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

Note that these terms are picking vocabulary. The overstapelen domain is
**partly** covered: `↳ Adding products to orders` supplies `kar` (cart),
`karren` (carts), `ladingdrager` (load carrier), `karoverzicht` (cart overview)
and `inhoud` (contents), all in the informal register. What is still undefined
anywhere in the file is the overstapelen-specific vocabulary — `strek`,
`strekkar`, `strekkenplein` (see `docs/product-context.md`). Those need agreeing
with design, and the NL/ENG pairing above is the pattern they should follow.

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

## Section pages are empty by design

**Read this before concluding anything is missing.** The page list is flat, and
a `↳` prefix marks a child page by naming convention only. A section header like
`00. System states` or `03. Picking` has **zero children**, and that is normal —
its content lives in the `↳` pages listed after it.

Worse, **the section names are not reliable either.** The picking flow is not
under `03. Picking` — that section is nearly empty. It is under `09. N/A`, as
`↳ Collect products`, with 66 screens. A section called `N/A` holds the single
most relevant flow in the file.

We got this wrong twice, both times expensively: `00. System states` was
reported here as an undesigned gap when its two child pages hold 20 screens, and
the picking flow was reported as largely undrawn when it has 66. **Never
conclude something is absent from a section page's name or child count.** Search
the whole file for the screen you expect, then look at what is around it.

## The cart flow already exists

This is the most directly relevant precedent in the file, and it went unread for
weeks. `↳ Adding products to orders` contains a complete load-carrier flow:

| Screen | NL title | Composition at 534×320 |
| --- | --- | --- |
| `Cart_overview` | *Karoverzicht* | `🧬 List item - Regular` 486×72 |
| `Select_cart` | *Selecteer een kar* | `🧬 List item - Regular` 486×72 |
| `View_contents` | *Overzicht van inhoud* | `🧬 Product Card List` 486×96 |
| `Verify_load_carrier` | *Inhoud ladingdrager* | `🧬 Checkbox` 486×48, `🧬 Divider`, `🧬 Product Card List` 486×96 |

Observed copy, both languages at equal fidelity:

- `"Karoverzicht"` / `"Cart overview"` — *"Bekijk en selecteer de kar met items
  die je aan bestellingen wilt toevoegen."*
- `"Selecteer een kar"` / `"Select a cart"` — *"Er zijn meerdere karren met
  hetzelfde product beschikbaar."*

### The house pattern for cart contents is a list, not a grid

**This bears directly on [ADR 0004](decisions/0004-position-map-over-per-crate-scan.md).**
The design system's existing answer to *"show me what is on this load carrier"*
is a **vertical list of full-width rows**, 486 wide and 72 or 96 tall, with a
checkbox to confirm. Not a spatial map.

At 232px of content that is **two to three rows visible**, so the list scrolls.
A position map trades that scrolling for glanceability — which may well be the
right trade for an arm-mounted screen, but it is now a trade **against an
existing pattern** rather than a choice in a vacuum. ADR 0004 was written
believing no alternative was drawn. One is, and it is drawn in Dutch.

`Verify_load_carrier` is worth studying before specifying our cart-complete
screen: it is already the "confirm what is on this carrier" interaction, with a
checkbox rather than a button as the confirming control.

## Tiles, onboarding and list density

Three more patterns worth knowing, all previously unrecorded.

**Tiles exist, three across.** `Select_next_step` — *"What do you want to do
next?"* — uses `🧬 Tile - Pantry` at **154×156, three in a row**. So a tile grid
is house style, but the established form is a single row of three, not a matrix.

**Every flow has a three-screen onboarding.** `Onboarding_1/2/3` appear in both
`↳ Collect products` and `↳ Adding products to orders`, composed of a 145×145
illustration and `_🖇️Pagination - Pantry` at 32×8. Given a workforce that is
~92% flex and continuously onboarded, this is a pattern overstapelen should
almost certainly reuse rather than skip. Note the pagination component, which is
what `P1` is bound to.

**List item sizes are a fixed vocabulary:**

| Component | Height at 534 | Seen in |
| --- | --- | --- |
| `🧬 List item - Image (S)` | 486×64 | `Activity_detail` |
| `🧬 List item - Regular` | 486×72 | `Cart_overview`, `Select_cart` |
| `🧬 Product Card List` | 486×96 | `View_contents`, `Verify_load_carrier` |

All are 486 wide — a 24px inset each side, matching the content region padding.
Three 64px rows fit the 232px budget; two 96px rows do.

The main picking screen, `Collect_default`, composes `🧬 Quantity Stepper`
215×48, two `🧬 Tag 1.1` chips and a `🧬 Button - Icon` 48×48 under the heading
*"Collecting products / Scan or add manually"* — useful as the reference for
what a dense working screen looks like here.

## Error and warning states exist

They live under `00. System states`, in two child pages, and they establish a
clear two-tier convention.

**`↳ Error toast` — 12 screens, all `Product_error` NL/ENG × both sizes.** A
toast in the **bottom** region over a full-bleed ` Overlay - Pantry`:

| Component | Size at 534 |
| --- | --- |
| `🧬 Toast` | 518×56, or 518×80 for two lines |
| `🧬 Toast with location` | 518×56 |

518 is 8px inset each side. The `with location` variant composes an `attention`
icon (24×24) with `Product location - Pantry` (125×24), so an error can point at
*where* to go, not only what went wrong. Observed copy: `"Incorrect product
scanned: return to"` followed by the location component.

**`↳ Warning` — 8 screens, all `Warning_message` NL/ENG × both sizes.** A modal
`🧬 Dialog - Feedback` at 502×284 or 502×252, same overlay-plus-dialog anatomy
as the interruptions.

The division is the useful part: **a toast for a recoverable error the operator
corrects and continues past; a modal warning for something that must be
acknowledged.** Note that the warning screens use the `[OLD]` dialog variant, so
confirm the current component before copying.

## The cart is already modelled in the library

`Load Carrier` is a **23-variant component set** that describes crates on a
carrier, and it is the closest thing to a position map that already exists.

| Axis | Values |
| --- | --- |
| `Type` | `Whole crate`, `Whole crate 2`, `Whole crate small 2`, `Half crate`, `Half crate 2`, `Bag front`, `Bag top` |
| `State` | `To map`, `Mapped`, `Not to map` — plus, for `Half crate 2`: `Mapped Up`, `Mapped Down`, `Mapped Up Scan down`, `Mapped Down Scan up`, `Mapped Full` |

Three things follow, and they matter more than the component itself.

**A cart position is not uniformly "one crate".** Positions hold whole crates,
half crates and bags, and half crates stack two high — which is what
`Mapped Up` / `Mapped Down` / `Mapped Full` encode. Any position map that
assumes a uniform grid of identical cells is assuming something the design
system already contradicts.

**`To map` / `Mapped` / `Not to map` is cart-mapping vocabulary that already
exists.** That is Phase 2's problem — mapping a cart while loading it from the
reject lane — modelled before we asked for it. It is also evidence that the
`Not to map` case is real: some positions are deliberately excluded.

**`Mapped Up Scan down` implies a per-position scanning interaction**, where one
half of a stacked position is confirmed and the other is being scanned. That is
close to ADR 0004's option (c), the confirming-scan fallback. Worth understanding
before assuming option (b) is the only designed-for route.

None of this confirms how many positions a cart has — that still needs the
floor. But it does mean a proposal should extend `Load Carrier` rather than
invent a tile, and should ask design what these states were drawn for.

## What is not designed yet

Confirmed by node count, not inferred from a silent page:

| Page | State |
| --- | --- |
| `↳ Splash` | **Empty** — zero children |
| `↳ Login` | **Empty** — zero children |
| `↳ App logo` | **Empty** — zero children |
| `🔀 User flow` (top level) | **Empty** — zero children |
| `↳ Select division` (under `03. Picking`) | **Empty** — but see below |
| `↳ ` (unnamed, under `00. Flow name`) | **Empty** — a template stub |

**`↳ Select division` being empty is misleading.** A `Select_division` screen
does exist — in `↳ Collect products`, along with the rest of the picking flow.
The empty page under `03. Picking` is an abandoned placeholder, not a gap.

So the honest summary is the opposite of what this document said until
2026-09-11: **overstapelen has substantial precedent to match.** Picking,
cart selection, load-carrier verification, onboarding, errors and interruptions
are all drawn. What is genuinely absent is anything showing crates positioned
*spatially* on a cart, and any state for a backend outage.

## Everything in this file has now been read

All pages were read on 2026-09-10 and 2026-09-11, after the seat upgrade lifted
the rate limit. Roughly 220 screens were found in pages previously recorded as
unread or absent.

Three caveats about the tooling, all learned the hard way:

**`./tools/figma-flow.sh` only reports frames matching a device size**
(534×320 or 640×360). `↳ Content guidelines` holds two off-size frames —
`Glossary` and `Other` — and the tool printed nothing for that page, which looks
exactly like an empty page. A silent page is not necessarily an empty one;
confirm with `/v1/files/:key/nodes?ids=<page>&depth=2` before concluding
anything is absent.

**The size tolerance is tight enough to miss real screens.** `↳ N/A` under
`03. Splitting` holds a frame at **536×302** — two pixels and eighteen pixels
off the 534×320 target — which the tool skipped. It also holds wide flow
diagrams at 3398×560 that are deliberately not screens.

**`Documentation components` and `Thumbnail` are not documentation you want.**
The first is a template stub (`Title`, `Body text`, `native scanning sound`),
the second is the file's 1600×960 cover image.

## Open questions for design

- **Should the position map be a map at all?** `Verify_load_carrier` already
  solves "confirm what is on this carrier" as a scrolling list with a checkbox.
  A spatial map is a deliberate departure from that, and needs justifying rather
  than assuming. See ADR 0004.
- **Which dialog components are current?** `Quit_confirmation` and
  `Resume_activity` use `🧬 Dialog - Content [OLD]` and
  `🧬 Dialog - Feedback [OLD]`, which the library marks deprecated. One of the
  two sources is wrong.
- **Is the status bar 16px or 24px at 534?** The screens say 16, the
  `↳ Devices and frame size` page says 24.
- **Who designs the error and warning states?** Answered — they exist, see
  above. What is *not* answered is whether the toast/warning split covers a
  backend outage, which is a different kind of failure from a bad scan.
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
