# Armscanner UI patterns

How screens are actually *composed*, as opposed to what components exist.
`docs/design-system.md` gives the vocabulary; this gives the grammar.

Derived by reading frames from the Figma designs file
(`XMc8Glk3X9V3xh1uEiYoRe`), **last modified `2026-09-01T11:59:03Z`**. Regenerate
the underlying reading with `./tools/figma-flow.sh <page pattern>`.

> **Coverage is partial, deliberately.** Figma's API is rate-limited to a
> handful of calls per week on the current seat (see `docs/figma-access.md`), so
> this was built from the pages that mattered most. What is here was read from
> the file; what is missing is named as missing rather than guessed.

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

Every screen read so far is three stacked regions:

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

## Screens are bilingual

Every screen exists as a **NL** and an **ENG** variant — `Continue_message_NL`
and `Continue_message_ENG`. Dutch is not an afterthought or a localisation
layer applied later; it is designed alongside English at the same fidelity.

Observed copy is short, sentence case, and question-led:

- `"Verdergaan waar je gebleven was?"` / `"Continue where you left off?"`
- `"Je was bezig met het verzamelen van diepvriesproducten."` /
  `"You were in progress of picking frozen products."`

Note the register: informal *je*, not *u*. Match it.

## Both device sizes are designed

Screens are drawn at **534×320 and 640×360**, not one with the other derived.
A proposal should say which it targets, and design for 534×320 first — it is
the tighter budget and the button bar does not shrink to help.

## What is not designed yet

Read from the file, so this is absence rather than oversight on our part:

| Page | State |
| --- | --- |
| `03. Picking` | **Empty** — no frames |
| `↳ Select division` | **Empty** — no frames |
| `↳ Continue with picking` | 4 screens (NL/ENG × both sizes) |

The Picking flow that overstapelen is meant to sit alongside is **largely
undrawn**. Only the "continue where you left off?" interruption screen exists.

That cuts both ways: there is less precedent to follow than assumed, and
correspondingly more room to propose — but a proposal cannot claim to match an
existing Picking screen that does not exist.

## Still unread

Blocked on the API rate limit, not on difficulty. In rough priority order:

- `00. System states` — error toast, warning. Directly serves the "floor does
  not stop" constraint.
- `↳ Break / Quit activity` — how interruption is handled.
- `↳ Content guidelines` — the tone and length rules, rather than inferring
  them from four strings as above.
- `↳ Devices and frame size` — already partly known (the two sizes), may carry
  more.

Fetch with `./tools/figma-flow.sh '00. System states|Break|Content guidelines'`
when the rate limit allows.

## Open questions for design

- **Does the WT6300 share the WT6400's `P1`/`P2`/`P3` mapping?** The file
  documents only the WT6400.
- **Is the Picking flow undrawn or drawn elsewhere?** Two of its three pages are
  empty.
- **What is the overstapelen task icon?** The library has ~30 task types —
  Picking, Counting, Mutating, Emballage and so on — and none for overstapelen,
  strek or transfer. A new icon is a lead-time item.
