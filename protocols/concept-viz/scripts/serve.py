#!/usr/bin/env python3
from __future__ import annotations

import argparse
import http.server
import os
import shutil
import signal
import socketserver
import sys
import threading
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from runstore import (  # noqa: E402
    BIND_HOST,
    DEFAULT_TTL_SECONDS,
    make_meta,
    marker_for,
    default_home,
    reap,
    register,
    run_dir,
    unregister,
)


class _Handler(http.server.BaseHTTPRequestHandler):
    html_bytes = b""

    def do_GET(self) -> None:
        path = self.path.split("?", 1)[0]
        if path in ("/", "/index.html"):
            body = self.html_bytes
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write(body)
            return
        self.send_error(404)

    def do_HEAD(self) -> None:
        path = self.path.split("?", 1)[0]
        if path in ("/", "/index.html"):
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(self.html_bytes)))
            self.end_headers()
            return
        self.send_error(404)

    def log_message(self, fmt: str, *args: object) -> None:
        sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))


class _Server(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = False


def _parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(prog="concept-viz-serve")
    parser.add_argument("html", help="path to a self-contained HTML file")
    parser.add_argument("--home", default=None)
    parser.add_argument("--ttl", type=int, default=DEFAULT_TTL_SECONDS)
    parser.add_argument("--run-id", default=None)
    return parser.parse_args(argv)


def _reexec_with_identity(args: argparse.Namespace) -> None:
    run_id = args.run_id or str(uuid.uuid4())
    cmd = [
        sys.executable,
        str(Path(__file__).resolve()),
        str(Path(args.html).resolve()),
        "--ttl",
        str(args.ttl),
        "--run-id",
        run_id,
        marker_for(run_id),
    ]
    if args.home:
        cmd.extend(["--home", str(Path(args.home).resolve())])
    os.environ["CONCEPT_VIZ_RUN"] = run_id
    os.execv(sys.executable, cmd)


def main(argv: list[str] | None = None) -> int:
    raw = list(sys.argv[1:] if argv is None else argv)
    markers = [item for item in raw if item.startswith("CONCEPT_VIZ_RUN=")]
    cleaned = [item for item in raw if not item.startswith("CONCEPT_VIZ_RUN=")]
    args = _parse_args(cleaned)
    if not args.run_id or not markers:
        _reexec_with_identity(args)
        return 1
    os.environ["CONCEPT_VIZ_RUN"] = args.run_id

    home = Path(args.home) if args.home else default_home()
    html_src = Path(args.html).resolve()
    if not html_src.is_file():
        print(f"html not found: {html_src}", file=sys.stderr)
        return 2

    removed = reap(home)
    if removed:
        print(f"Reaped {len(removed)} stale concept-viz run(s).", flush=True)
    dest_dir = run_dir(home, args.run_id)
    dest_dir.mkdir(parents=True, exist_ok=True)
    dest_html = dest_dir / "index.html"
    shutil.copy2(html_src, dest_html)
    html_bytes = dest_html.read_bytes()

    handler = type("Handler", (_Handler,), {"html_bytes": html_bytes})
    httpd = _Server((BIND_HOST, 0), handler)
    host, port = httpd.server_address[:2]
    if host != BIND_HOST:
        httpd.server_close()
        print(f"refusing bind {host}", file=sys.stderr)
        return 3

    meta = make_meta(
        run_id=args.run_id,
        pid=os.getpid(),
        port=int(port),
        html_path=str(dest_html),
        ttl_seconds=int(args.ttl),
    )
    register(home, meta)
    print(f"CONCEPT_VIZ_RUN_ID={args.run_id}", flush=True)
    print(f"CONCEPT_VIZ_PORT={port}", flush=True)
    print(f"CONCEPT_VIZ_URL={meta.url}", flush=True)
    print(f"CONCEPT_VIZ_HTML={dest_html}", flush=True)
    print("concept-viz ready", flush=True)
    print(f"URL: {meta.url}", flush=True)
    print(f"Stop: concept-viz-stop {args.run_id}", flush=True)
    print("TTL: 30 minutes (auto-reap after)", flush=True)
    print(
        "If any of [Assumes…] is new to you, say so — I’ll split/pre-train.",
        flush=True,
    )

    stop_once = threading.Event()

    def shutdown(_signum: int | None = None, _frame: object | None = None) -> None:
        if stop_once.is_set():
            return
        stop_once.set()
        threading.Thread(target=httpd.shutdown, daemon=True).start()

    signal.signal(signal.SIGTERM, shutdown)
    signal.signal(signal.SIGINT, shutdown)
    timer = threading.Timer(max(1, int(args.ttl)), shutdown)
    timer.daemon = True
    timer.start()
    try:
        httpd.serve_forever()
    finally:
        timer.cancel()
        httpd.server_close()
        unregister(home, args.run_id)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
