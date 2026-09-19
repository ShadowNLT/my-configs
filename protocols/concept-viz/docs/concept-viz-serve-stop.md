# concept-viz — Serve / Stop / Tmp Lifecycle Contract

**Status:** normative · 2026-09-03  
**Companion to:** `concept-viz-hardened.md` §11 MUST #8  
**Scope:** ephemeral local HTML delivery only — not a publish path, not a cloud host.

---

## 1. Purpose

Every pass delivery is **HTML served locally from a tmp tree**. The server **must not run forever**. User or command can stop it; session teardown and TTL reap orphans. No LAN bind, no orphan listeners, no fixed-port collisions.

---

## 2. Bind and port

| Rule | Spec |
|------|------|
| Bind | **MUST** `127.0.0.1` only |
| Forbidden | `0.0.0.0`, `::`, hostname wildcards |
| Port | **MUST** bind **port 0** (OS ephemeral); record actual port from the listen socket |
| Forbidden | Hardcoded 8000 / 8080 / 5500 / any fixed default |

After bind, read the assigned port and write it to `meta.json` before printing the URL.

---

## 3. Tmp layout

One run = one directory:

```
{os.tmpdir()}/concept-viz-<uuid>/
  index.html          # entry (or path recorded in meta)
  …assets…            # self-contained under this tree only
  meta.json           # run sidecar (required)
```

- `uuid` = run_id (opaque, printable).  
- **MUST NOT** write under permanent project publish paths.  
- Symlinks that escape the tmp tree: **forbidden** (static server must refuse or not follow).

---

## 4. `meta.json` schema

```json
{
  "run_id": "<uuid>",
  "pid": 12345,
  "bind": "127.0.0.1",
  "port": 54321,
  "started_at": "<ISO-8601 UTC>",
  "expires_at": "<ISO-8601 UTC>",
  "html_entry": "index.html",
  "url": "http://127.0.0.1:54321/index.html",
  "marker": "CONCEPT_VIZ_RUN=<uuid>",
  "status": "running"
}
```

Also write human-readable `STOP` notes next to meta (or in chat only — meta remains machine source of truth).

- `expires_at` = `started_at + 30 minutes` (TTL).  
- `marker` / env `CONCEPT_VIZ_RUN=<uuid>` on the server process for identity checks.

---

## 5. Registry

Path: `{os.tmpdir()}/concept-viz-registry.json`

```json
{
  "runs": [
    {
      "run_id": "<uuid>",
      "meta_path": "/tmp/concept-viz-<uuid>/meta.json",
      "pid": 12345,
      "port": 54321,
      "expires_at": "<ISO-8601 UTC>"
    }
  ]
}
```

- Concurrent runs allowed (distinct ports/dirs).  
- Every start: append registry entry after successful listen.  
- Every stop: remove entry.  
- `concept-viz-stop all` walks registry.

---

## 6. TTL

- **Hard TTL: 30 minutes** from `started_at`.  
- Server **SHOULD** self-exit at TTL (timer in process) and invoke cleanup.  
- Even if self-exit fails: **reap-on-next** (below) removes expired entries.  
- Chat **MUST** mention TTL when printing the URL.

---

## 7. Start contract

Preferred: skill package `scripts/serve` (dedicated static wrapper) over ad-hoc forever `python -m http.server` in agent shell — same contracts either way.

On start:

1. Reap stale registry entries (see §9).  
2. Create `concept-viz-<uuid>/`, write HTML assets.  
3. Spawn server: bind `127.0.0.1`, port `0`, cwd/root = tmp dir, env `CONCEPT_VIZ_RUN=<uuid>`.  
4. Resolve actual port; write `meta.json`; update registry.  
5. Print chat UX strings (§12).  
6. Static files **only** — no upload, no POST handlers, no CGI, no directory listing of parents.

If foreground serve is used: trap INT/TERM → same stop hook as `concept-viz-stop`.

---

## 8. Stop command: `concept-viz-stop`

```
concept-viz-stop <run_id>
concept-viz-stop all
```

User may also say **“stop viz”** in chat; agent MUST map that to this script (all active runs, or the last run_id if unambiguous).

### Stop algorithm

1. Resolve `run_id` → `meta.json` (or all registry entries for `all`).  
2. **Identity check:** process at `pid` must still be ours — cmdline/env contains `CONCEPT_VIZ_RUN=<uuid>` or equivalent marker. If PID reused by foreign process → **MUST NOT** kill; delete stale meta/registry only.  
3. SIGTERM (or platform equivalent); wait briefly; SIGKILL if needed.  
4. `rm -rf` the tmp tree.  
5. Remove registry entry.  
6. Chat: server stopped; open tabs may 404.

---

## 9. Reap-on-next

On **every** invoke of serve (and SHOULD on stop all):

For each registry entry:

- If PID dead **OR** `expires_at` past → if PID alive and identity matches, kill; always delete tmp dir + registry row.  
- If meta missing but registry row exists → drop row; best-effort delete dir if present.

Crash / Cursor kill / `kill -9` without stop: next concept-viz start cleans up. No permanent orphans by design.

---

## 10. Crash and browser behavior

| Event | Behavior |
|-------|----------|
| Agent crash mid-serve | Registry + TTL + reap-on-next reclaim |
| `rm -rf` while tab open | Tab 404s; chat warned at stop |
| Port collision | Impossible under port 0 + reap; if listen fails, abort and report — do not fall back to fixed port |
| Two parallel runs | Distinct uuid/port/dir; both listed in registry |

---

## 11. Platform notes

| OS | Kill / process identity |
|----|-------------------------|
| **Linux** | SIGTERM → SIGKILL; read `/proc/<pid>/environ` or cmdline for `CONCEPT_VIZ_RUN` |
| **macOS** | Same signals; `ps`/`sysctl` cmdline check for marker |
| **Windows** | `taskkill /PID <pid> /T` (and job-object grouping if available); verify command line via WMI/CIM for marker before kill; paths use `%TEMP%\concept-viz-<uuid>\` |

Same `meta.json` + registry contract on all three. Scripts in `scripts/` MUST branch on platform without changing the schema.

---

## 12. Security

- Static file server only.  
- Bind loopback only.  
- Root = tmp run dir; no `..` escape; no following symlinks out of tree.  
- No `allow_reuse_address` tricks that attach to a foreign listener.  
- No auth cookies or tokens in served files.  
- Paste/HTML content treated as display data, not executable server config.

---

## 13. Chat UX strings (required)

On every successful start, print exactly this shape (values filled):

```
concept-viz ready
URL: http://127.0.0.1:<port>/index.html
Stop: concept-viz-stop <run_id>
TTL: 30 minutes (auto-reap after)
If any of [Assumes…] is new to you, say so — I’ll split/pre-train.
```

On stop:

```
concept-viz stopped (run_id=<uuid>). Open tabs may 404.
```

On reap of stale runs at next start (if any):

```
Reaped N stale concept-viz run(s).
```

---

## 14. Cleanup when user done

Triggers (any one):

1. User runs `concept-viz-stop` / says “stop viz”  
2. TTL expires (self-exit + cleanup)  
3. Session/agent teardown hook if available → stop all  
4. Next serve reaps dead/expired  

After cleanup: no listener on that port, no tmp dir, no registry row. Do not leave “just the HTML” without a live server as the default story — delivery is served HTML; optional future static export is out of this contract.

---

## 15. Prefer skill scripts

| Script | Role |
|--------|------|
| `scripts/serve` | create tmp, bind, write meta, register, print UX |
| `scripts/stop` | identity-checked kill, rm tmp, unregister |
| `scripts/reap` | shared stale cleanup (called by serve/stop) |

Agent shell one-liners are acceptable only if they honor every row of this contract; package scripts are the durable source of truth.

---

## Amendment (N, 2026-09-03): artifact lifetime vs server TTL

**Locked intent:** The served artifact is a **self-contained single-file HTML** (CSS/JS/SVG inlined). Once the browser has loaded the page, the **open tab keeps working** without needing the server — until the user **refreshes** (or opens a new tab to the URL).

Implications:
- Prefer **stop-on-command** + orphan reap over aggressive mid-view kills.
- Hard TTL is a **backstop for abandoned servers**, not “page expires in 30 minutes while you read.”
- After `concept-viz-stop`, tell the user: current tab still works; **refresh will fail** unless they saved the HTML.
- Offer optional “Save / download HTML” so refresh isn’t needed after stop.
- Bind remains `127.0.0.1` only — local web serve, **not** public internet.
