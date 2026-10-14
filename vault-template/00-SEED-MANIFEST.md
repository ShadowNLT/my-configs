# Vault template — keep-layout seed

Source-of-truth seed for a DigitalBrain vault's keep layout. The files here are meta stubs:
empty scaffolds filled in after seeding, written in vault-relative language. Nothing in
them is a harness substitution token.

Two placeholders are supplied at seed time, not stored in the files:

| Placeholder | Meaning |
|---|---|
| `KNOWLEDGE_VAULT_ROOT` | Absolute path of the vault to seed |
| `COMPANY_NAME` | Directory name the `Company/` template maps onto |

## What gets seeded

Paths under this directory mirror the vault. `Company/` is renamed to `$COMPANY_NAME/` on the
way out. `00-SEED-MANIFEST.md` is never copied.

| Path in this package | Destination | Role |
|---|---|---|
| `README.md` | `README.md` | Vault conventions, folder map, legacy rule |
| `Company/README.md` | `$COMPANY_NAME/README.md` | Company knowledge root, copied when `$COMPANY_NAME/README.md` is missing |
| `Agent/README.md` | `Agent/README.md` | Agent corner: Patterns, Feedback, Dreams, INDEX |
| `Agent/INDEX.md` | `Agent/INDEX.md` | Empty pattern index |
| `Agent/Feedback.md` | `Agent/Feedback.md` | Standing behavioral rules (stub) |
| `Agent/Patterns/.gitkeep` | `Agent/Patterns/.gitkeep` | Keeps `Agent/Patterns/`; copied when that file is missing |
| `Agent/Dreams/.gitkeep` | `Agent/Dreams/.gitkeep` | Keeps `Agent/Dreams/`; copied when that file is missing |
| `Parking-Lot/README.md` | `Parking-Lot/README.md` | Deferred-item schema |
| `Parking-Lot/INDEX.md` | `Parking-Lot/INDEX.md` | Empty parking index |
| `Ships/README.md` | `Ships/README.md` | Runtime layout for `work.md` and `learning.md` |

Shape after seeding. `legacy/` is present only when the confirmed move had something to move:

```
<KNOWLEDGE_VAULT_ROOT>/
  README.md
  .seed-state
  <COMPANY_NAME>/
  Agent/
  Parking-Lot/
  Ships/
  legacy/
```

## Explicitly out of scope

- Sample `Ships/<ship_uid>-<slug>/` directories. Ships are runtime notes; this package does not create them.
- Filled company notes, pattern files, or parking items. Meta and stubs only.
- Harness commands that create or update Ships. Those are a separate pass; see below.
- `corporate/vault-seed/`. That older package stays as it is. New vault seed work lives here.

## Legacy rule

- **Seeded canon** means the root `README.md`, `.seed-state`, the company folder, `Agent/`, `Parking-Lot/` and `Ships/`. Everything else in the vault is **legacy**.
- **Crawlable** means it may be read and searched. The whole vault is crawlable, legacy folders and files included.
- **Write** means create, edit, delete, rename or move. Writes go only into seeded canon.
- Protocols may restrict writes further, and the narrower rule wins.
- Seeded canon may reference any crawlable content by link or path. Naming or quoting legacy content inside canon is allowed too.
- Legacy never references seeded canon, because that would mean editing legacy.
- If the vault doesn't fit these rules, report the conflict to the operator. The operator handles cleanup.

Seeding moves pre-existing content into `legacy/` exactly once, after a dry run the operator confirms, and never deletes.

## Seed policy

Ask the operator for `KNOWLEDGE_VAULT_ROOT` and `COMPANY_NAME`. Echo both and confirm before running. Nothing is ever deleted.

`.seed-state` lives at the vault root. The first line is `status: pending` or `status: done`. Each later line is one top-level name from the confirmed move list.

- Before the dry run, trim `COMPANY_NAME` and use that trimmed name from then on. Reject it, print the reason, and read another name, changing nothing, when it is empty (whitespace only counts as empty), `.` or `..`, contains `/`, or matches `legacy`, `Agent`, `Parking-Lot`, `Ships`, `README.md`, or `.seed-state` in any capitalization. Empty: `Company name can't be empty. Enter a different company name:`. `.` or `..`: `<name> isn't a valid folder name. Enter a different company name:`. A slash: `Company names can't contain /. Enter a different company name:`. A reserved name: `<name> is reserved for the vault layout. Enter a different company name:`.
- If `legacy/` already exists and `.seed-state` does not, stop. Print exactly: `Seed stopped: `legacy/` already exists in this vault. Rename or move it, then run the seed again. Nothing was changed.`
- First seed (no `.seed-state`): dry run, then ask `Move these into `legacy/`? (yes/no)`. The answer ignores case and surrounding spaces, so `yes`, `YES`, `Yes`, and ` yes ` all continue. Anything else (`no`, a blank line, `y`, `yeah`) changes nothing. On yes, write the confirmed list to `.seed-state` with `status: pending` before any move. Then move every listed top-level item into `legacy/`. That list is everything that was already in the vault: an old company folder, `Agent/`, `README.md`, hidden files, and every other top-level name. Only `.seed-state` itself is excluded. Then copy the template. Then set `.seed-state` to `status: done`.
- The dry run prints how many folders and files would move, one line per top-level item (`Work/` -> `legacy/Work/`), and how many path links would break. A path link is a wikilink that contains a slash (`[[Work/x]]`) or a relative climb (`../y.md`). When a top-level folder named exactly `$COMPANY_NAME` is already in the vault, the dry run also prints `` `<COMPANY_NAME>/` moves to `legacy/<COMPANY_NAME>/`, and a new `<COMPANY_NAME>/` with only the template files is created. `` with that name substituted. It does not print that line when the folder is absent.
- Unfinished `.seed-state` (`status: pending`): move names still on that list and still at the vault root. Move nothing that is not on the list. Then copy missing template files and mark `.seed-state` done. Do not ask again.
- Finished `.seed-state` (`status: done`): copy missing template files only. Do not move.

Template copy, used after the move and on every later run:

- `Company/<file>` maps to `$COMPANY_NAME/<file>`.
- `00-SEED-MANIFEST.md` is not copied.
- If the destination path already exists, skip it. Never overwrite.
- Vault files are copied as plain text. The seed performs no token substitution on them.

## Seed command

Run from the repo root after `KNOWLEDGE_VAULT_ROOT` and `COMPANY_NAME` are set and confirmed. An invalid company name is printed and read again before anything else. On a first seed the command then reads the dry-run answer. `yes` continues after case and surrounding spaces are ignored. Anything else stops and changes nothing.

```bash
if [ -z "${KNOWLEDGE_VAULT_ROOT:-}" ]; then
  echo "Set KNOWLEDGE_VAULT_ROOT and COMPANY_NAME before seeding." >&2
  exit 1
fi

src="$(pwd)/vault-template"
dst="$KNOWLEDGE_VAULT_ROOT"
company="${COMPANY_NAME:-}"
state="$dst/.seed-state"

if [ ! -d "$dst" ]; then
  echo "Seed stopped: KNOWLEDGE_VAULT_ROOT is not a directory. Nothing was changed." >&2
  exit 1
fi

company="$(printf '%s' "$company" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
while true; do
  company_key="$(printf '%s' "$company" | tr '[:upper:]' '[:lower:]')"
  if [ -z "$company" ]; then
    printf 'Company name can'\''t be empty. Enter a different company name:\n'
  elif [ "$company" = "." ] || [ "$company" = ".." ]; then
    printf '%s isn'\''t a valid folder name. Enter a different company name:\n' "$company"
  elif case "$company" in */*) true ;; *) false ;; esac; then
    printf 'Company names can'\''t contain /. Enter a different company name:\n'
  elif [ "$company_key" = "legacy" ] || [ "$company_key" = "agent" ] || [ "$company_key" = "parking-lot" ] || [ "$company_key" = "ships" ] || [ "$company_key" = "readme.md" ] || [ "$company_key" = ".seed-state" ]; then
    printf '%s is reserved for the vault layout. Enter a different company name:\n' "$company"
  else
    break
  fi
  read -r company || exit 1
  company="$(printf '%s' "$company" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
done

copy_template() {
  while IFS= read -r -d '' f; do
    rel="${f#"$src"/}"
    case "$rel" in
      00-SEED-MANIFEST.md) continue ;;
    esac
    dest_rel="$rel"
    case "$rel" in
      Company/*) dest_rel="${company}/${rel#Company/}" ;;
    esac
    target="$dst/$dest_rel"
    if [ -e "$target" ]; then
      echo "skip (exists): $dest_rel"
      continue
    fi
    mkdir -p "$(dirname "$target")"
    cp "$f" "$target"
    echo "seeded: $dest_rel"
  done < <(find "$src" -type f ! -name '00-SEED-MANIFEST.md' -print0)
}

mark_done() {
  tmp="$(mktemp)"
  {
    echo "status: done"
    tail -n +2 "$state"
  } > "$tmp"
  mv "$tmp" "$state"
  echo "seed state: done"
}

move_listed() {
  while IFS= read -r name || [ -n "$name" ]; do
    [ -z "$name" ] && continue
    if [ -e "$dst/$name" ]; then
      mkdir -p "$dst/legacy"
      mv "$dst/$name" "$dst/legacy/$name"
      echo "moved: $name -> legacy/$name"
    elif [ -e "$dst/legacy/$name" ]; then
      echo "already moved: $name"
    else
      echo "Seed conflict: $name is on the confirmed list but is not in the vault or in legacy/. Report this to the operator." >&2
      exit 1
    fi
  done < <(tail -n +2 "$state")
}

if [ -e "$dst/legacy" ] && [ ! -f "$state" ]; then
  printf 'Seed stopped: `legacy/` already exists in this vault. Rename or move it, then run the seed again. Nothing was changed.\n'
  exit 1
fi

if [ -f "$state" ]; then
  status="$(head -n 1 "$state")"
  case "$status" in
    "status: done")
      copy_template
      exit 0
      ;;
    "status: pending")
      move_listed
      copy_template
      mark_done
      exit 0
      ;;
    *)
      echo "Seed conflict: .seed-state is not a pending or done list. Report this to the operator. Nothing was changed." >&2
      exit 1
      ;;
  esac
fi

names=()
while IFS= read -r name; do
  [ -z "$name" ] && continue
  names+=("$name")
done < <(find "$dst" -mindepth 1 -maxdepth 1 -print | sed 's|.*/||' | LC_ALL=C sort)

folder_count="$(find "$dst" -mindepth 1 -type d | wc -l | tr -d ' ')"
file_count="$(find "$dst" -mindepth 1 -type f | wc -l | tr -d ' ')"
link_count=0
while IFS= read -r -d '' f; do
  hits="$(grep -a -o -E '\[\[[^][]*/[^][]*\]\]|\.\./[^[:space:]()<>]+' "$f" 2>/dev/null || true)"
  if [ -n "$hits" ]; then
    link_count=$((link_count + $(printf '%s\n' "$hits" | grep -c .)))
  fi
done < <(find "$dst" -type f -print0)

echo "Would move ${folder_count} folders and ${file_count} files."
for name in "${names[@]}"; do
  if [ -d "$dst/$name" ]; then
    echo "$name/ -> legacy/$name/"
  else
    echo "$name -> legacy/$name"
  fi
done
echo "Path links that would break: ${link_count}"
if [ -d "$dst/$company" ]; then
  printf '`%s/` moves to `legacy/%s/`, and a new `%s/` with only the template files is created.\n' "$company" "$company" "$company"
fi
printf 'Move these into `legacy/`? (yes/no)\n'
read -r reply || reply=""
reply="$(printf '%s' "$reply" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')"
if [ "$reply" != "yes" ]; then
  echo "Nothing was changed."
  exit 0
fi

{
  echo "status: pending"
  if [ "${#names[@]}" -gt 0 ]; then
    printf '%s\n' "${names[@]}"
  fi
} > "$state"

move_listed
copy_template
mark_done
```

## Relationship to harness seed

Harness seed (see `corporate/README.md`) installs commands and agent files. This package installs
vault meta docs only. The two passes are independent. Future harness commands will create and
update `Ships/<ship_uid>-<slug>/` notes; this seed does not install or define those commands.
