from __future__ import annotations

from dataclasses import asdict, dataclass
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Optional
import json
import os
import shutil
import signal
import subprocess
import sys
import tempfile
import time


BIND_HOST = "127.0.0.1"
DEFAULT_TTL_SECONDS = 1800
REGISTRY_NAME = "concept-viz-registry.json"
LOCK_NAME = "concept-viz-registry.lock"
META_NAME = "meta.json"
MARKER_PREFIX = "CONCEPT_VIZ_RUN="


@dataclass(frozen=True)
class RunMeta:
    run_id: str
    pid: int
    bind: str
    port: int
    started_at: str
    expires_at: str
    html_entry: str
    url: str
    marker: str
    status: str
    html_path: str

    def expired(self, now: Optional[datetime] = None) -> bool:
        current = now or datetime.now(timezone.utc)
        return current > datetime.fromisoformat(self.expires_at)


def default_home() -> Path:
    override = os.environ.get("CONCEPT_VIZ_HOME")
    if override:
        return Path(override)
    return Path(tempfile.gettempdir())


def run_dir(home: Path, run_id: str) -> Path:
    return home / f"concept-viz-{run_id}"


def registry_path(home: Path) -> Path:
    return home / REGISTRY_NAME


def meta_path(home: Path, run_id: str) -> Path:
    return run_dir(home, run_id) / META_NAME


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def marker_for(run_id: str) -> str:
    return f"{MARKER_PREFIX}{run_id}"


def make_meta(
    *,
    run_id: str,
    pid: int,
    port: int,
    html_path: str,
    started_at: Optional[str] = None,
    ttl_seconds: int = DEFAULT_TTL_SECONDS,
    status: str = "running",
    html_entry: str = "index.html",
) -> RunMeta:
    started = started_at or utc_now()
    started_dt = datetime.fromisoformat(started)
    expires = (started_dt + timedelta(seconds=ttl_seconds)).isoformat()
    return RunMeta(
        run_id=run_id,
        pid=pid,
        bind=BIND_HOST,
        port=int(port),
        started_at=started,
        expires_at=expires,
        html_entry=html_entry,
        url=f"http://{BIND_HOST}:{int(port)}/{html_entry}",
        marker=marker_for(run_id),
        status=status,
        html_path=html_path,
    )


def parse_meta(data: dict[str, Any]) -> RunMeta:
    run_id = str(data["run_id"])
    port = int(data["port"])
    html_entry = str(data.get("html_entry", "index.html"))
    started = str(data["started_at"])
    if "expires_at" in data:
        expires = str(data["expires_at"])
    else:
        ttl = int(data.get("ttl_seconds", DEFAULT_TTL_SECONDS))
        expires = (
            datetime.fromisoformat(started) + timedelta(seconds=ttl)
        ).isoformat()
    html_path = str(data.get("html_path", html_entry))
    return RunMeta(
        run_id=run_id,
        pid=int(data["pid"]),
        bind=str(data.get("bind", BIND_HOST)),
        port=port,
        started_at=started,
        expires_at=expires,
        html_entry=html_entry,
        url=str(data.get("url", f"http://{BIND_HOST}:{port}/{html_entry}")),
        marker=str(data.get("marker", marker_for(run_id))),
        status=str(data.get("status", "running")),
        html_path=html_path,
    )


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    tmp.replace(path)


def read_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


class RegistryLock:
    def __init__(self, home: Path) -> None:
        self.path = home / LOCK_NAME
        self._fh: Any = None

    def __enter__(self) -> "RegistryLock":
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._fh = open(self.path, "a+")
        if os.name == "nt":
            import msvcrt

            self._fh.seek(0)
            msvcrt.locking(self._fh.fileno(), msvcrt.LK_LOCK, 1)
        else:
            import fcntl

            fcntl.flock(self._fh.fileno(), fcntl.LOCK_EX)
        return self

    def __exit__(self, *exc: object) -> None:
        if self._fh is None:
            return
        if os.name == "nt":
            import msvcrt

            self._fh.seek(0)
            msvcrt.locking(self._fh.fileno(), msvcrt.LK_UNLCK, 1)
        else:
            import fcntl

            fcntl.flock(self._fh.fileno(), fcntl.LOCK_UN)
        self._fh.close()
        self._fh = None


def _runs(data: dict[str, Any]) -> list[dict[str, Any]]:
    raw = data.get("runs", [])
    if isinstance(raw, dict):
        return [{"run_id": key, **value} for key, value in raw.items()]
    return list(raw)


def registry_ids(data: dict[str, Any]) -> list[str]:
    return [str(row["run_id"]) for row in _runs(data)]


def load_registry(home: Path) -> dict[str, Any]:
    path = registry_path(home)
    if not path.exists():
        return {"runs": []}
    data = read_json(path)
    return {"runs": _runs(data)}


def save_registry(home: Path, data: dict[str, Any]) -> None:
    write_json(registry_path(home), {"runs": _runs(data)})


def pid_running(pid: int) -> bool:
    if pid <= 0:
        return False
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    except OSError:
        return False
    return True


def read_cmdline(pid: int) -> str:
    if os.name == "nt":
        return _read_cmdline_windows(pid)
    proc = Path(f"/proc/{pid}/cmdline")
    if proc.exists():
        raw = proc.read_bytes().replace(b"\x00", b" ")
        return raw.decode("utf-8", errors="replace").strip()
    try:
        out = subprocess.check_output(
            ["ps", "-p", str(pid), "-o", "args="],
            stderr=subprocess.DEVNULL,
            text=True,
        )
        return out.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return ""


def read_environ(pid: int) -> str:
    proc = Path(f"/proc/{pid}/environ")
    if proc.exists():
        raw = proc.read_bytes().replace(b"\x00", b" ")
        return raw.decode("utf-8", errors="replace")
    return ""


def _read_cmdline_windows(pid: int) -> str:
    try:
        out = subprocess.check_output(
            [
                "wmic",
                "process",
                "where",
                f"ProcessId={pid}",
                "get",
                "CommandLine",
                "/value",
            ],
            stderr=subprocess.DEVNULL,
            text=True,
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        return ""
    for line in out.splitlines():
        if line.startswith("CommandLine="):
            return line.split("=", 1)[1].strip()
    return ""


def identity_matches(meta: RunMeta, pid: Optional[int] = None) -> bool:
    target = meta.pid if pid is None else pid
    if not pid_running(target):
        return False
    blob = f"{read_cmdline(target)} {read_environ(target)}"
    if not blob.strip():
        return False
    return meta.marker in blob and meta.run_id in blob


def write_meta(home: Path, meta: RunMeta) -> Path:
    path = meta_path(home, meta.run_id)
    write_json(path, asdict(meta))
    return path


def read_meta(home: Path, run_id: str) -> Optional[RunMeta]:
    path = meta_path(home, run_id)
    if not path.exists():
        return None
    return parse_meta(read_json(path))


def register(home: Path, meta: RunMeta) -> None:
    write_meta(home, meta)
    with RegistryLock(home):
        data = load_registry(home)
        rows = [row for row in _runs(data) if row.get("run_id") != meta.run_id]
        rows.append(
            {
                "run_id": meta.run_id,
                "meta_path": str(meta_path(home, meta.run_id)),
                "pid": meta.pid,
                "port": meta.port,
                "expires_at": meta.expires_at,
            }
        )
        save_registry(home, {"runs": rows})


def unregister(home: Path, run_id: str) -> None:
    with RegistryLock(home):
        data = load_registry(home)
        rows = [row for row in _runs(data) if row.get("run_id") != run_id]
        save_registry(home, {"runs": rows})


def remove_run_tree(home: Path, run_id: str) -> None:
    path = run_dir(home, run_id)
    if path.exists():
        shutil.rmtree(path, ignore_errors=True)


def kill_pid(pid: int, wait_seconds: float = 2.0) -> None:
    if not pid_running(pid):
        return
    if os.name == "nt":
        subprocess.run(
            ["taskkill", "/PID", str(pid), "/T", "/F"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
        return
    try:
        os.kill(pid, signal.SIGTERM)
    except ProcessLookupError:
        return
    deadline = time.time() + wait_seconds
    while time.time() < deadline:
        if not pid_running(pid):
            return
        time.sleep(0.05)
    try:
        os.kill(pid, signal.SIGKILL)
    except ProcessLookupError:
        return


def reap(home: Path, now: Optional[datetime] = None) -> list[str]:
    removed: list[str] = []
    with RegistryLock(home):
        data = load_registry(home)
        kept: list[dict[str, Any]] = []
        for info in _runs(data):
            run_id = str(info.get("run_id", ""))
            meta = read_meta(home, run_id) if run_id else None
            pid = int(info.get("pid", 0)) if meta is None else meta.pid
            dead = not pid_running(pid)
            expired = bool(meta and meta.expired(now))
            drop = False
            if not run_id or meta is None:
                drop = True
            elif dead:
                drop = True
            elif expired and identity_matches(meta):
                kill_pid(meta.pid)
                drop = True
            elif not identity_matches(meta):
                drop = True
            if drop:
                removed.append(run_id)
            else:
                kept.append(info)
        save_registry(home, {"runs": kept})
    for run_id in removed:
        remove_run_tree(home, run_id)
    return [row for row in removed if row]


def stop_run(home: Path, run_id: str) -> str:
    reap(home)
    meta = read_meta(home, run_id)
    if meta is None:
        unregister(home, run_id)
        remove_run_tree(home, run_id)
        return "missing"
    if pid_running(meta.pid):
        if not identity_matches(meta):
            unregister(home, run_id)
            remove_run_tree(home, run_id)
            return "identity_mismatch"
        kill_pid(meta.pid)
    unregister(home, run_id)
    remove_run_tree(home, run_id)
    return "stopped"


def stop_all(home: Path) -> list[str]:
    reap(home)
    data = load_registry(home)
    ids = registry_ids(data)
    stopped: list[str] = []
    for run_id in ids:
        stop_run(home, run_id)
        stopped.append(run_id)
    return stopped


def python_executable() -> str:
    return sys.executable
