from __future__ import annotations

from pathlib import Path

from catalog import load_diagram_modules
from gate import Beat, SeriesPlan


def skeletons_dir() -> Path:
    return Path(__file__).resolve().parent / "skeletons"


def module_fragment_path(module_id: str) -> Path:
    modules = {item.id: item for item in load_diagram_modules()}
    if module_id not in modules:
        raise ValueError(f"unknown diagram_module {module_id!r}")
    path = skeletons_dir() / modules[module_id].fragment
    if not path.is_file():
        raise FileNotFoundError(path)
    return path


def markup_for(module_id: str) -> str:
    return module_fragment_path(module_id).read_text(encoding="utf-8")


def render_beat_stage(beat: Beat) -> str:
    if not beat.diagram_module:
        raise ValueError(f"beat {beat.n} missing diagram_module")
    return markup_for(beat.diagram_module)


def default_modules_for(plan: SeriesPlan) -> tuple[str, ...]:
    return tuple(beat.diagram_module for beat in plan.beats)
