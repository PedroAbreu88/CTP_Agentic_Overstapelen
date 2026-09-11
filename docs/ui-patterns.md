# Armscanner UI patterns

How screens are actually *composed*, as opposed to what components exist.
`docs/design-system.md` gives the vocabulary; this gives the grammar.

Derived by reading frames from the Figma designs file
(`XMc8Glk3X9V3xh1uEiYoRe`), **last modified `2026-09-01T11:59:03Z`**. Regenerate
the underlying reading with `./tools/figma-flow.sh <page pattern>`.

> **Coverage is partial, but no longer because of the API.** The seat was
> upgraded on 2026-09-10 and the rate limit that shaped earlier sessions is
> gone (see `docs/figma-access.md`). What remains missing is missing from the
> **file**, not from our reading of it. Everything here was read from the file;
> anything inferred is labelled as an inference.

## The physical buttons are part of the UI

This is the most important thing on this page, and it is invisible from the
component inventory.

The *Device button guidelines* page documents **three physical action buttons**.
The section is named `WT6400`, and there is no equivalent `WT6300` section in
the file — so this is read from the WT6400 and **not yet confirmed for the
WT6300**, which `docs/product-context.md` also lists as target hardware.

| Key | Role |
| --- | --- |
| `P1` | Tertiary action / pagination |
| `P2` | Secondary action |
| `P3` | Primary action |

Worth confirming with design whether the WT6300 shares this mapping. The screens
themselves are drawn at both device sizes without distinguishing model, which
suggests it is a general convention — but that is an inference, not something
the file states.

**Screens name the key in the button label**, in parentheses, as part of the
visible text:

```
"Nee, kies divisie (P2)"      "Ja, ga verder (P3)"
"No, select division (P2)"    "Yes, continue (P3)"
```

So the operator does not have to touch the screen to act — and with both hands
holding crates, usually cannot. **Touch is the fallback; the hardware keys are
the primary input.** Every screen with actions should bind them to keys and say
so in the label.

This also explains component names in the library that otherwise look cryptic:
`Button - P1`, `Secondary Button P123`, `Secondary Button P123 - Nadine`.

Convention observed: the **dismissive or secondary** choice is `P2` and sits on
the left; the **confirming or primary** choice is `P3` and sits on the right.

## Screen anatomy

Every **non-modal** screen read so far is three stacked regions. Modal
interruptions are a separate anatomy — see [Interruptions are
modal](#interruptions-are-modal-and-cover-the-button-bar).

```
┌─────────────────────────────────┐
│ Android status bar              │  16px  (534) / 21px (640)
├─────────────────────────────────┤
│                                 │
│ Content                         │  fills remaining space
│                                 │
├─────────────────────────────────┤
│ Button bar                      │  72px — fixed on both sizes
└─────────────────────────────────┘
```

Measured, for the same screen at both target sizes:

| Region | 534×320 | 640×360 |
| --- | --- | --- |
| Status bar (`Android / Status Bar - Nadine`) | y=0, h=**16** | y=0, h=**21** |
| Content | y=16, h=**232** | y=21, h=**267** |
| Button bar (`Button bar - Pantry`) | y=248, h=**72** | y=288, h=**72** |

**The button bar is a fixed 72px on both sizes.** It does not scale. On the
smaller device that is 22.5% of the screen, which is the single biggest
constraint on how much content fits.

### Content region internals

For a message screen (illustration + text):

- Content frame: `HORIZONTAL` layout, `gap=12`, padding `16` top / `24` sides.
- Illustration: **120×120**, from the `Illustrations` sets.
- Text column: `VERTICAL`, `gap=8`, **354px** wide at 534 (460px at 640) —
  i.e. the illustration takes a fixed 120 and the text takes the rest.
- Heading and body are separate text nodes, 64px and 48px tall respectively.

### Button bar internals

- Outer padding `12` top/bottom, `16` sides.
- Buttons are **48px tall**, in a `🧬 Button - Group` with `gap=12`.
- Two buttons split the width evenly: **245px each** at 534.
- Each button is icon + label, `gap=8`, icon 16×16.

`Button bar - Pantry` has variants for `Amount=1|2|3` and `Divider=True|False`,
so one, two or three actions are supported. Three buttons on a 534px screen
leaves ~160px each — enough for a short Dutch label and no more.

## Interruptions are modal, and cover the button bar

The `↳ Break / Quit activity` page holds **24 frames across five flows**. Four
of them appear once per NL/ENG × device size (16 frames); `Resume_activity`
appears **twice** in each of those four combinations, for 8. The duplicates look
like working copies rather than distinct states — worth confirming with design
before treating either as canonical.

| Flow | Purpose |
| --- | --- |
| `Freezer_check` | Confirm before entering or leaving the freezer |
| `Quit/Break` | Choose between quitting and taking a break |
| `Break_time` | Break in progress |
| `Quit_confirmation` | Confirm quitting the activity |
| `Resume_activity` | Return to an activity already in progress |

**None of them use the three-region anatomy.** Each is a full-bleed
` Overlay - Pantry` at the full screen size, with a dialog centred on top:

| Component | Size at 534×320 | Used by |
| --- | --- | --- |
| `🧬 Dialog - Feedback` | 502×284 | `Freezer_check` |
| `🧬 Dialog - Content` | 502×260 | `Quit/Break`, `Break_time` |
| `🧬 Dialog - Content` | 502×204 | `Resume_activity` |
| `🧬 Dialog - Feedback` | 502×252 | `Quit_confirmation` |

So a dialog is **16px inset on each side** and sits over everything, including
the 72px button bar. The button bar is therefore *not* a permanent fixture:
when the app interrupts the operator, it takes the whole screen.

Some variants carry explicit `Click area` nodes — `229×48` and `229×120` — in
pairs. At 502px wide with a gap, `229` is a half-width target, so these are
two-choice dialogs with touch targets far larger than the visible control. On a
device operated with gloves that is the right instinct, and worth copying.

**Caution: several of these screens use deprecated components.**
`🧬 Dialog - Content [OLD]` and `🧬 Dialog - Feedback [OLD]` appear in
`Quit_confirmation` and `Resume_activity`, while `docs/design-system.md` records
`[OLD]` as a hard do-not-use. The designs file is mid-migration and the two
sources disagree. Do not copy an `[OLD]` variant into new work; ask design which
is current before building an interruption screen.

## Screens are bilingual

Every screen exists as a **NL** and an **ENG** variant — `Continue_message_NL`
and `Continue_message_ENG`. Dutch is not an afterthought or a localisation
layer applied later; it is designed alongside English at the same fidelity.

Observed copy is short, sentence case, and question-led:

- `"Verdergaan waar je gebleven was?"` / `"Continue where you left off?"`
- `"Je was bezig met het verzamelen van diepvriesproducten."` /
  `"You were in progress of picking frozen products."`

Note the register: informal *je*, not *u*. Match it.

### The agreed terminology

The `↳ Content guidelines` page carries a small NL/ENG glossary. It is the only
terminology guidance in the file, so use exactly these words rather than
synonyms:

| ENG | NL |
| --- | --- |
| Division | Divisie |
| Aisle | Pad |
| Chilled | Koel |
| Quantity | Aantal |
| Items | Items |

And one formatting rule, quoted verbatim:

> *"Amounts are always written with a period and no euro sign (f.e. 8.10)"*

That is the whole page. **There is no documented tone or length guidance**, so
the register described above remains an inference from four observed strings,
not a stated rule. Worth asking design to write it down.

Note that these terms are picking vocabulary — none of the overstapelen domain
(`strek`, `strekkar`, `strekkenplein`, see `docs/product-context.md`) appears
anywhere in the design file. New terms will need agreeing with design, and the
NL/ENG pairing above is the pattern they should follow.

## Both device sizes are designed

Screens are drawn at **534×320 and 640×360**, not one with the other derived.
A proposal should say which it targets, and design for 534×320 first — it is
the tighter budget and the button bar does not shrink to help.

The `↳ Devices and frame size` page states the two sizes and nothing else of
substance — but it **contradicts the screens on one measurement**. It draws the
status bar at `534×24`; every actual screen in the file uses `534×16`. At 640
both agree on `21`.

**Trust the screens, not the spec page**: 16px is what every 534-wide screen we
have read actually uses, and it is
what the anatomy table above records. Eight pixels of content budget hang on
this, so it is worth having design correct whichever is stale.

## What is not designed yet

Read from the file, so this is absence rather than oversight on our part:

| Page | State |
| --- | --- |
| `00. System states` | **Empty** — no children at all |
| `03. Picking` | **Empty** — no frames |
| `↳ Select division` | **Empty** — no frames |
| `↳ Continue with picking` | 4 screens (NL/ENG × both sizes) |

Two absences matter more than the rest.

**The Picking flow is largely undrawn.** Only the "continue where you left off?"
interruption screen exists. That cuts both ways: there is less precedent to
follow than assumed, and correspondingly more room to propose — but a proposal
cannot claim to match an existing Picking screen that does not exist.

**`00. System states` is empty, and that is a gap in the product, not the
documentation.** It was expected to hold the error toast and warning states.
`docs/product-context.md` lists *"the floor does not stop"* as a
non-negotiable constraint — if the app is unavailable or wrong, a defined
fallback must already exist. **No error or degraded state has been designed for
any Armscanner flow.** Anyone proposing overstapelen screens is proposing the
first ones, and should say so rather than assume a house style exists.

The library does hold `Toast - Nadine` (4 variants) and `Toast - Pantry`, so the
components exist; what is missing is any screen showing when and how they are
used.

## Everything named here has now been read

The pages previously listed as unread were fetched on 2026-09-10, after the seat
upgrade lifted the rate limit. `00. System states` turned out to be empty and
`↳ Content guidelines` turned out to be much smaller than hoped; both findings
are recorded above.

One caveat about the tooling, learned in the process:
**`./tools/figma-flow.sh` only reports frames matching a device size**
(534×320 or 640×360). `↳ Content guidelines` holds two off-size frames —
`Glossary` and `Other` — and the tool printed nothing for that page, which looks
exactly like an empty page. A silent page is not necessarily an empty one;
confirm with `/v1/files/:key/nodes?ids=<page>&depth=2` before concluding
anything is absent.

## Open questions for design

- **Which dialog components are current?** `Quit_confirmation` and
  `Resume_activity` use `🧬 Dialog - Content [OLD]` and
  `🧬 Dialog - Feedback [OLD]`, which the library marks deprecated. One of the
  two sources is wrong.
- **Is the status bar 16px or 24px at 534?** The screens say 16, the
  `↳ Devices and frame size` page says 24.
- **Who designs the error and warning states?** `00. System states` is empty,
  and "the floor does not stop" needs an answer before overstapelen ships.
- **Does the WT6300 share the WT6400's `P1`/`P2`/`P3` mapping?** The file
  documents only the WT6400.
- **Is the Picking flow undrawn or drawn elsewhere?** Two of its three pages are
  empty.
- **Is there tone and length guidance anywhere?** `↳ Content guidelines` holds
  only a five-term glossary and a number-formatting rule.
- **What are the agreed NL/ENG terms for the overstapelen domain?** `strek`,
  `strekkar` and `strekkenplein` appear nowhere in the design file.
- **What is the overstapelen task icon?** The library has ~30 task types —
  Picking, Counting, Mutating, Emballage and so on — and none for overstapelen,
  strek or transfer. A new icon is a lead-time item.
