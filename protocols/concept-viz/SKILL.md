---
name: concept-viz
description: Build an animated explainer of a concept — actors contending on a shared timeline — and open it in the browser. Iterative: the first render is a draft you refine with the user. Trigger on "visualise/animate this concept", "show me how X works", "make a diagram of X over time".
argument-hint: [concept to visualise]
---

# concept-viz

Turn a concept into an animated page the user can play, pause, step through and scrub.

## Seeding this protocol

This folder installs as a unit. **`SKILL.md` is the only markdown here — deliberately.**
`template/` contains `.html` and `.js` only, so no harness can register them as extra commands
or skills no matter where the folder lands.

- Installing as a **skill**: copy the whole folder. Done.
- Installing as a **command**: copy `SKILL.md` into the command directory, put `template/`
  anywhere *outside* it, and tell the command where it went. Markdown inside a `commands/`
  directory is loaded as an invocable command; `template/` has none, but keep it out regardless.

Resolve `template/` relative to wherever this folder was seeded. Never hardcode an absolute path.

## The look is already decided

`template/player.html` is the house style. Use it as-is; don't redesign it per topic:

controls (play/pause, tick-step that auto-pauses, continuous speed from slow, replay-scene,
restart-all) · a hard start the timeline can't scrub behind · legend beside the chart, in frame ·
live annotations on the graphic that track the playhead and count as they grow · per-lane status
at the right edge · notes that reveal as the playhead passes.

If a topic needs something the player can't draw, extend the player once for everyone — never a
per-topic fork.

## The content is your job

1. **Agree the mechanism.** Not "HTTP/1.1" — "why a slow response blocks what's queued behind it."
   No argument given? Ask. State what you'll show and let the user correct it before building.
2. **Name the tension** — what goes wrong, and what fixing it costs.
   Arc: naive → it breaks → each fix and its price → comparison.
3. **Model it, run it, read the numbers — then design scenes.** One model, different inputs per
   scene. Never hand-write per-scene numbers.
4. **Build, open, and say what to look at.** Then fix what the user calls out. Several rounds is
   normal and is where the quality comes from.

## Writing the model

Copy `template/player.html`, replace the single line `/*__MODEL__*/` with your model, open it.
`template/example/http-hol.model.js` is a complete worked example — pattern-match on it.

The model supplies both the simulation and the topic's wording:

```js
TICK_MS, TW          // ms per cell; timeline width in cells
S = [ scene, ... ]   // scenes: {tag,title,sub,lanes,wire?,fin,notes,anno,legend?,foot?,drain?}
LABELS               // per-lane status words: {hs,req,wait,resp,block,stall,wire,idle}
LEGEND               // [[cssVar,label], ...]  — or per-scene via scene.legend
STATS                // [{label,kind:'elapsed'|'sum'|'done',of:[kinds],tone:'bad'|'good'}]
PALETTE              // optional; defaults to seven actor colours
```

## Three traps the eye won't catch

- **Actors that never finish.** A completion time computed over only the finished ones gets
  *faster* as load rises. Assert everyone finished, or the headline number lies.
- **Unmatched comparisons.** Vary one parameter; name it in the label.
- **Differences under one tick.** The model is too coarse to see the effect — change resolution
  or drop the comparison. Never report "they tie" about something real; say the model can't
  resolve it. The worked example does exactly this, and says so on screen.

Put the parameter values on screen. Nothing here checks the model against reality — that is the
user's judgement, which is why the assumptions are visible.

## Output

Write artefacts to a temp/scratch directory as `cviz-<slug>.html`. **The template is permanent;
only produced artefacts are disposable.** Delete nothing without asking; on cleanup, check sibling
session directories too. Close with the path and: *nothing is deleted until you say so — tell me
when to clean up.*
