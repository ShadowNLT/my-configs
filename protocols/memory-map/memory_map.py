#!/usr/bin/env python3
"""Map a vault into a word index, a meaning index, and a topic graph.

The vault path is a required argument. There is no default path.
"""

from __future__ import annotations

import contextlib
import hashlib
import io
import json
import math
import os
import re
import shutil
import sqlite3
import sys
import tempfile
import warnings
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import quote

from seed_state import check_seed

LIVE_NAMES = ("map.sqlite", "vectors.hnsw", "done")
OFFICE = {
    "doc",
    "docx",
    "docm",
    "dot",
    "dotx",
    "ppt",
    "pptx",
    "pptm",
    "pot",
    "potx",
    "xls",
    "xlsx",
    "xlsm",
    "xlsb",
    "xlt",
    "xltx",
    "odt",
    "ods",
    "odp",
}
IMAGES = {"png", "jpg", "jpeg", "gif", "webp", "tif", "tiff", "bmp", "jp2", "jfif"}
PLAIN = {"md", "markdown", "txt", "text", "csv", "tsv", "rst", "log"}
STOPWORDS = {
    "a",
    "an",
    "and",
    "are",
    "as",
    "at",
    "be",
    "by",
    "for",
    "from",
    "in",
    "is",
    "it",
    "of",
    "on",
    "or",
    "that",
    "the",
    "to",
    "was",
    "with",
    "der",
    "die",
    "das",
    "und",
    "ein",
    "eine",
    "ist",
    "im",
    "zu",
    "den",
    "dem",
    "des",
    "nicht",
    "auf",
    "für",
    "von",
}
_SECRET = re.compile(
    r"(?i)"
    r"(?:\b(?:sk|rk|pk|ghp|gho|github_pat|xox[baprs]|akia|asia|aiza)"
    r"[-_][a-z0-9_\-]{8,}\b)"
    r"|"
    r"(?:\b(?:api[_-]?key|apikey|secret|password|passwd|credential|"
    r"auth[_-]?token|access[_-]?key)\b\s*[:=]\s*\S+)"
    r"|"
    r"(?:\btoken\b\s*[:=]\s*\S+)"
    r"|"
    r"(?:\beyJ[A-Za-z0-9_\-]{8,}\.[A-Za-z0-9_\-]{8,}\.[A-Za-z0-9_\-]{8,})"
    r"|"
    r"(?:\b[a-f0-9]{32,}\b)"
    r"|"
    r"(?:\b[A-Za-z0-9+/]{40,}={0,2}\b)"
)
_WORD = re.compile(r"[^\W\d_]{2,}", re.UNICODE)
_WIKI = re.compile(r"\[\[([^\]|#]+)(?:#[^\]|]+)?(?:\|[^\]]+)?\]\]")
_MD_LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")
_MEANING_MIN = 0.80
_WORD_MIN = 0.20


def stop(reason: str) -> None:
    print(f"Memory map stopped: {reason}")
    raise SystemExit(1)


def data_home() -> Path:
    xdg = os.environ.get("XDG_DATA_HOME")
    if xdg:
        return Path(xdg)
    return Path.home() / ".local" / "share"


def model_dir() -> Path:
    env = os.environ.get("MEMORY_MAP_MODEL_DIR")
    if env:
        return Path(env).expanduser()
    return data_home() / "memory-map" / "models" / "multilingual-e5-small"


def tessdata_dir() -> Path:
    env = os.environ.get("TESSDATA_PREFIX")
    if env:
        path = Path(env).expanduser()
    else:
        path = data_home() / "memory-map" / "tessdata"
    nested = path / "tessdata"
    if not (path / "eng.traineddata").is_file() and (nested / "eng.traineddata").is_file():
        path = nested
    os.environ["TESSDATA_PREFIX"] = str(path)
    return path


def model_ready(path: Path) -> bool:
    if not (path / "config.json").is_file():
        return False
    if not (path / "modules.json").is_file():
        return False
    if not (path / "tokenizer.json").is_file() and not (path / "vocab.txt").is_file():
        return False
    if list(path.glob("*.safetensors")):
        return True
    return (path / "pytorch_model.bin").is_file()


def parse_vault(argv: list[str]) -> Path:
    if len(argv) != 2 or not argv[1] or argv[1].startswith("-"):
        stop("vault path argument is missing.")
    vault = Path(argv[1]).expanduser()
    if not vault.is_dir():
        stop("vault path is not a directory.")
    return vault.resolve()


def check_python() -> None:
    if sys.version_info < (3, 10):
        stop("Python 3.10 or newer is missing.")


def check_fts5() -> None:
    con = sqlite3.connect(":memory:")
    try:
        con.execute("create virtual table t using fts5(x)")
        con.execute("insert into t(x) values ('alpha')")
        con.execute("select bm25(t) from t where t match 'alpha'")
    except sqlite3.OperationalError:
        stop("SQLite FTS5 is missing.")
    finally:
        con.close()


def check_model() -> Path:
    path = model_dir()
    if not model_ready(path):
        stop("multilingual-e5-small model files are missing.")
    return path


def check_tessdata() -> Path:
    path = tessdata_dir()
    missing = []
    for label, name in (("English", "eng.traineddata"), ("German", "deu.traineddata")):
        file = path / name
        if not file.is_file() or file.stat().st_size < 1_000_000:
            missing.append(label)
    if len(missing) == 2:
        stop("English and German OCR language files are missing.")
    if missing:
        stop(f"{missing[0]} OCR language file is missing.")
    return path


def check_libraries() -> None:
    modules = (
        ("liteparse", "liteparse"),
        ("sentence-transformers", "sentence_transformers"),
        ("hnswlib", "hnswlib"),
        ("python-igraph", "igraph"),
        ("leidenalg", "leidenalg"),
    )
    missing = []
    sink = io.StringIO()
    for dist, module in modules:
        try:
            with contextlib.redirect_stdout(sink):
                __import__(module)
        except Exception:
            missing.append(dist)
    if missing:
        stop("pinned libraries are missing: " + ", ".join(missing) + ".")


def prepare_runtime(vault: Path) -> Path:
    root = vault / ".memory-map"
    cache = root / "cache"
    tmp = root / "tmp"
    cache.mkdir(parents=True, exist_ok=True)
    tmp.mkdir(parents=True, exist_ok=True)
    os.environ["HF_HUB_OFFLINE"] = "1"
    os.environ["TRANSFORMERS_OFFLINE"] = "1"
    os.environ["HF_DATASETS_OFFLINE"] = "1"
    os.environ["HF_HUB_DISABLE_TELEMETRY"] = "1"
    os.environ["HF_HUB_DISABLE_PROGRESS_BARS"] = "1"
    os.environ["TRANSFORMERS_VERBOSITY"] = "error"
    os.environ["TOKENIZERS_PARALLELISM"] = "false"
    os.environ["TQDM_DISABLE"] = "1"
    os.environ["HF_HOME"] = str(cache / "hf")
    os.environ["HUGGINGFACE_HUB_CACHE"] = str(cache / "hf" / "hub")
    os.environ["SENTENCE_TRANSFORMERS_HOME"] = str(cache / "st")
    os.environ["XDG_CACHE_HOME"] = str(cache / "xdg")
    os.environ["TMPDIR"] = str(tmp)
    os.environ["TEMP"] = str(tmp)
    os.environ["TMP"] = str(tmp)
    tempfile.tempdir = str(tmp)
    warnings.filterwarnings("ignore")
    return root


def fsync_file(path: Path) -> None:
    with path.open("rb") as handle:
        os.fsync(handle.fileno())


def fsync_dir(path: Path) -> None:
    fd = os.open(path, os.O_RDONLY)
    try:
        os.fsync(fd)
    finally:
        os.close(fd)


def ro_uri(path: Path) -> str:
    return "file:" + quote(path.as_posix(), safe="/:") + "?mode=ro"


def live_complete(root: Path) -> bool:
    return all((root / name).is_file() for name in LIVE_NAMES)


def discard_tree(path: Path) -> None:
    if path.exists():
        shutil.rmtree(path)


def recover(root: Path) -> None:
    """Drop an interrupted work copy. Restore the previous live map if a swap broke."""
    root.mkdir(parents=True, exist_ok=True)
    previous = root / "previous"
    staging = root / "staging"
    if live_complete(root):
        discard_tree(previous)
        discard_tree(staging)
        discard_tree(root / "work")
        return
    if all((previous / name).is_file() for name in LIVE_NAMES):
        for name in LIVE_NAMES:
            current = root / name
            if current.exists() or current.is_symlink():
                current.unlink()
        for name in LIVE_NAMES:
            os.replace(previous / name, root / name)
        discard_tree(previous)
    elif all((staging / name).is_file() for name in LIVE_NAMES) and not any(
        (root / name).exists() for name in LIVE_NAMES
    ):
        for name in LIVE_NAMES:
            os.replace(staging / name, root / name)
    discard_tree(staging)
    discard_tree(root / "work")
    if live_complete(root):
        discard_tree(previous)


def list_files(vault: Path) -> list[Path]:
    found: list[Path] = []
    for dirpath, dirnames, filenames in os.walk(vault, followlinks=False):
        dirnames[:] = sorted(name for name in dirnames if not name.startswith("."))
        for name in sorted(filenames):
            if name.startswith("."):
                continue
            path = Path(dirpath) / name
            if path.is_symlink() or not path.is_file():
                continue
            found.append(path)
    found.sort(key=lambda item: item.relative_to(vault).as_posix())
    return found


def file_hash(path: Path) -> tuple[str, float]:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest(), path.stat().st_mtime


def sanitize(text: str) -> str:
    cleaned = _SECRET.sub(" ", text)
    return cleaned.replace("\x00", " ")


def words_of(text: str) -> list[str]:
    tokens = []
    for word in _WORD.findall(text.lower()):
        if word in STOPWORDS:
            continue
        if len(word) >= 20 and any(ch.isdigit() for ch in word):
            continue
        tokens.append(word)
    return tokens


def extension_of(path: Path) -> str:
    suffix = path.suffix.lower().lstrip(".")
    return suffix


def read_plain(path: Path) -> str | None:
    try:
        text = path.read_text(encoding="utf-8-sig")
    except (OSError, UnicodeDecodeError):
        return None
    return text


def canvas_text(path: Path) -> str | None:
    raw = read_plain(path)
    if raw is None:
        return None
    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        return None
    cards: list[str] = []

    def walk(node: object) -> None:
        if isinstance(node, dict):
            value = node.get("text")
            if isinstance(value, str) and value.strip():
                cards.append(value)
            for child in node.values():
                walk(child)
        elif isinstance(node, list):
            for child in node:
                walk(child)

    walk(data)
    return "\n".join(cards)


def sniff_text(path: Path) -> str | None:
    try:
        sample = path.read_bytes()[:8192]
    except OSError:
        return None
    if b"\x00" in sample:
        return None
    return read_plain(path)


def parse_with_liteparse(path: Path, tessdata: Path) -> str:
    from liteparse import LiteParse

    parser = LiteParse(
        ocr_enabled=True,
        ocr_language="eng+deu",
        tessdata_path=str(tessdata),
        output_format="text",
        extract_images=False,
        quiet=True,
        num_workers=1,
    )
    sink = io.StringIO()
    with contextlib.redirect_stdout(sink):
        result = parser.parse(str(path))
    text = getattr(result, "text", "") or ""
    return str(text)


def extract(path: Path, tessdata: Path) -> tuple[str, str, str]:
    """Return status, detail, raw text. Office files are never parsed."""
    ext = extension_of(path)
    try:
        if ext in OFFICE:
            return "not_read", ext, ""
        if ext == "canvas":
            text = canvas_text(path)
        elif ext in PLAIN:
            text = read_plain(path)
        elif ext == "pdf" or ext in IMAGES:
            text = parse_with_liteparse(path, tessdata)
        else:
            text = sniff_text(path)
            ext = "text" if text is not None else ext
        if text is None or not text.strip():
            detail = "no text found" if ext not in OFFICE else ext
            if ext in OFFICE:
                return "not_read", ext, ""
            return "not_read", "no text found", ""
        detail = "md" if ext == "markdown" else ext
        if ext == "text" or detail == "":
            detail = "text"
        return "read", detail or "text", text
    except Exception:
        return "not_read", "other", ""


def bow(tokens: list[str]) -> dict[str, float]:
    counts: dict[str, float] = {}
    for token in tokens:
        counts[token] = counts.get(token, 0.0) + 1.0
    return counts


def bow_cosine(left: dict[str, float], right: dict[str, float]) -> float:
    if not left or not right:
        return 0.0
    dot = 0.0
    for key, value in left.items():
        other = right.get(key)
        if other:
            dot += value * other
    left_norm = math.sqrt(sum(value * value for value in left.values()))
    right_norm = math.sqrt(sum(value * value for value in right.values()))
    if left_norm == 0.0 or right_norm == 0.0:
        return 0.0
    return dot / (left_norm * right_norm)


def link_targets(text: str) -> list[str]:
    found = [match.group(1).strip() for match in _WIKI.finditer(text)]
    for match in _MD_LINK.finditer(text):
        target = match.group(1).strip()
        if target.startswith(("http://", "https://", "mailto:")):
            continue
        found.append(target)
    return found


def resolve_target(target: str, paths: set[str], stems: dict[str, list[str]]) -> str | None:
    raw = target.strip().replace("\\", "/")
    raw = raw.split("#", 1)[0].split("|", 1)[0].strip()
    if not raw or "://" in raw or raw.startswith("/"):
        return None
    options = [raw]
    if raw.endswith(".md"):
        options.append(raw[:-3])
    else:
        options.append(raw + ".md")
    for option in options:
        if option in paths:
            return option
    stem = Path(raw).stem.lower()
    hits = stems.get(stem, [])
    if len(hits) == 1:
        return hits[0]
    return None


def load_previous(root: Path) -> dict[str, dict[str, object]] | None:
    if not live_complete(root):
        return None
    uri = ro_uri(root / "map.sqlite")
    try:
        con = sqlite3.connect(uri, uri=True)
    except sqlite3.Error:
        return None
    try:
        rows = con.execute(
            "select path, content_hash, mtime, status, detail, body from manifest"
        ).fetchall()
        vectors: dict[str, bytes] = {}
        try:
            for path, blob in con.execute("select path, vector from embedding"):
                vectors[path] = blob
        except sqlite3.Error:
            vectors = {}
        topic_count = con.execute("select count(*) from topic").fetchone()[0]
    except sqlite3.Error:
        return None
    finally:
        con.close()
    previous: dict[str, dict[str, object]] = {}
    for path, content_hash, mtime, status, detail, body in rows:
        previous[path] = {
            "content_hash": content_hash,
            "mtime": mtime,
            "status": status,
            "detail": detail,
            "body": body or "",
            "vector": vectors.get(path),
            "topic_count": topic_count,
        }
    return previous


def embed_texts(model_path: Path, texts: list[str]) -> list[bytes]:
    import numpy as np
    from sentence_transformers import SentenceTransformer

    if not texts:
        return []
    sink = io.StringIO()
    with contextlib.redirect_stdout(sink):
        model = SentenceTransformer(str(model_path), local_files_only=True)
        prefixed = ["passage: " + text[:4000] for text in texts]
        matrix = model.encode(
            prefixed,
            normalize_embeddings=True,
            show_progress_bar=False,
            convert_to_numpy=True,
        )
    array = np.asarray(matrix, dtype=np.float32)
    if array.ndim == 1:
        array = array.reshape(1, -1)
    return [row.tobytes() for row in array]


def vector_dim(model_path: Path, blobs: list[bytes]) -> int:
    if blobs:
        return len(blobs[0]) // 4
    config = json.loads((model_path / "config.json").read_text(encoding="utf-8"))
    return int(config.get("hidden_size") or 384)


def write_hnsw(path: Path, blobs: list[bytes], dim: int) -> None:
    import hnswlib
    import numpy as np

    index = hnswlib.Index(space="cosine", dim=dim)
    index.init_index(max_elements=max(len(blobs), 1), ef_construction=200, M=16)
    if blobs:
        matrix = np.vstack(
            [np.frombuffer(blob, dtype=np.float32) for blob in blobs]
        ).astype(np.float32)
        norms = np.linalg.norm(matrix, axis=1, keepdims=True)
        norms[norms == 0] = 1.0
        matrix = matrix / norms
        index.add_items(matrix, np.arange(len(blobs)))
        index.set_ef(64)
    index.save_index(str(path))


def meaning_edges(
    paths: list[str], blobs: list[bytes], dim: int
) -> list[tuple[str, str, str, float]]:
    import hnswlib
    import numpy as np

    if len(blobs) < 2:
        return []
    matrix = np.vstack(
        [np.frombuffer(blob, dtype=np.float32) for blob in blobs]
    ).astype(np.float32)
    if matrix.shape[1] != dim:
        return []
    norms = np.linalg.norm(matrix, axis=1, keepdims=True)
    norms[norms == 0] = 1.0
    matrix = matrix / norms
    index = hnswlib.Index(space="cosine", dim=dim)
    index.init_index(max_elements=len(blobs), ef_construction=200, M=16)
    index.add_items(matrix, np.arange(len(blobs)))
    neighbors = min(10, len(blobs))
    index.set_ef(max(64, neighbors))
    labels, distances = index.knn_query(matrix, k=neighbors)
    edges = []
    seen: set[tuple[str, str]] = set()
    for row, (label_row, dist_row) in enumerate(zip(labels, distances)):
        for label, dist in zip(label_row, dist_row):
            other = int(label)
            if other == row or other < 0:
                continue
            similarity = 1.0 - float(dist)
            if similarity < _MEANING_MIN:
                continue
            left, right = paths[row], paths[other]
            if left > right:
                left, right = right, left
            key = (left, right)
            if key in seen:
                continue
            seen.add(key)
            edges.append((left, right, "meaning", similarity))
    return edges


def cluster(
    paths: list[str], file_edges: list[tuple[str, str, str, float]]
) -> tuple[list[tuple[int, int]], list[tuple[str, int]], list[tuple[int, int, str, float]]]:
    import igraph as ig
    import leidenalg

    count = len(paths)
    if count == 0:
        return [], [], []
    index = {path: pos for pos, path in enumerate(paths)}
    pair_weight: dict[tuple[int, int], float] = {}
    for source, target, _kind, weight in file_edges:
        left = index[source]
        right = index[target]
        if left == right:
            continue
        if left > right:
            left, right = right, left
        pair_weight[(left, right)] = pair_weight.get((left, right), 0.0) + float(weight)
    graph = ig.Graph(n=count, edges=list(pair_weight.keys()), directed=False)
    kwargs: dict[str, object] = {}
    if pair_weight:
        graph.es["weight"] = list(pair_weight.values())
        kwargs["weights"] = "weight"
    try:
        import inspect

        if "seed" in inspect.signature(leidenalg.find_partition).parameters:
            kwargs["seed"] = 42
    except (TypeError, ValueError):
        pass
    partition = leidenalg.find_partition(
        graph, leidenalg.ModularityVertexPartition, **kwargs
    )
    raw = list(partition.membership)
    renumber: dict[int, int] = {}
    membership_ids: list[int] = []
    for community in raw:
        if community not in renumber:
            renumber[community] = len(renumber)
        membership_ids.append(renumber[community])
    sizes: dict[int, int] = {}
    membership = []
    for path, topic_id in zip(paths, membership_ids):
        sizes[topic_id] = sizes.get(topic_id, 0) + 1
        membership.append((path, topic_id))
    topics = [(topic_id, sizes[topic_id]) for topic_id in sorted(sizes)]
    by_path = dict(membership)
    aggregated: dict[tuple[int, int, str], float] = {}
    for source, target, kind, weight in file_edges:
        left = by_path[source]
        right = by_path[target]
        if left == right:
            continue
        if left > right:
            left, right = right, left
        key = (left, right, kind)
        aggregated[key] = aggregated.get(key, 0.0) + float(weight)
    topic_edges = [
        (source, target, kind, weight)
        for (source, target, kind), weight in sorted(aggregated.items())
    ]
    return topics, membership, topic_edges


def open_work_db(path: Path) -> sqlite3.Connection:
    con = sqlite3.connect(path)
    con.execute("pragma journal_mode=delete")
    con.execute(
        """
        create table manifest (
            path text primary key,
            content_hash text not null,
            mtime real not null,
            status text not null,
            detail text not null,
            body text not null
        )
        """
    )
    con.execute(
        """
        create virtual table words using fts5(
            path unindexed,
            body,
            tokenize='unicode61 remove_diacritics 2'
        )
        """
    )
    con.execute(
        """
        create table embedding (
            path text primary key,
            label integer not null,
            vector blob not null
        )
        """
    )
    con.execute(
        """
        create table topic (
            topic_id integer primary key,
            size integer not null
        )
        """
    )
    con.execute(
        """
        create table membership (
            path text primary key,
            topic_id integer not null
        )
        """
    )
    con.execute(
        """
        create table file_edge (
            source_path text not null,
            target_path text not null,
            kind text not null,
            weight real not null
        )
        """
    )
    con.execute(
        """
        create table topic_edge (
            source_topic integer not null,
            target_topic integer not null,
            kind text not null,
            weight real not null
        )
        """
    )
    return con


def build_edges(
    records: list[dict[str, object]],
) -> list[tuple[str, str, str, float]]:
    paths = [str(record["path"]) for record in records]
    path_set = set(paths)
    stems: dict[str, list[str]] = {}
    for path in paths:
        stems.setdefault(Path(path).stem.lower(), []).append(path)
    edges: list[tuple[str, str, str, float]] = []
    seen_links: set[tuple[str, str]] = set()
    bows = []
    for record in records:
        body = str(record["body"])
        tokens = words_of(body)
        bows.append(bow(tokens))
        for target in link_targets(body):
            resolved = resolve_target(target, path_set, stems)
            if resolved is None or resolved == record["path"]:
                continue
            left, right = str(record["path"]), resolved
            if left > right:
                left, right = right, left
            key = (left, right)
            if key in seen_links:
                continue
            seen_links.add(key)
            edges.append((left, right, "link", 1.0))
    for i in range(len(records)):
        for j in range(i + 1, len(records)):
            shared = sum(1 for token in bows[i] if token in bows[j])
            if shared < 2:
                continue
            similarity = bow_cosine(bows[i], bows[j])
            if similarity < _WORD_MIN:
                continue
            left, right = paths[i], paths[j]
            if left > right:
                left, right = right, left
            edges.append((left, right, "word", similarity))
    return edges


def write_db(
    db_path: Path,
    hnsw_path: Path,
    records: list[dict[str, object]],
    model_path: Path,
) -> int:
    embed_rows = [record for record in records if str(record["body"]).strip()]
    missing = [record for record in embed_rows if not isinstance(record.get("vector"), (bytes, bytearray))]
    if missing:
        blobs = embed_texts(model_path, [str(record["body"]) for record in missing])
        for record, blob in zip(missing, blobs):
            record["vector"] = blob
    vector_rows = [record for record in embed_rows if isinstance(record.get("vector"), (bytes, bytearray))]
    blobs = [bytes(record["vector"]) for record in vector_rows]
    dim = vector_dim(model_path, blobs)
    write_hnsw(hnsw_path, blobs, dim)
    vector_paths = [str(record["path"]) for record in vector_rows]
    file_edges = build_edges(records)
    file_edges.extend(meaning_edges(vector_paths, blobs, dim))
    topics, membership, topic_edges = cluster(
        [str(record["path"]) for record in records], file_edges
    )
    con = open_work_db(db_path)
    try:
        con.executemany(
            "insert into manifest(path, content_hash, mtime, status, detail, body) values (?, ?, ?, ?, ?, ?)",
            [
                (
                    record["path"],
                    record["content_hash"],
                    record["mtime"],
                    record["status"],
                    record["detail"],
                    record["body"],
                )
                for record in records
            ],
        )
        con.executemany(
            "insert into words(path, body) values (?, ?)",
            [
                (record["path"], record["body"])
                for record in records
                if str(record["body"]).strip()
            ],
        )
        con.executemany(
            "insert into embedding(path, label, vector) values (?, ?, ?)",
            [
                (record["path"], label, record["vector"])
                for label, record in enumerate(vector_rows)
            ],
        )
        con.executemany("insert into topic(topic_id, size) values (?, ?)", topics)
        con.executemany(
            "insert into membership(path, topic_id) values (?, ?)", membership
        )
        con.executemany(
            "insert into file_edge(source_path, target_path, kind, weight) values (?, ?, ?, ?)",
            file_edges,
        )
        con.executemany(
            "insert into topic_edge(source_topic, target_topic, kind, weight) values (?, ?, ?, ?)",
            topic_edges,
        )
        con.commit()
    finally:
        con.close()
    return len(topics)


def count_check(db_path: Path, listed: list[str]) -> str | None:
    uri = ro_uri(db_path)
    con = sqlite3.connect(uri, uri=True)
    try:
        rows = [row[0] for row in con.execute("select path from manifest")]
    finally:
        con.close()
    if sorted(rows) != sorted(listed) or len(rows) != len(listed) or len(set(rows)) != len(rows):
        return (
            "count check failed: manifest has "
            f"{len(rows)} entries for {len(listed)} listed files."
        )
    return None


def summary_line(db_path: Path, changed: int) -> str:
    uri = ro_uri(db_path)
    con = sqlite3.connect(uri, uri=True)
    try:
        rows = con.execute("select status, detail from manifest").fetchall()
        topics = con.execute("select count(*) from topic").fetchone()[0]
    finally:
        con.close()
    mapped = 0
    office = 0
    no_text = 0
    other = 0
    for status, detail in rows:
        if status == "read":
            mapped += 1
            continue
        if detail in OFFICE:
            office += 1
        elif detail == "no text found":
            no_text += 1
        else:
            other += 1
    total = len(rows)
    not_read = total - mapped
    return (
        f"{total} files: {mapped} mapped, {not_read} not read: "
        f"{office} Office, {no_text} no text, {other} other. "
        f"{topics} topics, {changed} changed."
    )


def commit(root: Path, work: Path) -> None:
    staging = root / "staging"
    previous = root / "previous"
    discard_tree(staging)
    discard_tree(previous)
    for name in LIVE_NAMES:
        fsync_file(work / name)
    fsync_dir(work)
    os.rename(work, staging)
    previous.mkdir()
    moved: list[str] = []
    try:
        for name in LIVE_NAMES:
            current = root / name
            if current.exists() or current.is_symlink():
                os.rename(current, previous / name)
                moved.append(name)
        for name in ("map.sqlite", "vectors.hnsw"):
            os.rename(staging / name, root / name)
            fsync_file(root / name)
        os.rename(staging / "done", root / "done")
        fsync_file(root / "done")
        fsync_dir(root)
    except Exception:
        for name in LIVE_NAMES:
            current = root / name
            if name not in moved and (current.exists() or current.is_symlink()):
                current.unlink()
        for name in moved:
            os.replace(previous / name, root / name)
        raise
    discard_tree(previous)
    discard_tree(staging)


def fast_copy(root: Path, work: Path) -> None:
    shutil.copyfile(root / "map.sqlite", work / "map.sqlite")
    shutil.copyfile(root / "vectors.hnsw", work / "vectors.hnsw")


def collect_records(
    vault: Path,
    files: list[Path],
    previous: dict[str, dict[str, object]] | None,
    tessdata: Path,
) -> tuple[list[dict[str, object]], int]:
    previous = previous or {}
    old_paths = set(previous)
    new_paths = []
    records: list[dict[str, object]] = []
    added = 0
    modified = 0
    for path in files:
        rel = path.relative_to(vault).as_posix()
        new_paths.append(rel)
        try:
            content_hash, mtime = file_hash(path)
        except OSError:
            content_hash, mtime = "unreadable", 0.0
            records.append(
                {
                    "path": rel,
                    "content_hash": content_hash,
                    "mtime": mtime,
                    "status": "not_read",
                    "detail": "other",
                    "body": "",
                    "vector": None,
                }
            )
            if rel not in old_paths:
                added += 1
            elif previous[rel]["content_hash"] != content_hash:
                modified += 1
            continue
        old = previous.get(rel)
        if old is not None and old["content_hash"] == content_hash:
            records.append(
                {
                    "path": rel,
                    "content_hash": content_hash,
                    "mtime": old["mtime"],
                    "status": old["status"],
                    "detail": old["detail"],
                    "body": old["body"],
                    "vector": old["vector"],
                }
            )
            continue
        if old is None:
            added += 1
        else:
            modified += 1
        status, detail, raw = extract(path, tessdata)
        body = sanitize(raw) if status == "read" else ""
        records.append(
            {
                "path": rel,
                "content_hash": content_hash,
                "mtime": mtime,
                "status": status,
                "detail": detail,
                "body": body,
                "vector": None,
            }
        )
    removed = len(old_paths - set(new_paths))
    return records, added + modified + removed


def stamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ") + "\n"


def run(vault: Path, model_path: Path, tessdata: Path) -> None:
    root = vault / ".memory-map"
    recover(root)
    files = list_files(vault)
    listed = [path.relative_to(vault).as_posix() for path in files]
    previous = load_previous(root)
    records, changed = collect_records(vault, files, previous, tessdata)
    work = root / "work"
    discard_tree(work)
    work.mkdir(parents=True)
    try:
        unchanged = previous is not None and changed == 0 and live_complete(root)
        if unchanged:
            fast_copy(root, work)
        else:
            write_db(
                work / "map.sqlite",
                work / "vectors.hnsw",
                records,
                model_path,
            )
        (work / "done").write_text(stamp(), encoding="utf-8")
        problem = count_check(work / "map.sqlite", listed)
        if problem:
            discard_tree(work)
            stop(problem)
        line = summary_line(work / "map.sqlite", changed)
        commit(root, work)
    except SystemExit:
        discard_tree(root / "work")
        raise
    except Exception:
        import traceback

        traceback.print_exc()
        discard_tree(root / "work")
        stop("the build failed.")
    print(line)


def main(argv: list[str]) -> None:
    os.environ["HF_HUB_OFFLINE"] = "1"
    os.environ["TRANSFORMERS_OFFLINE"] = "1"
    os.environ["HF_DATASETS_OFFLINE"] = "1"
    os.environ["HF_HUB_DISABLE_TELEMETRY"] = "1"
    vault = parse_vault(argv)
    check_seed(vault)
    check_python()
    prepare_runtime(vault)
    check_libraries()
    check_fts5()
    model_path = check_model()
    tessdata = check_tessdata()
    run(vault, model_path, tessdata)


if __name__ == "__main__":
    main(sys.argv)
