---
description: Build an animated explainer of a concept and open it in the browser. Choose the shape that makes the mechanism clearest — graph, tree, grid, state machine, flow, timeline — and write its renderer; a shared shell supplies controls, in-frame legend, live annotations and notes. Iterative: the first render is a draft.
argument-hint: [concept to visualise]
---

# Concept Viz

Target: $ARGUMENTS. If empty or too vague to build from, ask what concept to visualise, and let
the user correct the mechanism before you build anything.

The `template/` folder lives in this protocol folder. Never hardcode a harness home path.
Resolve it per `protocols/README.md`: this folder in the repo, the skill folder after a skill
install, or the command-form sidecar (sibling of the commands directory, named `concept-viz/`)
after a command install.

Turn a concept into an animated page the learner can play, pause, step through and scrub.

## What is fixed, and what is yours

**Fixed — `template/player.html`, the shell.** Every explainer gets the same chrome, and you do
not redesign it: play/pause · step-by-step that auto-pauses · continuous speed from 0.05× ·
replay-scene and restart-all · a hard start nothing can scrub behind · scene navigation and
progress · legend in-frame beside the diagram · notes that reveal as the animation advances ·
live stat readouts · a footnote line · keybindings · the palette, typography and dark theme.

**Yours — the shape, the diagram and the model.** The shell draws nothing of its own.

## Choose the shape — this is the decision that matters

**The learner should grasp the mechanism from the picture before reading a word.** The shape is
chosen for comprehension, not for convenience, not for what you drew last time.

Before writing any code: name **two** shapes that could carry this mechanism, say which you are
choosing and why it makes the idea land faster. Tell the user, and let them correct you — the
same way you let them correct the mechanism. Then declare it in the model so the choice is on the
record:

```js
const SHAPE = 'graph — the cycle IS the concept; on a timeline it would be invisible';
```

| When the mechanism is about…            | the picture is usually…            |
| --------------------------------------- | ---------------------------------- |
| who waits on whom, cycles, relationships | a graph — nodes and edges          |
| nesting, splitting, descent              | a tree                             |
| position, locality, adjacency            | a grid or memory map               |
| discrete modes and the moves between     | a state machine                    |
| a value travelling through stages        | a flow or pipeline                 |
| several actors contending over time      | lanes on a shared time axis        |
| proportion, growth, relative magnitude   | bars or an area                    |
| a rule producing structure from a seed   | successive generations in place    |

None of these is the default. A timeline is one row of that table, not the shape everything falls
back to. Note too that `t` is an **animation step**, not necessarily time — a tree can reveal one
level per step, a graph one edge, a grid one cell.

No renderer or worked example ships with this protocol, deliberately: a shipped example gets
copied, and then every explainer looks alike whether or not that shape helps anyone learn.

## Build it

1. **Agree the mechanism.** Not "HTTP/1.1" — "why a slow response blocks what is queued behind
   it." State what you will show and let the user correct it before building.
2. **Name the tension** — what goes wrong, and what fixing it costs.
3. **Choose and declare the shape** (above). Say it to the user before you write code.
4. **Model it, run it, read the numbers — then design scenes.** One model, different inputs per
   scene. Never hand-write per-scene numbers.
5. **Write the renderer**, copy `template/player.html`, replace the single line `/*__MODEL__*/`
   with your model, open it.
6. **Say what to look at.** Then fix what the user calls out. Several rounds is normal and is
   where the quality comes from.

## The contract

Your model defines these; the shell consumes them.

```js
const TICK_MS = 20;     // wall-clock ms per animation step
const SHAPE   = '...';  // the shape you chose, and why
const S = [ scene ];    // scenes, played in order
const RENDER = {
  size(scene)       -> [w, h]      // SVG viewBox
  mount(scene)      -> svg string  // static layer, built once when the scene opens
  frame(scene, t)   -> svg string  // dynamic layer, rebuilt every step
};
const LEGEND  = [[colourToken, label], ...];   // optional; or per-scene scene.legend
const PALETTE = ['--s0', ...];                 // optional; seven actor colours by default

scene = {
  tag, title, sub,        // header; title may contain <em>
  fin,                    // last step of this scene
  notes: [[step, text, isKey?]],
  stats: [{ label, tone: 'bad'|'good', value: t => string }],
  legend?, foot?          // foot: the model's assumptions and parameter values
}
```

Available to renderers — CSS classes `.lbl .st .axl .anl .glyph .stall-r`, and colour tokens
`--ink --faint --dim --line --line2 --hs --req --wait --block --stall --lost --rtx --ok` plus the
actor palette `--s0`…`--s6`. Read them with `css('--token')`.

Keep annotations **live**: brackets that grow, counters that tick, highlights that appear when the
thing they describe happens. A static caption is a legend, not an annotation.

**Size the viewBox for legibility, not for your monitor.** The shell scales the SVG to any width,
so the diagram is responsive for free — but text scales with it, and **width is what governs
whether labels stay readable**: at a viewBox around 900–1200 units, ~11px label text is still
legible in a window that is not maximised. Go much wider and it is not.

Height is a separate concern — keep it under about 600 units so the diagram, its notes and the
controls fit without scrolling. Aspect ratio itself does not matter: a tree is naturally wide and
short, a call stack tall and narrow. If a diagram truly needs more width, split it across scenes
rather than widening it, and never assume a maximised window.


## Three traps the eye will not catch

- **Aggregates that quietly exclude the unfinished.** A completion figure averaged over only the
  items that completed gets *better* as load rises. Assert everything finished, or the headline
  number lies.
- **Unmatched comparisons.** Vary one parameter; name it in the label.
- **Differences below your own resolution.** If two configurations land within one step, the model
  cannot see the effect — change the resolution or drop the comparison. Never report "they tie"
  about something real; say the model cannot resolve it.

Put the parameter values on screen via `scene.foot`. Nothing here checks the model against
reality — that is the user's judgement, which is why the assumptions must be visible.

## Output

Write artefacts to a temp/scratch directory as `cviz-<slug>.html`. **The template is permanent;
only produced artefacts are disposable.** Delete nothing without asking; on cleanup, check sibling
session directories too. Close with the path and: *nothing is deleted until you say so — tell me
when to clean up.*
