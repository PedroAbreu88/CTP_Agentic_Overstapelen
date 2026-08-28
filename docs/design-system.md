# Armscanner design system

Generated inventory of the published Figma library. **Do not edit by hand** —
regenerate with `./tools/figma-extract.sh`, which rewrites this file.

This exists so agents and people can work in the existing design vocabulary
without a Figma token and without an API call. It records *what exists and what
it is called*. It does not record why a pattern was chosen — that reasoning
lives with the design team, not in the file.

## Source

| | |
| --- | --- |
| Library file | [Armscanner - Library](https://www.figma.com/design/nsgOZTtYiHjPOxrt1ImVHv/) (`nsgOZTtYiHjPOxrt1ImVHv`) |
| Designs file | [Armscanner - UI designs](https://www.figma.com/design/XMc8Glk3X9V3xh1uEiYoRe/) (`XMc8Glk3X9V3xh1uEiYoRe`) |
| Library last modified | `2026-08-13T11:42:44Z` |
| Published components | 643 in 117 sets |
| Published styles | 167 |

`Library last modified` is the staleness check. Run
`./tools/figma-extract.sh --check` to compare it against the live file; a
mismatch means this document describes a library that has moved on.

The **library** defines components. The **designs** file consumes them — it
holds ~6,800 instances and almost no local components, so read the library for
the vocabulary and the designs file for how flows use it.

## Reading the names

Component names carry their origin as a suffix, and the library deliberately
blends three sources. This is the single most important thing to get right,
because picking a deprecated variant produces confident, wrong work.

| Family | Sets | Meaning |
| --- | --- | --- |
| `- Pantry` | 7 | From the Ahold Delhaize Pantry design system. |
| `- Nadine` | 16 | From the Nadine system. Often the newer of a duplicated pair. |
| unsuffixed | 91 | Armscanner-specific, built for this device class. |
| `[OLD]` | 3 | **Deprecated. Do not use.** |

Where a set appears twice under different families, that is a live migration,
not a mistake. Prefer the family used by the flow you are extending, and say
which you picked and why. If in doubt, ask design rather than guessing.

## Page marks — ✅ and ❌

Designers annotate library pages with tick and cross emoji. These are
**preserved verbatim and deliberately not interpreted**, because their meaning
is not recorded anywhere in the file.

| Mark | Pages |
| --- | --- |
| ✅ | `-> Button bar ✅`, `✅ Header`, `-> Volume toggle ✅` |
| ❌ | `-> Checkbox & radiobutton ❌`, `-> Input field ❌`, `-> Divider ❌` |
| unmarked | 29 pages |

**Do not guess what ❌ means.** It could mean "do not use", "not yet
reviewed", or "being replaced" — and those imply very different things for a
proposal. Treat a ❌ page as a question for design, not as a prohibition and
not as a green light. Most pages carry no mark at all, so absence of a tick
says nothing.

## Deprecated — do not use

- `🧬 Dialog - Content [OLD]` — 3 variants
- `🧬 Dialog - Feedback [OLD]` — 4 variants
- `Slider [OLD]` — 3 variants

## Component sets

Grouped by library page. Variant names are the axes you choose along
(`State=`, `Type=`, `Platform=`, `Size=` and so on).

### -> Cell

- ** Table / Cell / Regular** — 2 variants
  - `Divider=True`, `Divider=False`
- ** Table / Header** — 5 variants
  - `Type=Secondary, Divider=False`, `Type=Primary, Divider=Both`, `Type=Primary, Divider=False`, `Type=Secondary, Divider=True`, `Type=Primary, Divider=True`
- **Table Edit** — 2 variants
  - `Divider=True`, `Divider=False`

### ->  Icons

- **(ungrouped)** — 40 variants
  - `Icon / 666999`, `Icon / Error`, `Icon / Cat3&666999`, `Icon / Cool Freezerbox VIP`, `Icon / Rollcontainer`, `Icon / Cat2&666999` …
- **Chevron** — 4 variants
  - `Type=Right`, `Type=Left`, `Type=Down`, `Type=Up`
- **Icon** — 2 variants
  - `Type=Default`, `Type=Kilogram`
- **Icons - Pantry** _(Pantry)_ — 2 variants
  - `15min_outlined_24`, `30min_outlined_24`
- **Icons 64px** — 33 variants
  - `Type=Empty rollcontainer, Size=64px`, `Type=DummyCrate, Size=64px`, `Type=Goods Receival, Size=64px`, `Type=Smart Filling, Size=64px`, `Type=Multipack, Size=64px`, `Type=Picking Z-Area, Size=64px` …
- **Task icons** — 30 variants
  - `Type=Weighted prep, Platform=Wallscanner`, `Type=Smart Refill, Platform=Armscanner`, `Type=Indirect picking HB, Platform=Wallscanner`, `Type=Indirect picking DPVR, Platform=Wallscanner`, `Type=Corvee, Platform=Wallscanner`, `Type=Mutate, Platform=Armscanner` …
- **Task icons - 40px** — 31 variants
  - `Type=Spotcheck`, `Type=Gel packs`, `Type=Alignment`, `Type=Receiva`, `Type=Corvee`, `Type=Emballage` …
- **Task icons - 64px** — 29 variants
  - `Type=Counting, Platform=Armscanner`, `Type=Preloading, Platform=Wallscanner`, `Type=Smart Refill, Platform=Armscanner`, `Type=Indirect picking Z, Platform=Wallscanner`, `Type=Indirect picking Koel, Platform=Wallscanner`, `Type=Activities, Platform=Armscanner` …

### ->  Sound

- **Sounds - Material design** — 7 variants
  - `Feedback=Informative, Type=Delete / Cancel`, `Feedback=Succes, Type=Completing full flow`, `Feedback=Succes, Type=Completing sub-flow / task`, `Feedback=Error, Type=Critical issue`, `Feedback=Informative, Type=Scanning`, `Feedback=Attention, Type=Non-critical issue` …

### -> Button bar ✅

- ** Action Bar** — 2 variants
  - `2 buttons=False`, `2 buttons=True`
- **Action bar - Nadine** _(Nadine)_ — 2 variants
  - `Buttons=Two`, `Buttons=One`
- **Button bar - Pantry** _(Pantry)_ — 6 variants
  - `Amount=3, Divider=False`, `Amount=2, Divider=False`, `Amount=2, Divider=True`, `Amount=1, Divider=True`, `Amount=1, Divider=False`, `Amount=3, Divider=True`
- **Pagination** — 3 variants
  - `Page=1`, `Page=3`, `Page=2`

### -> Buttons

- ** Button** — 12 variants
  - `Type=Secondary, Icon=True, State=DIsabled`, `Type=Secondary, Icon=True, State=Down`, `Type=Secondary, Icon=True, State=Default`, `Type=Primary, Icon=False, State=Default`, `Type=Primary, Icon=False, State=DIsabled`, `Type=Secondary, Icon=False, State=DIsabled` …
- ** Button - Nadine** _(Nadine)_ — 8 variants
  - `Level=Secondary, State=Default, Icon=False`, `Level=Primary, State=Default, Icon=False`, `Level=Secondary, State=Loading, Icon=False`, `Level=Primary, State=Disabled, Icon=False`, `Level=Primary, State=Pressed, Icon=False`, `Level=Secondary, State=Pressed, Icon=False` …
- ** Scan Button** — 2 variants
  - `Size=Big`, `Size=Small`
- ** Small Button** — 6 variants
  - `Type=Secondary, State=Default`, `Type=Primary, State=Default`, `Type=Primary, State=Down`, `Type=Secondary, State=Disabled`, `Type=Secondary, State=Down`, `Type=Primary, State=Disabled`
- **Button - Icon** — 6 variants
  - `Type=Secondary, State=Default`, `Type=Secondary, State=Pressed`, `Type=Primary, State=Pressed`, `Type=Primary, State=Default`, `Type=Primary, State=Inactive`, `Type=Secondary, State=Inactive`
- **Button - P1** — 2 variants
  - `Type=Icon`, `Type=Pagination`
- **Button - scan - Nadine** _(Nadine)_ — 1 variant
  - `🧬 Button - scan - Nadine`
- **Button group - Nadine** _(Nadine)_ — 2 variants
  - `Layout=Horizontal`, `Layout=Vertical`
- **Secondary Button Big** — 2 variants
  - `State=Default`, `State=Prressed`
- **Secondary Button P123 ** — 8 variants
  - `State=Default, Type=Stepper`, `State=Default, Type=Icon`, `State=Pressed, Type=Icon`, `State=Pressed, Type=Stepper` …
- **Secondary Button P123 - Nadine** _(Nadine)_ — 4 variants
  - `State=Pressed, Type=Pagination`, `State=Default, Type=Icon`, `State=Default, Type=Pagination`, `State=Pressed, Type=Icon`
- **Stepper** — 2 variants
  - `Page=1`, `Page=2`
- **Stepper - Nadine** _(Nadine)_ — 3 variants
  - `Page=3`, `Page=1`, `Page=2`
- **Text button** — 2 variants
  - `Property 1=Pressed`, `Property 1=Default`

### -> Callout

- **Call out - feedback** — 4 variants
  - `Size=Large, Feedback=Warning`, `Size=Small, Feedback=Negative`, `Size=Small, Feedback=Warning`, `Size=Large, Feedback=Negative`
- **Call out - feedback - Nadine** _(Nadine)_ — 6 variants
  - `Size=Small, Feedback=Negative`, `Size=Small, Feedback=Information`, `Size=Large, Feedback=Warning`, `Size=Small, Feedback=Warning`, `Size=Large, Feedback=Information`, `Size=Large, Feedback=Negative`

### -> Checkbox & radiobutton ❌ — ❌ marked; confirm with design before using

- ** Input / Checkbox** — 4 variants
  - `Selected=True, State=Default`, `Selected=True, State=Down`, `Selected=False, State=Default`, `Selected=False, State=Down`
- ** Input / Radio** — 4 variants
  - `Selected=False, State=Down`, `Selected=True, State=Down`, `Selected=False, State=Default`, `Selected=True, State=Default`

### -> Counter

- **(ungrouped)** — 2 variants
  - `Number counter - Current`, `Number counter - new`

### -> Dialog

- **🧬 Dialog - Content** — 3 variants
  - App 🧪 Beta component
  - `Type=Type3`, `Type=Quit / Break`, `Type=Buttons`
- **🧬 Dialog - Content [OLD]** **[DEPRECATED]** — 3 variants
  - App 🧪 Beta component
  - `Type=Quit / Break`, `Type=Default`, `Type=Type3`
- **🧬 Dialog - Feedback** — 4 variants
  - App 🧪 Beta component
  - `Type=Succes`, `Type=Information`, `Type=Error`, `Type=Warning`
- **🧬 Dialog - Feedback [OLD]** **[DEPRECATED]** — 4 variants
  - App 🧪 Beta component
  - `Type=Information`, `Type=Warning`, `Type=Succes`, `Type=Error`
- **Crate/Coolbox confirmation** — 1 variant
  - `Modal dialog - Crate/Cool box confirmation`
- **Kuhne + Nagel additional labels** — 1 variant
  - `Modal dialog - Kuhne + Nagel additional labels `
- **Modal dialog - article scan** — 1 variant
  - `Buttons=One`
- **Modal dialog - confirm replacement** — 3 variants
  - `Type=Full crate`, `Type=Cool box`, `Type=Half loadcarriers`
- **Modal dialog - confirmation** — 2 variants
  - `Buttons=One`, `Buttons=Two`
- **Modal dialog - error** — 2 variants
  - `Buttons=Two`, `Buttons=One`
- **Modal dialog - sticker information** — 4 variants
  - `Type=Default, Loading=True`, `Type=Default, Loading=False`, `Type=Heavy weight, Loading=False`, `Type=Heavy weight, Loading=True`
- **Product info** — 1 variant
  - `Modal dialog - product info`

### -> Divider ❌ — ❌ marked; confirm with design before using

- **(ungrouped)** — 1 variant
  - ` Divider`

### -> Header

- **(ungrouped)** — 4 variants
  - ` Header Duo Text`, ` Header (old)`, ` Header`, ` Header + Subheader`

### -> Illustrations

- **EOPK cart** — 2 variants
  - `Type=Mechanized HSC`, `Type=New`
- **Illustrations - 104px** — 1 variant
  - `Type=Barcode`
- **Illustrations - 120px** — 1 variant
  - `Type=Barcode`
- **Illustrations - 148px** — 2 variants
  - `Type=scanBarcode`, `Type=emptyBag`
- **Illustrations - 160px** — 1 variant
  - `Type=Barcode`
- **Illustrations - 72px** — 3 variants
  - `Type=No animal consumption (CAT 2)`, `Type=Animal consumption (CAT 3)`, `Type=Recall (666/999)`
- **Illustrations - 80px** — 8 variants
  - `Type=Barcode`, `Type=Datamatrix`, `Type=Succes`, `Type=Type9`, `Type=Error`, `Type=Cool box` …
- **Scan** — 2 variants
  - `Size=160`, `Size=120`

### -> Input field ❌ — ❌ marked; confirm with design before using

- ** Inputfield** — 3 variants
  - `Type=Focus`, `Type=Filled`, `Type=Inactive`
- **(ungrouped)** — 1 variant
  - `Number input`
- **Input - Text - Nadine** _(Nadine)_ — 1 variant
  - `🧬 Input - Text`
- **Inputfield Listitem I** — 2 variants
  - `State=Inactive`, `State=Default`

### -> List item

- ** List item** — 12 variants
  - `State=Default, Type=Parent, Position=Middle`, `State=Down, Type=Regular, Position=Middle`, `State=Default, Type=Parent, Position=Top`, `State=Down, Type=Parent, Position=Top`, `State=Default, Type=Regular, Position=Middle`, `State=Down, Type=Parent, Position=Bottom` …
- ** List Item / Checkbox** — 12 variants
  - `State=Down, Selected=True, Position=Middle`, `State=Default, Selected=True, Position=Top`, `State=Default, Selected=False, Position=Bottom`, `State=Default, Selected=False, Position=Top`, `State=Default, Selected=True, Position=Bottom`, `State=Down, Selected=True, Position=Top` …
- ** List Item / Radio** — 12 variants
  - `State=Down, Selected=False, Position=Bottom`, `State=Down, Selected=True, Position=Middle`, `State=Default, Selected=True, Position=Top`, `State=Default, Selected=True, Position=Middle`, `State=Down, Selected=False, Position=Top`, `State=Default, Selected=False, Position=Middle` …
- **(ungrouped)** — 1 variant
  - `Listitems Weight`
- **🧬 List item - Image (S)** — 2 variants
  - `State=Disabled`, `State=Default`
- **List item - product - Nadine** _(Nadine)_ — 2 variants
  - `List item`, `List`
- **Listitem** — 8 variants
  - `State=Default, Type=Middle`, `State=Pressed, Type=Down`, `State=Pressed, Type=Top`, `State=Pressed, Type=Center`, `State=Default, Type=Center`, `State=Default, Type=Top` …
- **Listitem/content** — 8 variants
  - `Type=Checkbox`, `Type=Regular`, `Type=Scanning`, `Type=Radiobutton`, `Type=Registry goods`, `Type=Mutating` …

### -> Load carriers

- ** Load Carrier** — 23 variants
  - Adjust the size to visualise different load carrier types.
  - `Type=Whole crate, State=Mapped`, `Type=Bag front, State=Mapped`, `Type=Half crate 2, State=To map`, `Type=Whole crate, State=Not to map`, `Type=Whole crate small 2, State=Mapped`, `Type=Half crate 2, State=Mapped Up` …
- ** Scan indicator** — 3 variants
  - `Property 1=Medium`, `Property 1=Big`, `Property 1=Small`
- **Crate - Nadine** _(Nadine)_ — 19 variants
  - Adjust the size to visualise different load carrier types.
  - `Type=Half loadcarriers, State=Mapped (half), View=Front, Automap=No`, `Type=Half loadcarriers, State=Not mapped, View=Front, Automap=Yes`, `Type=Crate, State=Mapped, View=Top, Automap=Front`, `Type=Half loadcarriers, State=Mapped, View=Front, Automap=No`, `Type=Half loadcarriers, State=Mappe (both halfs), View=Top, Automap=Yes`, `Type=Crate, State=Not mapped, View=Front, Automap=No` …
- **Load_carrier - Nadine** _(Nadine)_ — 6 variants
  - `Type=Bag top, State=Not to map, View=Front`, `Type=Bag, State=Not to map, View=Front`, `Type=Bag top, State=To map, View=Front`, `Type=Bag, State=Mapped, View=Front`, `Type=Bag, State=To map, View=Front`, `Type=Bag top, State=Mapped, View=Front`
- **Scan_indicator - Nadine** _(Nadine)_ — 3 variants
  - `Property 1=Medium`, `Property 1=Big`, `Property 1=Small`

### -> Native

- **Android / Navigation bar - Nadine** _(Nadine)_ — 1 variant
- **Android / Status Bar** — 2 variants
  - `Color=Dark`, `Color=Light`
- **Android / Status Bar - Nadine** _(Nadine)_ — 4 variants
  - `Color=Light, Device=WT6300`, `Color=Dark, Device=WT6400`, `Color=Dark, Device=WT6300`, `Color=Light, Device=WT6400`

### -> Numpad

- ** Numpad** — 2 variants
  - `Type=Disabled`, `Type=Active`
- ** Numpad - Pantry** _(Pantry)_ — 2 variants
  - `Type=Active`, `Type=Disabled`
- ** Numpad / Inputfield** — 5 variants
  - `Type=Type5`, `Type=Active`, `Type=Inactive`, `Type=Letter`, `Type=Active 2`

### -> Overlay

- **(ungrouped)** — 1 variant
  - ` Overlay - Pantry`

### -> Pop-up

- ** Popup** — 4 variants
  - `Type=Action 2`, `Type=Article Info`, `Type=Information`, `Type=Action`

### -> Product details

- **(ungrouped)** — 2 variants
  - ` Indicator / Success`, ` Position`
- **Article info table** — 2 variants
  - `Type=No Amount`, `Type=With amount`
- **Checked table** — 2 variants
  - `State=Empty`, `State=Filled`
- **Counter** — 3 variants
  - `Type=Positive`, `Type=Error`, `Type=Picking`
- **Picking indicator** — 3 variants
  - `Type=Location`, `Type=Second Pick`, `Type=First pick`
- **Product location - Pantry** _(Pantry)_ — 6 variants
  - `Size=S, Color=Default`, `Size=M, Color=Default`, `Size=S, Color=Inverted`, `Size=M, Color=Inverted`, `Size=L, Color=Inverted`, `Size=L, Color=Default`
- **Product Title** — 3 variants
  - `Sub-Items=2`, `Sub-Items=4`, `Sub-Items=Picking`
- **ProductLocation** — 3 variants
  - `Size=XS`, `Size=M`, `Size=S`
- **ProductLocation-Elements** — 4 variants
  - `Type=Rack, Size=Small`, `Type=Path, Size=Default`, `Type=Rack, Size=Default`, `Type=Path, Size=Small`
- **SProductLocation Shelft Colors** — 20 variants
  - `Color=Red, Size=Default`, `Color=Yellow, Size=Default`, `Color=Purple, Size=Default`, `Color=Blue, Size=Default`, `Color=Grey, Size=Default`, `Color=Grey, Size=Small` …

### -> Product page

- **Product Page** — 4 variants
  - `Type=Stock`, `Type=Article info`, `Type=FIlling`, `Type=Picking`

### -> Product picture

- **Product image** — 16 variants
  - `Product=Bananas, Size=200`, `Product=Frozen snack, Size=200`, `Product=Paprika, Size=200`, `Product=Cheese pesto dip, Size=200`, `Product=Yakult, Size=200`, `Product=Cheese pesto dip, Size=48` …

### -> Progress indicator

- **Progress indicator - Linear - Pantry** _(Pantry)_ — 1 variant
  - `Progress indicator - linear - Pantry `

### -> Quiz question

- ** Question** — 3 variants
  - `State=Wrong`, `State=Unfilled`, `State=Good`
- ** Question indicator** — 6 variants
  - `State=Answer 4`, `State=Answer 6`, `State=Answer 5`, `State=Answer 3`, `State=Answer 1`, `State=Answer 2`

### -> Signature

- **Signature** — 2 variants
  - `Type=Writing`, `Type=Submitted`

### -> Slide to unlock

- **🧬 Slider** — 3 variants
  - `Progress=0%`, `Progress=50%`, `Progress=100%`
- **Slider [OLD]** **[DEPRECATED]** — 3 variants
  - `Progress=100%`, `Progress=0%`, `Progress=50%`

### -> Stats

- **(ungrouped)** — 1 variant
  - `Picking stats`

### -> Table

- **(ungrouped)** — 3 variants
  - `Load carrier table`, `Load carrier deviation table`, `Article info table`

### -> Tag

- ** Tag** — 2 variants
  - `Type=Warning`, `Type=Positive`
- **🧬 Tag - icon** — 12 variants
  - `Type=Succes, Size=Medium`, `Type=Succes, Size=Large`, `Type=Neutral, Size=Large`, `Type=Neutral, Size=Small`, `Type=Succes, Size=Small`, `Type=Error, Size=Large` …
- **Label** — 2 variants
  - `Type=Version`, `Type=Bonus`
- **Tag** — 8 variants
  - `Color=Blue, Size=S`, `Color=Blue, Size=XL`, `Color=Light blue, Size=XL`, `Color=Light blue, Size=L`, `Color=Blue, Size=L`, `Color=Blue, Size=M` …

### -> Tiles and cards

- **🧬 Tile - Pantry** _(Pantry)_ — 18 variants
  - `Type=Image, Level=Primary, State=Default, Layout=Horizontal, Button=True`, `Type=Icon, Level=Secondary, State=Disabled, Layout=Vertical, Button=True`, `Type=Icon, Level=Primary, State=Default, Layout=Horizontal, Button=False`, `Type=Icon, Level=Primary, State=Disabled, Layout=Vertical, Button=True`, `Type=Image, Level=Secondary, State=Default, Layout=Horizontal, Button=False`, `Type=Image, Level=Primary, State=Default, Layout=Vertical, Button=True` …
- **Card** — 2 variants
  - `Layout=Vertical`, `Layout=Horizontal`
- **Tile** — 14 variants
  - `Interactive=No, Type=Default, Layout=Vertical, State=Default, Selected=No, Illustration size=80px`, `Interactive=Yes, Type=Default, Layout=Vertical, State=Default, Selected=No, Illustration size=80px`, `Interactive=Yes, Type=Default, Layout=Vertical, State=Default, Selected=Yes, Illustration size=80px`, `Interactive=Yes, Type=Compact, Layout=Vertical, State=Default, Selected=No, Illustration size=72px`, `Interactive=No, Type=Default, Layout=Horizontal, State=Default, Selected=No, Illustration size=80px`, `Interactive=Yes, Type=Default, Layout=Horizontal, State=Default, Selected=Yes, Illustration size=80px` …

### -> Toast

- **Snackbar** — 4 variants
  - `Type=Informative`, `Type=Positive`, `Type=Negative`, `Type=Warning`
- **Toast - Nadine** _(Nadine)_ — 4 variants
  - `Feedback=🟢 Positive`, `Feedback=🟡 Warning`, `Feedback=🔴 Negative`, `Feedback=🔵 Informative`
- **Toast - Pantry** _(Pantry)_ — 1 variant
  - `🧬 Toast with location`

### -> Toggle

- **Toggle** — 2 variants
  - `Type=Negative`, `Type=Postiive`

### -> Volume toggle ✅

- ** Toggle volume** — 4 variants
  - `Volume=High`, `Volume=Low`, `Volume=Medium`, `Volume=Off`
- **🧬 Volume toggle** — 4 variants
  - `Volume level=Low`, `Volume level=High`, `Volume level=Muted`, `Volume level=Medium`

### TEMPLATES

- **(ungrouped)** — 2 variants
  - `ALI / Organism / Keypad with numbers`, `ALI / Organism / Keypad with letters`

### ✅ Header

- **Header - Nadine** _(Nadine)_ — 1 variant
  - `Heading - Nadine`

## Styles

Semantic tokens. Prefer these names over raw values — a hex code in a design
proposal is a defect, because it cannot follow the system when it changes.

### Effects — 1

**Popup**

- `Popup`

### Colour (FILL) — 123

**AH**

- `AH/+2`
- `AH/+3`
- `AH/-1`
- `AH/-2`
- `AH/-3`
- `AH/-4`
- `AH/0`

**Aardbei**

- `Aardbei / +1`
- `Aardbei / +2`
- `Aardbei / -1`
- `Aardbei / -2`
- `Aardbei / -3`
- `Aardbei / -4`
- `Aardbei / 0`
- `Aardbei/+3`

**Avocado**

- `Avocado / +1`
- `Avocado / +2`
- `Avocado / +3`
- `Avocado / -1`
- `Avocado / -2`
- `Avocado / -3`
- `Avocado / -4`
- `Avocado / 0`

**Base**

- `Base / Black / 50%`
- `Base / Black / 80%`
- `Base/Black / 100%`
- `Base/White / 100%`

**Bonus**

- `Bonus / +1`
- `Bonus / +2`
- `Bonus / +3`
- `Bonus / -1`
- `Bonus / -2`
- `Bonus / -3`
- `Bonus / -4`
- `Bonus / 0`

**Braam**

- `Braam / +1`
- `Braam / +2`
- `Braam / +3`
- `Braam / -1`
- `Braam / -2`
- `Braam / -3`
- `Braam / -4`
- `Braam / 0`

**Chocolade**

- `Chocolade / +1`
- `Chocolade / +2`
- `Chocolade / +3`
- `Chocolade / -1`
- `Chocolade / -2`
- `Chocolade / -3`
- `Chocolade / -4`
- `Chocolade / 0`

**Drop**

- `Drop / +1`
- `Drop / +2`
- `Drop / +3`
- `Drop / -1`
- `Drop / -2`
- `Drop / -3`
- `Drop / -4`
- `Drop / 0`

**Haring**

- `Haring / +1`
- `Haring / +2`
- `Haring / +3`
- `Haring / -1`
- `Haring / -2`
- `Haring / -3`
- `Haring / -4`
- `Haring / 0`

**Mokka**

- `Mokka / +1`
- `Mokka / +2`
- `Mokka / +3`
- `Mokka / -1`
- `Mokka / -2`
- `Mokka / -3`
- `Mokka / -4`
- `Mokka / 0`

**Olijf**

- `Olijf / +1`
- `Olijf / +2`
- `Olijf / +3`
- `Olijf / -1`
- `Olijf / -2`
- `Olijf / -3`
- `Olijf / 0`
- `Olijf/-4`

**Pistache**

- `Pistache / +1`
- `Pistache / +2`
- `Pistache / +3`
- `Pistache / -1`
- `Pistache / -2`
- `Pistache / -3`
- `Pistache / -4`
- `Pistache / 0`

**Salmiak**

- `Salmiak / +1`
- `Salmiak / +2`
- `Salmiak / +3`
- `Salmiak / -1`
- `Salmiak / -2`
- `Salmiak / -4`
- `Salmiak / 0`
- `Salmiak/-3`

**Vanille**

- `Vanille / +1`
- `Vanille / +2`
- `Vanille / +3`
- `Vanille / -1`
- `Vanille / -2`
- `Vanille / -3`
- `Vanille / -4`
- `Vanille / 0`

**Walnoot**

- `Walnoot / +1`
- `Walnoot / +2`
- `Walnoot / +3`
- `Walnoot / -1`
- `Walnoot / -2`
- `Walnoot / -3`
- `Walnoot / -4`
- `Walnoot / 0`

**Water**

- `Water / +1`
- `Water / +2`
- `Water / +3`
- `Water / -1`
- `Water / -2`
- `Water / -3`
- `Water / -4`
- `Water / 0`

### Typography (TEXT) — 42

**Inter**

- `Inter/10/Bold`
- `Inter/12 (subtext and link-2)/Medium`
- `Inter/12 (subtext and link-2)/Regular`
- `Inter/12 (subtext and link-2)/Semi Bold`
- `Inter/12 (subtext and link-2)/SemiBold`
- `Inter/12 (subtext and link-2)/👉 Bold`
- `Inter/12 (subtext and link-2)/👉 Extra Bold`
- `Inter/12 (subtext and link-2)/👉 Regular`
- `Inter/13/Bold`
- `Inter/13/DemiBold`
- `Inter/13/Extra Bold`
- `Inter/13/Regular`
- `Inter/14 (body compact)/DemiBold`
- `Inter/14 (body compact)/Medium`
- `Inter/14 (body compact)/👉 Bold`
- `Inter/14 (body compact)/👉 Regular`
- `Inter/16 (body and link-1)/Medium`
- `Inter/16 (body and link-1)/SemiBold`
- `Inter/16 (body and link-1)/👉 Bold`
- `Inter/16 (body and link-1)/👉 Extra Bold`
- `Inter/16 (body and link-1)/👉 Regular`
- `Inter/16 (button)/👉 Regular`
- `Inter/16 (button)/👉 SemiBold`
- `Inter/18 (heading-3)/Medium`
- `Inter/18 (heading-3)/Regular`
- `Inter/18 (heading-3)/SemiBold`
- `Inter/18 (heading-3)/👉 Bold`
- `Inter/20 (heading-2)/Bold`
- `Inter/20 (heading-2)/Medium`
- `Inter/20 (heading-2)/Regular`
- `Inter/20 (heading-2)/Semi Bold`
- `Inter/20 (heading-2)/👉 Extra Bold`
- `Inter/22/Bold`
- `Inter/22/Medium`
- `Inter/22/SemiBold`
- `Inter/24 (heading-1)/Bold`
- `Inter/24 (heading-1)/Medium`
- `Inter/24 (heading-1)/Regular`
- `Inter/24 (heading-1)/Semi Bold`
- `Inter/24 (heading-1)/👉 Extra Bold`
- `Inter/28/Bold`
- `Inter/32 (display)/Bold`

## What this file does not tell you

- **Why** a component exists or when it was chosen over another. Ask design.
- **Pixel geometry.** Sizes, spacing and layout live in the Figma frames.
- **Whether a component is right for overstapelen.** The library serves
  several flows across Armscanner and Wallscanner; not everything applies.
- **How a component behaves.** Variant axes hint at states, but interaction
  detail is in the designs file and in the flows.

