---
description: >-
  Map the whole vault into topics and indexes so retrieval is fast. It is
  standalone. It takes no input.
argument-hint: "[none. This protocol takes no input.]"
---

# memory-map

A standalone protocol.

Knowledge vault root: `{{KNOWLEDGE_VAULT_ROOT}}`

Python: `{{MEMORY_MAP_PYTHON}}`

`memory_map.py` in this folder carries out every step below. Resolve this
folder per `protocols/README.md`: this folder in the repo, the skill folder
after a skill install, or the command-form sidecar `$CONFIG_DIR/memory-map/`
after a command install. Pass the knowledge vault root above to the script
as its required vault-path argument:

`{{MEMORY_MAP_PYTHON}} memory_map.py "{{KNOWLEDGE_VAULT_ROOT}}"`

The operator types nothing. The one-time install is `install.sh` in this
same folder. A run never goes online.

---

## 1. Parse arguments

`$ARGUMENTS` is empty. The operator types nothing.

| Token | Default | Meaning |
|---|---|---|
| (none) | none | `$ARGUMENTS` is empty. This protocol takes no input. |

---

## 2. Start check

The script stops with one reason line naming whatever is missing. It checks:

- `.seed-state` at `{{KNOWLEDGE_VAULT_ROOT}}` says done.
- Python 3.10 or newer.
- The pinned libraries are installed.
- SQLite has FTS5.
- The `multilingual-e5-small` model files are stored locally.
- The English and German OCR language files are in the local folder that
  `TESSDATA_PREFIX` points to.

---

## 3. List

It lists every file in the vault, including `legacy/` and `Ships/`. It skips
only its own corner (`.memory-map/`) and the metadata, meaning every
dot-folder and dot-file. The start check's read of `.seed-state` is the only
dot-file read.

---

## 4. Read

`.md` files and plain text are read directly, and `.canvas` files give their
card text. `.csv` and `.tsv` files are read directly as plain text, like
`.md`. LiteParse never opens them. PDFs and images go through LiteParse, with
OCR for scans and images. Word, PowerPoint, and spreadsheet files other than
`.csv` and `.tsv` are listed as not read with their type. LiteParse never
opens them, so LibreOffice is never needed. A file that gives no text, such
as handwriting or an empty scan, is listed as not read with the reason
"no text found".

---

## 5. Build

The script builds the new map on the side, in a work folder inside
`.memory-map/`, and leaves the live map untouched.

- **Manifest:** each file's path, content hash, modified time, and its read
  or not-read status, with type or reason, in `map.sqlite`.
- **Word index:** SQLite FTS5 with BM25 ranking, in `map.sqlite`. Strings
  that look like keys or tokens are dropped.
- **Meaning index:** `multilingual-e5-small` embeddings run locally, searched
  with `hnswlib`, in `vectors.hnsw`.
- **Topic graph:** each node is a topic and each file belongs to a node.
  Edges come from note links and word or meaning similarity. Topics are found
  with Leiden clustering through `python-igraph` and `leidenalg`, stored in
  `map.sqlite`.

---

## 6. Update

Files whose hash has not changed keep their entries. New and changed files
are read again. Deleted files are removed. The topic graph is re-clustered
only when files were added, changed, or removed since the last run.
Otherwise the graph stays exactly as it was.

---

## 7. Count check

The work copy's manifest must have exactly one entry for every listed file.
If not, the script stops, the work copy is thrown away, and the live map
stays as it was.

---

## 8. Commit

Once the count check passes, the work copy replaces the live map in one
swap. The live files are `.memory-map/map.sqlite`, `.memory-map/vectors.hnsw`,
and a done marker `.memory-map/done` that records the run time. An
interrupted run never leaves a half-built map live.

---

## 9. Return

A successful run ends with one summary line, for example
"415 files: 401 mapped, 14 not read: 9 Office, 3 no text, 2 other. 37 topics, 4 changed."
A stop ends with one reason line instead.

---

## Facts

- An inverted-index lookup reads only the posting lists for the query's
  words, not every file. Cost grows with how many files contain those words
  (Introduction to Information Retrieval, ch. 1).
- Leiden is proven to give connected communities. Louvain does not guarantee
  that (Traag et al. 2019).
- HNSW scaling roughly logarithmically was observed in benchmarks, not proven
  (Malkov & Yashunin 2018).
- No structure here is proven to be the fastest possible. These are standard
  choices with known costs.
- LiteParse's OCR does not read handwriting (LiteParse's own benchmark notes).

---

## Out of scope

- the vault-research edit
- fast mode
- dream

---

## Fixed points

- It writes only inside `.memory-map/` and is forbidden to write anywhere
  else in the vault.
- It never reads `.obsidian/` or any other dot-folder or dot-file, except
  the start check reads `.seed-state` at the vault root.
- No credentials or account details go into the map or the logs. The word
  index drops strings that look like keys or tokens.
- A run never goes online. The model and the OCR language files are loaded
  only from local folders, with `TESSDATA_PREFIX` set, so OCR never
  downloads anything. Downloads happen only in the one-time install step.
- It never hardcodes the operator. The vault path is the knowledge vault
  root named above, passed as the script's required argument. There is
  no default path.
