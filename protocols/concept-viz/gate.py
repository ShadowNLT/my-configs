from __future__ import annotations

from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Literal, Optional
import json

from retrieval import (
    RetrievalPrompt,
    check_retrieval,
    parse_retrieval,
    retrieval_closed_world,
)


Expertise = Literal["novice", "intermediate", "expert"]
SplitReason = Literal[
    "missing_stair", "multi_goal", "high_interactivity", "ambiguous_prior"
]
PriorSource = Literal["inferred", "probed", "default_novice"]
Verdict = Literal["single_grain", "must_split"]

NOVEL_BUDGET: dict[str, int] = {
    "novice": 4,
    "intermediate": 6,
    "expert": 8,
}

FAN_IN_LIMIT = 4
MAX_CHILD_GRAINS = 12
MAX_PROBE_TURNS = 1
MAX_PROBE_QUESTIONS = 3
MAX_PROBE_WORDS = 80

SPLIT_ORDER: tuple[SplitReason, ...] = (
    "ambiguous_prior",
    "multi_goal",
    "missing_stair",
    "high_interactivity",
)


@dataclass(frozen=True)
class Probe:
    questions: tuple[str, ...]
    word_count: int
    turns: int = 1


@dataclass(frozen=True)
class ChildGrain:
    id: str
    teaching: str
    assumed: tuple[str, ...]


@dataclass(frozen=True)
class Grain:
    id: str
    teaching: str
    assumed_priors: tuple[str, ...]
    novel_intros: tuple[str, ...]
    hardest_beat_relations: int
    fan_in: int
    expertise: Expertise
    goals: tuple[str, ...]
    high_interactivity: bool
    prior_confidence: Literal["high", "low"]
    missing_priors: tuple[str, ...] = ()


@dataclass(frozen=True)
class AssumptionFooter:
    assumes: str
    teaching: str
    exit: str

    def render(self) -> str:
        return (
            f"Assumes: {self.assumes} · Teaching: {self.teaching} "
            f"· Exit: able to {self.exit}"
        )


@dataclass(frozen=True)
class Split:
    reason: SplitReason
    children: tuple[ChildGrain, ...]
    offer: str


@dataclass(frozen=True)
class GateRecord:
    ask: str
    expertise: Expertise
    prior_source: PriorSource
    grain: Grain
    verdict: Verdict
    footer: Optional[AssumptionFooter]
    split: Optional[Split]
    probe: Optional[Probe]
    show_graph: bool
    reject_reasons: tuple[str, ...]
    novel_budget: int


@dataclass(frozen=True)
class Beat:
    n: int
    kind: Literal["teach", "retrieval"]
    novel_intros: tuple[str, ...] = ()
    diagram_module: str = ""


@dataclass(frozen=True)
class SeriesPlan:
    grain_id: str
    primary_job: str
    seed: Optional[str]
    beats: tuple[Beat, ...]
    able_to: str
    retrieval: RetrievalPrompt
    motion_used: bool = False
    motion_justification: Optional[str] = None


def load_series_plan(path: Path) -> SeriesPlan:
    raw = json.loads(path.read_text(encoding="utf-8"))
    if not retrieval_closed_world(raw.get("retrieval")):
        reasons = check_retrieval(raw.get("retrieval"))
        raise ValueError(f"retrieval_closed_world failed: {', '.join(reasons)}")
    beats: list[Beat] = []
    for item in raw["beats"]:
        module = item.get("diagram_module")
        if not isinstance(module, str) or not module.strip():
            raise ValueError(f"beat {item.get('n')!r} missing diagram_module")
        beats.append(
            Beat(
                n=int(item["n"]),
                kind=item["kind"],
                novel_intros=tuple(item.get("novel_intros") or ()),
                diagram_module=module.strip(),
            )
        )
    return SeriesPlan(
        grain_id=raw["grain_id"],
        primary_job=raw["primary_job"],
        seed=raw.get("seed"),
        beats=tuple(beats),
        able_to=raw["able_to"],
        retrieval=parse_retrieval(raw["retrieval"]),
        motion_used=bool(raw.get("motion_used", False)),
        motion_justification=raw.get("motion_justification"),
    )


def novel_budget(expertise: Expertise) -> int:
    return NOVEL_BUDGET[expertise]


def unique_novels(names: tuple[str, ...]) -> tuple[str, ...]:
    seen: list[str] = []
    for name in names:
        if name not in seen:
            seen.append(name)
    return tuple(seen)


def series_novel_intros(plan: SeriesPlan) -> tuple[str, ...]:
    names: list[str] = []
    for beat in plan.beats:
        names.extend(beat.novel_intros)
    return unique_novels(tuple(names))


def probe_ok(probe: Optional[Probe]) -> bool:
    if probe is None:
        return True
    return (
        probe.turns <= MAX_PROBE_TURNS
        and len(probe.questions) <= MAX_PROBE_QUESTIONS
        and probe.word_count <= MAX_PROBE_WORDS
    )


def has_scope_limiter(ask: str) -> bool:
    text = ask.lower()
    return any(
        token in text
        for token in (
            "just the",
            "only the",
            "only a",
            "one diagram",
            "vanilla",
            "just ",
        )
    )


def ask_is_multi_goal(ask: str) -> bool:
    text = ask.lower()
    return any(
        token in text
        for token in (
            " and also ",
            " vs ",
            " versus ",
            "from scratch",
            "everything about",
        )
    )


def split_reasons(grain: Grain, ask: str = "") -> tuple[SplitReason, ...]:
    reasons: list[SplitReason] = []
    budget = novel_budget(grain.expertise)
    novels = unique_novels(grain.novel_intros)
    if grain.prior_confidence == "low":
        reasons.append("ambiguous_prior")
    if len(grain.goals) > 1 or ask_is_multi_goal(ask):
        reasons.append("multi_goal")
    if (
        grain.missing_priors
        or len(novels) > budget
        or grain.fan_in > FAN_IN_LIMIT
        or len(grain.goals) == 0
    ):
        reasons.append("missing_stair")
    if grain.high_interactivity or grain.hardest_beat_relations > budget:
        reasons.append("high_interactivity")
    found = {r for r in SPLIT_ORDER if r in reasons}
    if has_scope_limiter(ask) and grain.fan_in <= FAN_IN_LIMIT:
        hard: set[SplitReason] = set()
        if "multi_goal" in found:
            hard.add("multi_goal")
        if len(novels) > budget or grain.fan_in > FAN_IN_LIMIT:
            hard.add("missing_stair")
        if grain.high_interactivity or grain.hardest_beat_relations > budget:
            hard.add("high_interactivity")
        found = hard
    return tuple(r for r in SPLIT_ORDER if r in found)


def _footer_for(grain: Grain) -> AssumptionFooter:
    assumes = ", ".join(grain.assumed_priors) if grain.assumed_priors else "none named"
    return AssumptionFooter(
        assumes=assumes,
        teaching=grain.teaching,
        exit=grain.teaching,
    )


def evaluate(
    ask: str,
    grain: Grain,
    probe: Optional[Probe] = None,
    children: tuple[ChildGrain, ...] = (),
    prior_source: Optional[PriorSource] = None,
) -> GateRecord:
    source: PriorSource = prior_source or ("probed" if probe is not None else "inferred")
    reasons = split_reasons(grain, ask)
    budget = novel_budget(grain.expertise)
    if reasons:
        clipped = children[:MAX_CHILD_GRAINS]
        offer = clipped[0].id if clipped else "grain_1"
        return GateRecord(
            ask=ask,
            expertise=grain.expertise,
            prior_source=source,
            grain=grain,
            verdict="must_split",
            footer=None,
            split=Split(reason=reasons[0], children=clipped, offer=offer),
            probe=probe,
            show_graph=True,
            reject_reasons=reasons,
            novel_budget=budget,
        )
    return GateRecord(
        ask=ask,
        expertise=grain.expertise,
        prior_source=source,
        grain=grain,
        verdict="single_grain",
        footer=_footer_for(grain),
        split=None,
        probe=probe,
        show_graph=False,
        reject_reasons=(),
        novel_budget=budget,
    )


def series_respects_budget(record: GateRecord, plan: SeriesPlan) -> bool:
    if record.verdict != "single_grain":
        return False
    if plan.grain_id != record.grain.id:
        return False
    gated = unique_novels(record.grain.novel_intros)
    appeared = series_novel_intros(plan)
    if set(appeared) != set(gated):
        return False
    allowed = set(record.grain.assumed_priors) | set(gated)
    if plan.beats:
        allowed |= set(plan.beats[0].novel_intros)
    for beat in plan.beats[1:]:
        for name in beat.novel_intros:
            if name not in allowed:
                return False
    return True


def record_to_dict(record: GateRecord) -> dict[str, Any]:
    payload = asdict(record)
    if record.footer is not None:
        payload["footer"]["rendered"] = record.footer.render()
    return payload
