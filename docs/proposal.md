# Solution proposal (Agentic)

<!-- toc -->

> [!NOTE]
> **Status: draft for review.** A proposal to react to, not a decided design.
> The core interaction now has a **proposed direction** (see _The core design
> decision_) that needs floor observation to confirm or reverse. Everything
> under _Open questions_ still needs Operations and Stickerfree input before
> this can be estimated.

## Summary

The **Stack App** (_overstapelen_) supports the manual step where picked crates
are moved from a picking cart onto the correct _strekkar_. Today the operator
reads a physical sticker on each crate to know where it goes. **Stickerfree
phase 2 removes that sticker**, and the remaining options are all bad: reprint
stickers (defeats the programme), work from a paper list (slow, error-prone), or
guess. A mis-sorted crate surfaces at the customer's door as a wrong or missing
order -- long after the cheap moment to catch it.

The information is not missing. **The pick cart is already mapped during
picking**, so the system knows which crates are on it and which strek each
belongs to. The app's job is to surface knowledge that already exists, at the
moment and place the operator needs it.

It is deliberately scoped as an isolated application: it supports one physical
process, holds no master data of its own, and can be delivered or withdrawn
without touching the systems around it.

## Glossary

| Term | Meaning |
| --- | --- |
| **Overstapelen** | Transferring picked crates from a picking cart onto their designated strekkar. The process this app supports. |
| **Strek** | A delivery route segment. Every crate is destined for exactly one strek. |
| **Strekkar** | The roll container that collects all crates for one strek. |
| **Strekkenplein** | The floor area where strekkarren are staged and loaded. |
| **HSC** | Home Shopping Centre. Either manual or mechanised. |
| **Reject lane** | Mechanised-HSC lane collecting crates that fell out of the automated flow. |
| **Finishing** / **Finisher** | What the operation itself calls overstapelen and the operator who performs it, in CWMS process language. Material is filed under either term. |

## Scope

| In scope | Out of scope |
| --- | --- |
| Phase 1 -- overstapelen from picking carts | Changing how picking itself works |
| Phase 2 -- reject-lane offloading (mechanised HSC) | Replacing or extending WMS master data |
| Manual and mechanised HSCs | Loading strekkarren onto trucks |
| **Arm-mounted scanners** (Zebra WT6300 / WT6400) | Any customer-facing surface |

## Proposed solution -- Phase 1

| # | Step | What the operator sees |
| --- | --- | --- |
| 1 | Scan **any** crate on the cart | The app resolves the pick cart and batch from that single scan |
| 2 | App loads the cart manifest | The cart drawn as a **position map** -- one cell per position, showing that crate's strek |
| 3 | Operator moves crates to strekkarren | The map stays on screen, read at a glance between lifts |
| 4 | Cart is emptied | Operator confirms completion (`P3`) |

Scanning _any_ crate rather than a designated one is the important detail: no
hunting for a particular crate, and **one scan per cart rather than one per
crate**.

### The main screen

**Schematic, not a design.** This is the structure of the screen -- a cell per
crate position, laid out as the operator faces the cart. Colour groups a strek;
the **number** carries the meaning. The warning marker flags a crate over 10 kg.

```cart-grid
5  5  5! 5  5  5
5! 6  6! 7  7  7
7! 7! 7! 7! 9! 9!
```

> [!WARNING]
> **Draft and partly guesswork.** This was drawn from a hand sketch and from an
> _incomplete_ reading of the Armscanner Figma library -- our agent is still
> learning the library's definitions, and Figma's API rate limit means several
> pages have not been read at all. Cell count, proportions, colours and the
> orientation marker are all placeholders.
>
> **Figma remains the single source of truth for UI.** Nothing here has been
> reviewed by design, and no overstapelen screen exists in Figma yet. Replace
> this schematic with the exported frame once one does. See _A note on the UI
> fidelity of this proposal_ below for what specifically is unread.

Reading the schematic, the elements that matter:

- The cart is drawn as a **grid of cells**, one per crate position, laid out as the operator sees the physical cart.
- Each cell carries its **strek number**. Colour groups cells by strek as a secondary cue -- the number carries the meaning, because cold-store glare and colour vision deficiency make colour alone unsafe.
- A **cart orientation marker** makes it unambiguous which end of the cart the map describes. This is a correctness element, not decoration -- see the risk below.
- A **>10 kg warning marker** flags heavy crates. The component library already carries a _Heavy weight_ variant, so this is an existing concept rather than a new one.
- Actions bind to the **physical keys**: `P3` primary (_Finished_), `P2` secondary (_Close_), `P1` pagination where a cart needs more than one screen. With both hands holding crates, the keys are the primary input and touch is the fallback.

## The core design decision

Step 2 had two plausible designs leading to two different applications. This was
previously the largest open question on this page; it now has a **proposed
direction**.

| Option | Trade-off | Verdict |
| --- | --- | --- |
| **(a)** Scan every crate | Unambiguous, never assumes anything about the physical world, gives a complete audit trail. Costs one scan per crate. | Rejected on interaction cost -- an app slower than the sticker it replaced gets worked around, and an unused app has no audit trail either. |
| **(b)** Position map from one scan | One scan per cart, glanceable, uses mapping that already exists. Depends on crates staying in their picked positions. | **Proposed for Phase 1.** |
| **(c)** Position map plus one confirming scan per strekkar | A handful of scans per cart. Buys back a coarse audit trail and catches a systematically wrong map. | Held in reserve -- the first correction to reach for if floor observation shows position drift is real. |

> [!IMPORTANT]
> **This is proposed, not settled.** It was chosen from a draft design, not from
> watching the floor -- a weaker basis, and worth keeping visible. The
> observation that confirms or reverses it is a single question: **do crates stay
> in their picked positions between picking and the strekkenplein?** If they do
> not, (c) is the fallback and (a) is the safe retreat.
>
> What we accept in exchange for speed: **no per-crate audit trail.** The app
> cannot tell whether the crate the operator lifted was the one the map
> described, so a mis-sort is still found at the customer's door.

The full reasoning, including what each rejected option would have cost, is
recorded as an architecture decision record in the repository:
`docs/decisions/0004-position-map-over-per-crate-scan.md`.

## Proposed solution -- Phase 2 (reject lane)

Crates from the reject lane are loaded onto a picking cart and taken to the
strekkenplein. The flow is identical to Phase 1 with one addition: **the cart was
never mapped by picking**, so the operator maps it while loading.

Because the only real difference is _where the cart mapping comes from_, Phase 2
should be a small extension rather than a second application -- **provided Phase
1 puts cart mapping behind an interface** instead of assuming picking is the only
source. This is the main thing Phase 1 must do to avoid rework.

## Architecture

The app fits the existing platform. Nothing here needs new infrastructure.

| Layer | Choice | Rationale |
| --- | --- | --- |
| Device app | React + Capacitor (Android) | Matches the existing stack; runs on the arm scanners already on the floor |
| Backend | Kotlin service | Consistent with existing services and team skills |
| App state | PostgreSQL | Session and progress state owned by this app |
| Source data | Read from existing systems | Cart, batch and strek assignment are read, never mastered here |
| Delivery | Argo CD on KaaS | Same GitOps pipeline as the rest of the estate |

## Constraints that shape the design

- **The Android app cannot be rolled back.** It ships through Play Store review and old versions stay installed for weeks, so APIs must be **additive-only and versioned**. A breaking change strands scanners on the floor.
- **Database changes follow expand, migrate, contract** (Flyway). Never a destructive change in a single release.
- **The floor does not stop.** A fallback for app unavailability must be agreed with Operations before go-live; operators cannot wait for a fix.
- **The device is worn on the arm.** During overstapelen both hands are lifting crates, so the operator glances at the screen between lifts. Interaction must be minimal, glanceable, and survivable one-handed at best.
- **The screen is small and landscape** -- 534x320 and 640x360 logical. Design for the smaller. The button bar is a fixed 72px, which is 22.5% of the small screen and the single biggest limit on how much fits.
- **The UI is bilingual**, Dutch and English at equal fidelity, informal _je_ rather than _u_.
- **Roughly 92% of the workforce is flex**, with continuous onboarding. **Training cannot be a dependency** -- the app must be self-evident on first use, error recovery included.
- **Scanning happens with gloves, in the cold, at speed.**

## Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Crates moved between positions before overstapelen | The position map is confidently wrong, and nothing detects it. Worse than no app, because a wrong answer is trusted where an absent one is questioned. | The decisive floor observation. Fall back to option (c) or (a) if drift is real. |
| Cart approached from the wrong end | The whole map is mirrored and every cell is wrong in a way that looks entirely plausible. | Treat orientation as a correctness-critical UI element; validate it on the floor, not in a demo. |
| Cart mapping from picking is incomplete or stale | Wrong strek shown, and it is trusted | Validate mapping freshness; fail loudly rather than guessing |
| App unavailable during a shift | Overstapelen halts | Degraded mode agreed with Operations before go-live |
| Interaction slower than reading a sticker | Operators work around the app | Measure against the sticker baseline on the floor, not in a demo |
| Phase 2 assumptions leak into Phase 1 | Rework | Keep cart mapping behind an interface from day one |

## Open questions

1. **Confirm or reverse the position map** by observing the floor -- do crates stay in their picked positions?
2. Which system is the authoritative source of the crate-to-strek assignment, and how is it read?
3. Do crates carry a stable, scannable identifier once stickers are gone?
4. What is the agreed fallback when the app is unavailable?
5. Which HSC is the pilot site, and what baseline do we measure against?
6. Is Phase 2 committed, or deferred until Phase 1 has floor data?

## A note on the UI fidelity of this proposal

> [!WARNING]
> **The screen description above still contains guesswork.** It was composed
> against a _partial_ reading of the Armscanner Figma library, and the gaps are
> known rather than hidden.

- The Figma API is **rate-limited to a handful of calls per week** on the current seat, so the library was read selectively. _System states_ (error and warning handling), _Break / Quit activity_ and _Content guidelines_ have **not** been read -- so error, interruption and copy-tone conventions are inferred, not sourced.
- The `P1`/`P2`/`P3` button mapping is documented in Figma for the **WT6400 only**. Its application to the WT6300 is an inference and needs confirming with design.
- The Picking flow this sits alongside is **largely undrawn** in Figma, so there is less existing precedent to match than assumed.
- The library has **no overstapelen task icon** -- roughly 30 task types exist and none covers overstapelen, strek or transfer. A new icon is a **lead-time item** worth starting early.

Treat the screen as **structurally indicative**. Expect visual detail to change
once the remaining library pages are read and design has reviewed it.

## Suggested next steps

1. **Observe overstapelen on the floor** at one manual and one mechanised HSC -- primarily to answer the position-drift question.
2. Answer open questions 2 and 3; they block any meaningful estimate.
3. Agree the pilot site and the success measure with Operations.
4. Start the overstapelen icon with design, since it carries lead time.
5. Build a thin slice: one cart, one strek, a real arm scanner, real crates.
