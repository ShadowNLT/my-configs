#!/usr/bin/env python3
"""Read a vault .seed-state file. Standard library only.

The same file ships, byte for byte, in every protocol folder that works on the
vault (memory-map, vault-research). Install runs it before anything is written.
The stop label comes from the folder name, so the copies never differ.
"""

from __future__ import annotations

import sys
from pathlib import Path

LABEL = Path(__file__).resolve().parent.name.replace("-", " ").capitalize()


def stop(reason: str) -> None:
    print(f"{LABEL} stopped: {reason}")
    raise SystemExit(1)


def seed_status(vault: Path) -> str | None:
    path = vault / ".seed-state"
    if not path.is_file():
        return None
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""
    for line in text.splitlines():
        stripped = line.strip()
        if stripped:
            return stripped
    return ""


def check_seed(vault: Path) -> None:
    status = seed_status(vault)
    if status is None:
        stop(".seed-state is missing.")
    if status != "status: done":
        stop(".seed-state does not say done.")


def main(argv: list[str]) -> None:
    if len(argv) != 2 or not argv[1] or argv[1].startswith("-"):
        stop("vault path argument is missing.")
    vault = Path(argv[1]).expanduser()
    if not vault.is_dir():
        stop("vault path is not a directory.")
    check_seed(vault.resolve())


if __name__ == "__main__":
    main(sys.argv)
