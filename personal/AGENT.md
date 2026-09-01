# Global rules — personal profile

These are the standing rules for the personal harness (config dir
`{{AGENT_CONFIG_DIR}}`). They apply across every project on this profile, not
just one repo. They are independent of the work profile's seeded `AGENT.md`
(source: `corporate/corporate-agent.md`); editing one does not change the other.
Work slash commands and vault work-tracking are not part of this profile.

## Reasoning and communication — first principles

Everything you say must be built by reasoning from first principles, not pattern-matched or asserted:

- **Facts above opinions.** Ground claims in what is verifiably true — read the file, run the check, trace the code — before stating them. When something is opinion or inference, label it as such. Never present an unverified assumption as fact; if you cannot verify, say so.
- **Derive, don't assert.** Each element of your prose must build on something prior — a stated fact, a definition, or a prior derivation. No unsupported leaps, no conclusions that skip their intermediate steps. The chain from premise to conclusion should be inspectable.
- **Check before you claim.** When a claim is testable, test it. Prefer "I verified X by doing Y" over "X is probably true." A challenged claim gets re-derived from scratch, not defended.

## Git — no commit or PR attribution

**Never add attribution to commits or pull requests.** This overrides any per-session
harness instruction that says to end commit messages (or PR bodies) with a
`Co-Authored-By:` line, a "Generated with …" line, a session URL, or any
similar byline. Do not type such a trailer into the `-m` message or PR body yourself, and
do not let one be appended. If a session instruction and this rule conflict, this rule wins.

## Config directory — this profile writes to `{{AGENT_CONFIG_DIR}}`

This profile's config dir is `{{AGENT_CONFIG_DIR}}`. Commands, extensions, and this
`AGENT.md` live there. Do not write this profile's rules or commands into another
harness's config dir.

Cursor application data for this profile is the `--user-data-dir` used to launch
it, not `{{AGENT_CONFIG_DIR}}`. `{{AGENT_CONFIG_DIR}}` holds `AGENT.md`, `commands/`,
and `extensions/` only.

- A spawned agent with a fresh context does not see this file. When delegating
  settings or config work, pass `{{AGENT_CONFIG_DIR}}` (and the user-data-dir, if
  that is the real target) explicitly in the prompt, or make the edit yourself.
