---
type: pattern
repo: vivenu-core
scope: pr-template
confidence: high
learned: 2026-07-02
verified_last: 2026-08-13
source_session: "[[2026-07-02-1436-checkout-native-loading]]", "[[2026-07-07-1107-afg-3085-respect-showavailableseats]]"
---

**Fact:** the user's expected PR body template for vivenu-core (not found as a `.github/PULL_REQUEST_TEMPLATE.md` file in-repo, given directly by the user, so treat as authoritative regardless):

```markdown
## Description, Motivation and Context

<!--- Describe your changes in detail -->
<!--- Why is this change required? What problem does it solve? -->
<!--- If it fixes an open issue, please link to the issue here. -->

## How to test?

<!--- Please describe in detail how you tested your changes. -->
<!--- Include details of your testing environment, and the tests you ran to -->
<!--- see how your change affects other areas of the code, etc. -->
```

**Why it matters:** the user wants this prefilled automatically whenever they say they're about to make a PR in this repo — don't ask what format to use, don't fall back to this session's generic `gh pr create` default (Summary/Test plan bullets), use this exact structure with the actual change's description/motivation and testing steps filled in under each heading.

**How to apply:** when creating a PR for vivenu-core, use this as the `--body` template for `gh pr create`, filling in real content (not leaving the HTML comments as placeholders) under both headings. Combine with [[git-branch-and-commit-conventions]] for branch/commit naming on the same PR. The prose written under each heading should follow the Writing style section of the seeded harness `AGENT.md`: no em dashes, human prose, succinct, first-principles grounded, not a dry bullet-list changelog.

**Evidence (2026-07-07, AFG-3085):** this repo has Cursor Bugbot installed, which auto-posts a diff-overview comment (Overview + Risk assessment, technical detail per file) on every PR shortly after it opens. A PR body for AFG-3085 that included a file-by-file "Changes:" bullet list under Description was followed by a Bugbot comment covering the same three files in the same order, a near-duplicate of the hand-written list. Concrete confirmation of why "not a dry bullet-list changelog" matters here specifically: with Bugbot in the repo, that kind of list isn't just poor style, it's actively redundant with something that appears on the PR automatically.

**Refinement:** keep "Description, Motivation and Context" to the *why* (a sentence or two on the problem and the reasoning that led to the fix), not a walkthrough of *what changed file by file* — Bugbot's comment already provides that. This does not extend to "How to test?": Bugbot's comment covers risk/overview only, never reproduction or testing steps, so that section should stay as detailed as the change actually needs.
