from __future__ import annotations

from dataclasses import dataclass
from typing import Any
import json
import re


MISSING_GIVEN = "missing_given"
EMPTY_GIVEN = "empty_given"
NONCONCRETE_GIVEN = "nonconcrete_given"
MISSING_QUESTION = "missing_question"
FUSED_OPS = "fused_ops"
NAME_NOT_IN_GIVEN = "name_not_in_given"
HEADER_NOT_IN_GIVEN = "header_not_in_given"
OPTIONS_MISSING = "options_missing"
ANSWER_NOT_IN_OPTIONS = "answer_not_in_options"

_IDENT = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*)\b")
_HEADER_FN = re.compile(r"\b(ptr|len|cap)\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)")
_PREDICATE = re.compile(r"[<>]=?|!=|(?<![:=])=(?!=)")
_MUTATION = re.compile(
    r":=|\bappend\s*\(|\[\s*[\w]*\s*\]\s*=|\+=|(?<![:<>=!])=(?!=)",
    re.IGNORECASE,
)
_STOP = frozenset(
    {
        "an",
        "and",
        "after",
        "answer",
        "are",
        "before",
        "both",
        "cap",
        "does",
        "false",
        "for",
        "from",
        "given",
        "how",
        "in",
        "is",
        "it",
        "keys",
        "len",
        "no",
        "none",
        "not",
        "now",
        "of",
        "on",
        "only",
        "or",
        "ptr",
        "same",
        "see",
        "share",
        "still",
        "the",
        "then",
        "this",
        "that",
        "to",
        "true",
        "what",
        "which",
        "yes",
    }
)


@dataclass(frozen=True)
class RetrievalPrompt:
    given: dict[str, Any]
    question: str
    options: tuple[str, ...]
    answer: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "given": self.given,
            "question": self.question,
            "options": list(self.options),
            "answer": self.answer,
        }


def parse_retrieval(raw: Any) -> RetrievalPrompt:
    if not isinstance(raw, dict):
        raise ValueError("retrieval must be an object with given, question, options, answer")
    given = raw.get("given")
    if given is None:
        given = {}
    if not isinstance(given, dict):
        raise ValueError("retrieval.given must be an object")
    options = raw.get("options") or ()
    if not isinstance(options, (list, tuple)):
        raise ValueError("retrieval.options must be an array")
    return RetrievalPrompt(
        given=dict(given),
        question=str(raw.get("question") or ""),
        options=tuple(str(item) for item in options),
        answer=str(raw.get("answer") or ""),
    )


def load_retrieval(path) -> RetrievalPrompt:
    return parse_retrieval(json.loads(path.read_text(encoding="utf-8")))


def _concrete(value: Any) -> bool:
    if isinstance(value, (int, float, bool)):
        return True
    if isinstance(value, str):
        text = value.strip()
        if not text:
            return False
        if _PREDICATE.search(text) and not re.fullmatch(r"-?\d+(\.\d+)?", text):
            return False
        return True
    if isinstance(value, list):
        return bool(value) and all(_concrete(item) for item in value)
    if isinstance(value, dict):
        return bool(value) and all(_concrete(item) for item in value.values())
    return False


def _live_names(text: str) -> set[str]:
    names = set()
    for match in _IDENT.finditer(text):
        token = match.group(1)
        if token.lower() in _STOP:
            continue
        if token.lower() in {"append", "grow", "reslice"}:
            continue
        names.add(token)
    return names


def _has_header(given: dict[str, Any], name: str, field: str) -> bool:
    value = given.get(name)
    if isinstance(value, dict) and field in value:
        return _concrete(value[field])
    if field == "len" and isinstance(value, (list, tuple, str)):
        return True
    return False


def check_retrieval(raw: Any) -> tuple[str, ...]:
    reasons: list[str] = []
    if not isinstance(raw, dict):
        return (MISSING_GIVEN, MISSING_QUESTION, OPTIONS_MISSING)
    if "given" not in raw:
        reasons.append(MISSING_GIVEN)
        given: dict[str, Any] = {}
    elif not isinstance(raw["given"], dict):
        reasons.append(MISSING_GIVEN)
        given = {}
    elif len(raw["given"]) == 0:
        reasons.append(EMPTY_GIVEN)
        given = {}
    else:
        given = raw["given"]
        if not all(_concrete(value) for value in given.values()):
            reasons.append(NONCONCRETE_GIVEN)

    question = raw.get("question")
    if not isinstance(question, str) or not question.strip():
        reasons.append(MISSING_QUESTION)
        question = ""
    elif len(_MUTATION.findall(question)) >= 2:
        reasons.append(FUSED_OPS)

    options = raw.get("options")
    if not isinstance(options, (list, tuple)) or len(options) < 2:
        reasons.append(OPTIONS_MISSING)
        option_text = ""
    else:
        option_text = " ".join(str(item) for item in options)

    answer = raw.get("answer")
    if (
        isinstance(options, (list, tuple))
        and len(options) >= 2
        and (not isinstance(answer, str) or str(answer) not in {str(item) for item in options})
    ):
        reasons.append(ANSWER_NOT_IN_OPTIONS)

    stem = f"{question} {option_text}"
    for name in _live_names(stem):
        if name not in given:
            reasons.append(NAME_NOT_IN_GIVEN)
            break
    for field, name in _HEADER_FN.findall(stem):
        if name in given and not _has_header(given, name, field):
            reasons.append(HEADER_NOT_IN_GIVEN)
            break
    return tuple(dict.fromkeys(reasons))


def retrieval_closed_world(raw: Any) -> bool:
    return not check_retrieval(raw)
