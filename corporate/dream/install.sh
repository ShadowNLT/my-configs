#!/bin/sh
# One-time install for dream. Asks for a seeded vault, then fills
# {{KNOWLEDGE_VAULT_ROOT}} only in the copy installed for the harness.
# The seed check is seed_state.py. Nothing is written unless it passes.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")" && pwd)

fail() {
  printf '%s\n' "Dream stopped: $1"
  exit 1
}

ask() {
  printf '%s' "$1" >&2
  IFS= read -r REPLY || REPLY=
  printf '%s' "$REPLY"
}

if [ "$#" -eq 3 ]; then
  VAULT=$1; CONFIG_DIR=$2; COMMANDS_DIR=$3
elif [ "$#" -eq 0 ]; then
  VAULT=$(ask "Seeded vault path: ")   # only the vault path here; the other two are asked after the seed check
  CONFIG_DIR=
  COMMANDS_DIR=
else
  fail "install needs the vault path, CONFIG_DIR, and COMMANDS_DIR."
fi

if [ -z "$VAULT" ] || [ ! -d "$VAULT" ]; then
  fail "vault path is not a directory."
fi
VAULT=$(CDPATH= cd -- "$VAULT" && pwd)

python3 "$ROOT/seed_state.py" "$VAULT"   # exits 1 with one reason line unless .seed-state says done

# Asked only after the vault passed the seed check (same order as memory-map install.sh:39-46).
if [ -z "$CONFIG_DIR" ]; then
  CONFIG_DIR=$(ask "CONFIG_DIR: ")
fi
if [ -z "$COMMANDS_DIR" ]; then
  COMMANDS_DIR=$(ask "COMMANDS_DIR: ")
fi

if [ -z "$CONFIG_DIR" ] || [ -z "$COMMANDS_DIR" ]; then
  fail "CONFIG_DIR or COMMANDS_DIR is missing."
fi
case "$CONFIG_DIR" in /*) ;; *) fail "CONFIG_DIR is not an absolute path." ;; esac
case "$COMMANDS_DIR" in /*) ;; *) fail "COMMANDS_DIR is not an absolute path." ;; esac
case "$CONFIG_DIR" in "$ROOT"|"$ROOT"/*) fail "install destination is the protocol source." ;; esac
case "$COMMANDS_DIR" in "$ROOT"|"$ROOT"/*) fail "install destination is the protocol source." ;; esac

python3 - "$VAULT" "$CONFIG_DIR" "$COMMANDS_DIR" "$ROOT" <<'PY'
import pathlib, shutil, sys
vault, config_dir, commands_dir, root = sys.argv[1:]
root_path = pathlib.Path(root)
sidecar = pathlib.Path(config_dir) / "dream"
commands = pathlib.Path(commands_dir)
sidecar.mkdir(parents=True, exist_ok=True)
commands.mkdir(parents=True, exist_ok=True)

def place(src, dest):
    text = src.read_text(encoding="utf-8").replace("{{KNOWLEDGE_VAULT_ROOT}}", vault)
    dest.write_text(text, encoding="utf-8")

place(root_path / "command.md", commands / "dream.md")
place(root_path / "command.md", sidecar / "command.md")
for name in ("seed_state.py", "install.sh"):
    shutil.copy2(root_path / name, sidecar / name)
installed = sidecar / "install.sh"
installed.chmod(installed.stat().st_mode | 0o111)
PY

printf '%s\n' "Dream install done."
