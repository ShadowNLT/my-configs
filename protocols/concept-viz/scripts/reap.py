#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from runstore import default_home, reap  # noqa: E402


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="concept-viz-reap")
    parser.add_argument("--home", default=None)
    args = parser.parse_args(sys.argv[1:] if argv is None else argv)
    home = Path(args.home) if args.home else default_home()
    removed = reap(home)
    if removed:
        print(f"Reaped {len(removed)} stale concept-viz run(s).")
        for run_id in removed:
            print(run_id)
    else:
        print("Reaped 0 stale concept-viz run(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
