---
description: Build an animated explainer of a concept and open it in the browser — you write the diagram that fits the mechanism, the shell supplies controls, legend, live annotations and notes. Iterative: the first render is a draft.
argument-hint: [concept to visualise]
---

# Concept Viz

Target: $ARGUMENTS. If empty or too vague to build from, ask what concept to visualise, and let
the user correct the mechanism before you build anything.

The `template/` folder ships beside this file. Resolve it relative to wherever this folder was
seeded; never hardcode an absolute path.

Turn a concept into an animated page the user can play, pause, step through and scrub.

## What is fixed, and what is yours

**Fixed — `template/player.html`, the shell.** Every explainer gets the same chrome, and you do
not redesign it: play/pause · tick-stepping that auto-pauses · continuous speed from 0.05× ·
replay-scene and restart-all · a hard start nothing can scrub behind · scene navigation and
progress · legend in-frame beside the diagram · notes that reveal as time passes · live stat
readouts · a footnote line · keybindings · the palette, typography and dark theme.

**Yours — the diagram and the model.** The shell draws no diagram of its own. You write a
`RENDER` object that draws whatever actually shows the mechanism.

**Pick the diagram from the mechanism, not from habit.** A queue over time wants lanes on a time
axis; a deadlock wants a wait-for graph; a B-tree split wants a tree; cache lines want a grid; a
handshake wants a state machine; a request path wants a flow. No renderer ships with this
protocol, deliberately — a shipped example gets copied, and then every topic looks the same
whether or not that shape fits.

## Build it

1. **Agree the mechanism.** Not "HTTP/1.1" — "why a slow response blocks what is queued behind
   it." State what you will show and let the user correct it before building.
2. **Name the tension** — what goes wrong, and what fixing it costs.
3. **Decide the shape.** What picture makes the mechanism obvious? Say it out loud before coding.
4. **Model it, run it, read the numbers — then design scenes.** One model, different inputs per
   scene. Never hand-write per-scene numbers.
5. **Write the renderer**, copy `template/player.html`, replace the single line `/*__MODEL__*/`
   with your model, open it.
6. **Say what to look at.** Then fix what the user calls out. Several rounds is normal and is
   where the quality comes from.

## The contract

Your model defines these; the shell consumes them.

```js
const TICK_MS = 20;     // wall-clock ms per animation tick
const S = [ scene ];    // scenes, played in order
const RENDER = {
  size(scene)       -> [w, h]      // SVG viewBox
  mount(scene)      -> svg string  // static layer, built once when the scene opens
  frame(scene, t)   -> svg string  // dynamic layer, rebuilt every tick
};
const LEGEND  = [[colourToken, label], ...];   // optional; or per-scene scene.legend
const PALETTE = ['--s0', ...];                 // optional; seven actor colours by default

scene = {
  tag, title, sub,        // header; title may contain <em>
  fin,                    // last tick of this scene
  notes: [[tick, text, isKey?]],
  stats: [{ label, tone: 'bad'|'good', value: t => string }],
  legend?, foot?          // foot: the model's assumptions and parameter values
}
```

Available to renderers — CSS classes `.lbl .st .axl .anl .glyph .stall-r`, and colour tokens
`--ink --faint --dim --line --line2 --hs --req --wait --block --stall --lost --rtx --ok` plus the
actor palette `--s0`…`--s6`. Read them with `css('--token')`.

Keep annotations **live**: brackets that grow, counters that tick, highlights that appear when the
thing they describe happens. A static caption is a legend, not an annotation.

## Three traps the eye will not catch

- **Aggregates that quietly exclude the unfinished.** A completion figure averaged over only the
  items that completed gets *better* as load rises. Assert everything finished, or the headline
  number lies.
- **Unmatched comparisons.** Vary one parameter; name it in the label.
- **Differences below your own resolution.** If two configurations land within one tick, the model
  cannot see the effect — change the resolution or drop the comparison. Never report "they tie"
  about something real; say the model cannot resolve it.

Put the parameter values on screen via `scene.foot`. Nothing here checks the model against
reality — that is the user's judgement, which is why the assumptions must be visible.

## Output

Write artefacts to a temp/scratch directory as `cviz-<slug>.html`. **The template is permanent;
only produced artefacts are disposable.** Delete nothing without asking; on cleanup, check sibling
session directories too. Close with the path and: *nothing is deleted until you say so — tell me
when to clean up.*
