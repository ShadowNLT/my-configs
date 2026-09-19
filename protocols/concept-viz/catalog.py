from __future__ import annotations

from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Optional
import json


JOBS = (
    "structure",
    "process",
    "compare",
    "quantity_in_concept",
    "constraint",
    "failure",
    "transfer",
)

DIMENSIONS = (
    "congruence",
    "element_interactivity_fit",
    "contiguity_feasible",
    "segmentability",
    "honesty",
    "expertise_fit",
    "seed_metaphor_consistency",
)

MIN_CANDIDATES = 3
SCORE_CAP = 1


@dataclass(frozen=True)
class Archetype:
    id: str
    title: str
    primary_job: str
    element_interactivity: int
    segmentable: bool
    expertise_fit: tuple[str, ...]
    seed_affinity: tuple[str, ...]
    motion_default: str = "static"
    honesty: str = ""
    notes: str = ""
    panels: int = 1
    diagram_module: str = ""


@dataclass(frozen=True)
class Seed:
    id: str
    title: str
    boost: tuple[str, ...]
    metaphors: tuple[str, ...] = ()
    forbidden_patterns: tuple[str, ...] = ()
    common_assumed_chunks: tuple[str, ...] = ()
    common_missing_stairs: tuple[str, ...] = ()
    interference_pairs: tuple[str, ...] = ()
    worked_example_skin: str = ""


@dataclass(frozen=True)
class ScoreContext:
    primary_job: str
    expertise: str
    hardest_beat_relations: int
    seed_id: Optional[str] = None
    wants_motion: bool = False


@dataclass(frozen=True)
class DimensionScores:
    congruence: int
    element_interactivity_fit: int
    contiguity_feasible: int
    segmentability: int
    honesty: int
    expertise_fit: int
    seed_metaphor_consistency: int

    def total(self) -> int:
        return sum(getattr(self, name) for name in DIMENSIONS)

    def failing(self) -> tuple[str, ...]:
        return tuple(name for name in DIMENSIONS if getattr(self, name) < 1)


@dataclass(frozen=True)
class ScoredCandidate:
    id: str
    scores: DimensionScores
    total: int
    rejected: bool
    rubric_ids: tuple[str, ...]


@dataclass(frozen=True)
class CatalogAudit:
    scored: tuple[ScoredCandidate, ...]
    selected: Optional[str]
    rejected: tuple[ScoredCandidate, ...]
    seed_id: Optional[str]
    job: str = ""


def _as_tuple(value: Any) -> tuple[str, ...]:
    if value is None:
        return ()
    return tuple(value)


@dataclass(frozen=True)
class DiagramModule:
    id: str
    title: str
    fragment: str
    layout: str


MIN_DIAGRAM_MODULES = 6


def load_diagram_modules(path: Path | None = None) -> tuple[DiagramModule, ...]:
    src = path or (catalog_dir() / "diagram_modules.json")
    raw = json.loads(src.read_text(encoding="utf-8"))
    items = raw["modules"] if isinstance(raw, dict) else raw
    out: list[DiagramModule] = []
    for item in items:
        out.append(
            DiagramModule(
                id=item["id"],
                title=item.get("title", item["id"]),
                fragment=item["fragment"],
                layout=item.get("layout", ""),
            )
        )
    return tuple(out)


def load_archetypes(path: Path) -> tuple[Archetype, ...]:
    raw = json.loads(path.read_text(encoding="utf-8"))
    items = raw["archetypes"] if isinstance(raw, dict) else raw
    out: list[Archetype] = []
    for item in items:
        module = item.get("diagram_module")
        if not isinstance(module, str) or not module.strip():
            raise ValueError(f"archetype {item.get('id')!r} missing diagram_module")
        out.append(
            Archetype(
                id=item["id"],
                title=item["title"],
                primary_job=item["primary_job"],
                element_interactivity=int(item["element_interactivity"]),
                segmentable=bool(item["segmentable"]),
                expertise_fit=_as_tuple(item.get("expertise_fit")),
                seed_affinity=_as_tuple(item.get("seed_affinity")),
                motion_default=item.get("motion_default", "static"),
                honesty=item.get("honesty", ""),
                notes=item.get("notes", ""),
                panels=int(item.get("panels", 1)),
                diagram_module=module.strip(),
            )
        )
    return tuple(out)


def validate_catalog(
    archetypes: tuple[Archetype, ...] | list[Archetype],
    modules: tuple[DiagramModule, ...] | list[DiagramModule],
) -> None:
    known = {module.id for module in modules}
    if len(known) < MIN_DIAGRAM_MODULES:
        raise ValueError(
            f"diagram module registry has {len(known)} ids; need ≥{MIN_DIAGRAM_MODULES}"
        )
    used: set[str] = set()
    for arch in archetypes:
        if not arch.diagram_module:
            raise ValueError(f"archetype {arch.id!r} missing diagram_module")
        if arch.diagram_module not in known:
            raise ValueError(
                f"archetype {arch.id!r} unknown diagram_module {arch.diagram_module!r}"
            )
        used.add(arch.diagram_module)
    if len(used) < MIN_DIAGRAM_MODULES:
        raise ValueError(
            f"catalog uses {len(used)} diagram_module ids; need ≥{MIN_DIAGRAM_MODULES}"
        )


def load_seed(path: Path) -> Seed:
    item = json.loads(path.read_text(encoding="utf-8"))
    preferred = item.get("preferred_archetypes") or item.get("boost")
    zoo = item.get("metaphor_zoo") or item.get("metaphors")
    return Seed(
        id=item["id"],
        title=item["title"],
        boost=_as_tuple(preferred),
        metaphors=_as_tuple(zoo),
        forbidden_patterns=_as_tuple(item.get("forbidden_patterns")),
        common_assumed_chunks=_as_tuple(item.get("common_assumed_chunks")),
        common_missing_stairs=_as_tuple(item.get("common_missing_stairs")),
        interference_pairs=_as_tuple(item.get("interference_pairs")),
        worked_example_skin=str(item.get("worked_example_skin", "")),
    )


def score_archetype(
    arch: Archetype, ctx: ScoreContext, seed: Optional[Seed] = None
) -> DimensionScores:
    congruence = 1 if arch.primary_job == ctx.primary_job else 0
    delta = abs(arch.element_interactivity - ctx.hardest_beat_relations)
    interact = 1 if delta <= 1 else 0
    contiguity = 1 if arch.segmentable else 0
    segment = 1 if arch.segmentable else 0
    if ctx.wants_motion and arch.motion_default == "static":
        honesty = 0
    else:
        honesty = 1
    expertise = 1 if ctx.expertise in arch.expertise_fit else 0
    if ctx.seed_id is None:
        seed_score = 1
    elif ctx.seed_id in arch.seed_affinity:
        seed_score = 1
    else:
        seed_score = 0
    if (
        seed is not None
        and ctx.seed_id == seed.id
        and arch.id in seed.boost
    ):
        seed_score = 1
    return DimensionScores(
        congruence=congruence,
        element_interactivity_fit=interact,
        contiguity_feasible=contiguity,
        segmentability=segment,
        honesty=honesty,
        expertise_fit=expertise,
        seed_metaphor_consistency=seed_score,
    )


def score_and_pick(
    archetypes: tuple[Archetype, ...] | list[Archetype],
    ctx: ScoreContext,
    seed: Optional[Seed] = None,
) -> CatalogAudit:
    if seed is not None and ctx.seed_id != seed.id:
        raise ValueError("ScoreContext.seed_id must match the loaded seed")
    if len(tuple(archetypes)) < MIN_CANDIDATES:
        raise ValueError(f"score at least {MIN_CANDIDATES} catalog candidates")
    by_id = {arch.id: arch for arch in archetypes}
    scored: list[ScoredCandidate] = []
    for arch in archetypes:
        dims = score_archetype(arch, ctx, seed)
        failing = dims.failing()
        rejected = dims.congruence == 0
        scored.append(
            ScoredCandidate(
                id=arch.id,
                scores=dims,
                total=dims.total(),
                rejected=rejected,
                rubric_ids=failing if rejected else (),
            )
        )

    def _lock_key(candidate: ScoredCandidate) -> tuple[int, int, int, str]:
        arch = by_id[candidate.id]
        motion_penalty = 0 if arch.motion_default == "static" else 1
        return (-candidate.total, motion_penalty, arch.panels, candidate.id)

    scored.sort(key=_lock_key)
    viable = [c for c in scored if not c.rejected]
    selected = viable[0].id if viable else None
    return CatalogAudit(
        scored=tuple(scored),
        selected=selected,
        rejected=tuple(c for c in scored if c.rejected),
        seed_id=ctx.seed_id,
        job=ctx.primary_job,
    )


def audit_to_dict(audit: CatalogAudit) -> dict[str, Any]:
    return {
        "selected": audit.selected,
        "job": audit.job,
        "seed_id": audit.seed_id,
        "scored": [
            {
                "id": c.id,
                "total": c.total,
                "rejected": c.rejected,
                "rubric_ids": list(c.rubric_ids),
                "scores": asdict(c.scores),
            }
            for c in audit.scored
        ],
        "rejected": [
            {"id": c.id, "rubric_ids": list(c.rubric_ids)} for c in audit.rejected
        ],
    }


def catalog_dir() -> Path:
    return Path(__file__).resolve().parent / "catalog"


def seeds_dir() -> Path:
    return Path(__file__).resolve().parent / "seeds"


def load_bundled_catalog() -> tuple[Archetype, ...]:
    general = catalog_dir() / "general.json"
    legacy = catalog_dir() / "archetypes.json"
    archetypes = load_archetypes(general if general.exists() else legacy)
    validate_catalog(archetypes, load_diagram_modules())
    return archetypes


def load_bundled_seed(seed_id: str) -> Seed:
    return load_seed(seeds_dir() / f"{seed_id}.json")
