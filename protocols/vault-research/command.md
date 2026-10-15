---
description: >-
  Find something in the vault with two independent reads. The operator can
  run it directly, and other protocols can call it too. The goal or question
  is required. The Ship folder is optional, only when a protocol hands one
  over.
argument-hint: [the goal or question, required. Optional line "Ship folder: <absolute path>", only when a protocol hands one over.]
---

# vault-research

A standalone protocol. The operator can run it directly to find something
in the vault, and other protocols can call it too.

Knowledge vault root: `{{KNOWLEDGE_VAULT_ROOT}}`

`seed_state.py` is in this folder. Resolve this folder per `protocols/README.md`:
this folder in the repo, the skill folder after a skill install, or the
command-form sidecar `$CONFIG_DIR/vault-research/` after a command install.
The one-time install is `install.sh` in this same folder. It stops, and
installs nothing for that harness, when the path it is given is not a seeded
vault.

---

## 1. Parse arguments

`$ARGUMENTS` is the goal or question. The goal or question is required. The
Ship folder is optional, and only when a protocol hands one over. If
`$ARGUMENTS` has a line `Ship folder: <absolute path>`, that line is the Ship
folder; the rest is the goal or question.

| Token | Default | Meaning |
|---|---|---|
| goal or question | required | What to find in the vault. |
| Ship folder | optional | Only when a protocol hands one over, as one line `Ship folder: <absolute path>`. |

---

## 2. Start check

At the start, in this order:

1. If the knowledge vault root above is still the unfilled placeholder
   (double braces), stop: "Vault research stopped: install has not run for
   this harness."
2. Run `python3 seed_state.py "{{KNOWLEDGE_VAULT_ROOT}}"` from this folder.
   This is the same check install runs. If it stops, show its one reason line
   and tell the operator to run the seed first.
3. If a Ship folder was handed over, it must be an absolute path to a folder
   that exists directly under `{{KNOWLEDGE_VAULT_ROOT}}/Ships/` after symlinks
   are resolved. If not, stop with one reason line, for example "Vault
   research stopped: Ship folder is not an absolute path." or "Vault research
   stopped: Ship folder does not exist." or "Vault research stopped: Ship
   folder is not in this vault's Ships/."

These checks run before any file is listed or read.

---

## 3. List

It lists every file under `{{KNOWLEDGE_VAULT_ROOT}}`, including `legacy/`. It skips every
dot-folder and dot-file. On a rerun it also skips this Ship's own earlier
`findings.md`.

---

## 4. First read

Each file gets one verdict: related (with the reason and the passage), not
related, or not read (with the type). Text means `.md`, plain text, and the
card text in `.canvas` files. PDFs and other non-text files are marked not
read.

---

## 5. First count check

The number of verdicts must equal the number of files. If not, it stops.

---

## 6. Second read

A second reader starts from a fresh context. It gets the goal and the "not
related" files, but never the first read's verdicts or reasons. It reads
the files in its own random order.

---

## 7. Second count check

Every "not related" file must get a verdict. If not, it stops.

---

## 8. Disagreements

Any file the readers disagree on counts as related.

---

## 9. Write

With a Ship folder (checked in §2), it writes `<Ship folder>/findings.md`,
which is `Ships/<ship>/findings.md` in the vault, and a rerun rewrites the
whole file. Without a Ship folder, it writes nothing.

---

## 10. Return

When a protocol called it and it succeeds, it hands control back and the
operator sees nothing.

When the operator ran it directly, it shows the related files, each with
its reason and passage. It always ends with one coverage line, even when
nothing is related, for example
"415 files: 403 read, 3 related. 12 not read: 11 PDF, 1 image."

When it stops, the operator always gets one reason line, for example
"Vault research stopped: second reader gave 412 verdicts for 415 files."
A calling protocol shows that line and doesn't go on.

---

## Facts

Two independent reads cut misses by the second reader's miss rate. The 10%
miss rate is an assumption, not a measurement. Misses never reach zero.
Every run makes about two full passes over the vault.

---

## Estimate

Not measured: on a big vault, a run could take minutes.

---

## Out of scope

- start-task
- resume-task's rerun
- the ship-goal edit
- memory-map

---

## Fixed points

- It writes only `findings.md` in a Ship folder it was given and never
  touches any other vault file.
- It never hardcodes the operator or a vault path. The vault path is the
  knowledge vault root filled in at install, and it runs only on a seeded
  vault.
- It never reads `.obsidian/` or any other place that can hold tokens.
- No credentials or account details go into findings, logs or screenshots.
