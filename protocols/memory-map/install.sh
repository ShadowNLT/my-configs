#!/bin/sh
# One-time install for memory-map. Asks for a seeded vault, then fills
# {{KNOWLEDGE_VAULT_ROOT}} and {{MEMORY_MAP_PYTHON}} only in the copy
# installed for the harness. The seed check is seed_state.py, before the
# virtual environment exists.
# Downloads and library installs happen after the seed check passes.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")" && pwd)

fail() {
  printf '%s\n' "Memory map stopped: $1"
  exit 1
}

ask() {
  printf '%s' "$1" >&2
  IFS= read -r REPLY || REPLY=
  printf '%s' "$REPLY"
}

if [ "$#" -eq 3 ]; then
  VAULT=$1
  CONFIG_DIR=$2
  COMMANDS_DIR=$3
elif [ "$#" -eq 0 ]; then
  VAULT=$(ask "Seeded vault path: ")
  CONFIG_DIR=
  COMMANDS_DIR=
else
  fail "install needs the vault path, CONFIG_DIR, and COMMANDS_DIR."
fi

if [ -z "$VAULT" ] || [ ! -d "$VAULT" ]; then
  fail "vault path is not a directory."
fi
VAULT=$(CDPATH= cd -- "$VAULT" && pwd)

python3 "$ROOT/seed_state.py" "$VAULT"

if [ -z "$CONFIG_DIR" ]; then
  CONFIG_DIR=$(ask "CONFIG_DIR: ")
fi
if [ -z "$COMMANDS_DIR" ]; then
  COMMANDS_DIR=$(ask "COMMANDS_DIR: ")
fi
if [ -z "$CONFIG_DIR" ] || [ -z "$COMMANDS_DIR" ]; then
  fail "CONFIG_DIR or COMMANDS_DIR is missing."
fi

case "$CONFIG_DIR" in
  /*) ;;
  *) fail "CONFIG_DIR is not an absolute path." ;;
esac
case "$COMMANDS_DIR" in
  /*) ;;
  *) fail "COMMANDS_DIR is not an absolute path." ;;
esac
case "$CONFIG_DIR" in
  "$ROOT"|"$ROOT"/*) fail "install destination is the protocol source." ;;
esac
case "$COMMANDS_DIR" in
  "$ROOT"|"$ROOT"/*) fail "install destination is the protocol source." ;;
esac

if ! python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)'; then
  fail "Python 3.10 or newer is missing."
fi

BASE=${XDG_DATA_HOME:-$HOME/.local/share}
mkdir -p "$BASE"
BASE=$(CDPATH= cd -- "$BASE" && pwd)
DATA_HOME=$BASE/memory-map
VENV=$DATA_HOME/venv
mkdir -p "$DATA_HOME"
if [ ! -x "$VENV/bin/python" ]; then
  if ! python3 -m venv "$VENV"; then
    fail "Python virtual environment could not be created."
  fi
fi
PY=$VENV/bin/python

if ! "$PY" -m pip install -r "$ROOT/requirements.txt" >&2; then
  fail "pinned libraries are not installed."
fi

MODEL_DIR="${MEMORY_MAP_MODEL_DIR:-$DATA_HOME/models/multilingual-e5-small}"
if [ -n "${TESSDATA_PREFIX:-}" ]; then
  TESS=$TESSDATA_PREFIX
else
  TESS=$DATA_HOME/tessdata
fi
mkdir -p "$MODEL_DIR" "$TESS"

fetch() {
  url=$1
  dest=$2
  if [ -f "$dest" ] && [ "$(wc -c < "$dest" | tr -d ' ')" -ge 1000000 ]; then
    return 0
  fi
  tmp=$dest.partial
  if ! curl -fsSL "$url" -o "$tmp"; then
    rm -f "$tmp"
    return 1
  fi
  mv "$tmp" "$dest"
}

if ! fetch "https://github.com/tesseract-ocr/tessdata_best/raw/main/eng.traineddata" "$TESS/eng.traineddata"; then
  fail "English OCR language file is missing."
fi
if ! fetch "https://github.com/tesseract-ocr/tessdata_best/raw/main/deu.traineddata" "$TESS/deu.traineddata"; then
  fail "German OCR language file is missing."
fi

if ! MEMORY_MAP_MODEL_DIR="$MODEL_DIR" "$PY" - "$MODEL_DIR" <<'PY' >&2
import sys
from pathlib import Path
from huggingface_hub import snapshot_download

dest = Path(sys.argv[1])
dest.mkdir(parents=True, exist_ok=True)
weights = list(dest.glob("*.safetensors")) or (
    [dest / "pytorch_model.bin"] if (dest / "pytorch_model.bin").is_file() else []
)
ready = (
    (dest / "modules.json").is_file()
    and (dest / "config.json").is_file()
    and ((dest / "tokenizer.json").is_file() or (dest / "vocab.txt").is_file())
    and bool(weights)
)
if not ready:
    snapshot_download(
        repo_id="intfloat/multilingual-e5-small",
        local_dir=str(dest),
        allow_patterns=[
            "config.json",
            "config_sentence_transformers.json",
            "modules.json",
            "sentence_bert_config.json",
            "special_tokens_map.json",
            "tokenizer.json",
            "tokenizer_config.json",
            "sentencepiece.bpe.model",
            "vocab.txt",
            "model.safetensors",
            "1_Pooling/*",
            "2_Normalize/*",
        ],
    )
PY
then
  fail "multilingual-e5-small model files are missing."
fi

"$PY" - "$VAULT" "$CONFIG_DIR" "$COMMANDS_DIR" "$ROOT" "$PY" <<'PY'
import pathlib
import shutil
import sys

vault, config_dir, commands_dir, root, python_bin = sys.argv[1:]
root_path = pathlib.Path(root)
config = pathlib.Path(config_dir)
commands = pathlib.Path(commands_dir)
sidecar = config / "memory-map"
sidecar.mkdir(parents=True, exist_ok=True)
commands.mkdir(parents=True, exist_ok=True)

def place(src: pathlib.Path, dest: pathlib.Path, fill: bool) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    text = src.read_text(encoding="utf-8")
    if fill:
        text = text.replace("{{KNOWLEDGE_VAULT_ROOT}}", vault)
        text = text.replace("{{MEMORY_MAP_PYTHON}}", python_bin)
    dest.write_text(text, encoding="utf-8")

place(root_path / "command.md", commands / "memory-map.md", True)
place(root_path / "command.md", sidecar / "command.md", True)
place(root_path / "SKILL.md", sidecar / "SKILL.md", True)
for name in ("memory_map.py", "seed_state.py", "requirements.txt", "install.sh"):
    shutil.copy2(root_path / name, sidecar / name)
installed = sidecar / "install.sh"
installed.chmod(installed.stat().st_mode | 0o111)
PY

printf '%s\n' "Memory map install done."
