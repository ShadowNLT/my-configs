#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from runstore import default_home, stop_all, stop_run  # noqa: E402


def _parse(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(prog="concept-viz-stop")
    parser.add_argument("target", help="run_id or the word all")
    parser.add_argument("--home", default=None)
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = _parse(sys.argv[1:] if argv is None else argv)
    home = Path(args.home) if args.home else default_home()
    if args.target == "all":
        stopped = stop_all(home)
        print(f"stopped {len(stopped)} run(s)")
        for run_id in stopped:
            print(f"concept-viz stopped (run_id={run_id}). This tab still works until refresh.")
        return 0
    result = stop_run(home, args.target)
    print(f"{args.target} {result}")
    print(
        f"concept-viz stopped (run_id={args.target}). This tab still works until refresh."
    )
    return 0 if result in {"stopped", "missing"} else 1


if __name__ == "__main__":
    raise SystemExit(main())
