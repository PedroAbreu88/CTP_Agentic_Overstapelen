# 0004 — Read a cart position map from one scan, rather than scanning every crate

**Status:** Accepted — provisionally, on recorded assumptions. See
[Accepted provisionally, 2026-09-11](#accepted-provisionally-2026-09-11).
**Date:** 2026-09-07 (proposed), 2026-09-11 (accepted)

## Context

Stickerfree phase 2 removes the physical sticker that today tells an operator
which strekkar a crate belongs to. The Stack App replaces that signal. *How* it
replaces it is listed as open question 1 in `docs/product-context.md`, and
`docs/decisions/README.md` names it as the ADR this folder was expecting.

It is the decision that shapes everything else. It sets the interaction cost per
cart, determines whether the system can tell you what actually happened, and
decides how much the design depends on the physical world matching the database.

Two things forced it now. A draft screen was sketched that assumes one of the
two answers, and design work is about to start against it — an assumption made in
a drawing and never written down is the expensive kind. And the surrounding
constraints are unusually restrictive: an arm-mounted scanner with both of the
operator's hands full, a fixed 72px button bar leaving 232px of content at
534×320, and a workforce that is roughly 92% flex, so no design may rest on an
experienced operator.

## Options considered

### (a) Scan every crate

The operator scans each crate and the app answers "strek 7".

Unambiguous: the app never has to assume anything about the physical world,
because every crate is identified at the moment it is handled. It produces a
complete audit trail, so a mis-sort is detectable at the moment it happens rather
than at the customer's door. It also degrades gracefully — a crate that has been
moved, added, or swapped is simply scanned and answered correctly.

Rejected on interaction cost. It adds a scan per crate to a process that is
currently one glance per crate, on a device worn on the arm while both hands lift
crates. The risk named in the existing Confluence proposal — *"interaction slower
than reading a sticker, so operators work around the app"* — applies most
directly here. An app that is slower than the sticker it replaced does not get
used, and an unused app has no audit trail either.

### (b) Read a position map from one scan (proposed)

The operator scans any crate on the cart. The app resolves the cart and batch,
then draws the cart as a grid: one cell per position, each showing the strek that
position's crate belongs to.

The interaction cost is one scan per cart rather than one per crate, and the
information is glanceable — which is what an arm-mounted screen is good at. It
uses the pick-cart mapping that already exists, so it adds no new data capture
anywhere.

The cost is that correctness now depends on the physical world matching the map.
If a crate is not in the position the map claims, the app is confidently wrong,
and nothing detects it. That is a genuinely worse failure than no app at all,
because a wrong answer is trusted where an absent one is questioned.

### (c) Position map, plus one confirming scan per strekkar

A middle option: the operator reads the map to work, but scans one crate as each
strekkar is completed. Interaction cost is one scan per strek — typically a
handful per cart rather than one per crate — and it buys back a coarse audit
trail and a check that the map was not systematically wrong.

Not proposed for Phase 1, but this is the option to reach for first if floor
observation shows position drift is real. It is deliberately recorded here
because it is the cheapest available correction, and it only stays cheap if
Phase 1 does not architect it away — see *Consequences*.

## Decision

> **Superseded on 2026-09-11.** This section records the original *Proposed*
> decision and is kept for the reasoning. The status is now **Accepted,
> provisionally** — see [Accepted provisionally,
> 2026-09-11](#accepted-provisionally-2026-09-11) for what changed and on which
> assumptions.

**Proposed:** option (b), the position map, for Phase 1.

Marked *Proposed*, not *Accepted*, for a specific reason: `docs/product-context.md`
says this question "should be settled by observing the floor", and no floor
observation has happened. What has happened is that a direction was chosen in a
draft design, which is a weaker basis. Recording it as *Proposed* keeps that
distinction visible rather than letting a sketch harden into a decision by
default.

It should be confirmed or reversed after observing overstapelen at one manual and
one mechanised HSC, against one question above all others: **do crates stay in
their picked positions between picking and the strekkenplein?** If they do not,
option (c) is the fallback and option (a) is the safe retreat.

### Relationship to ADR 0003

[ADR 0003](0003-pilot-cell-squad-shape.md) argues for a small pilot cell on the
grounds that most of the work is blocked on evidence rather than capacity, and
cites this question as the clearest example. **That argument is unchanged.** A
proposed direction is not the evidence it asks for — the floor observation has
still not happened, and until it does, staffing up to build against this remains
building efficiently in a direction nobody has checked.

## Consequences

**Easier.** One scan per cart. The screen is glanceable, which suits a device
worn on the arm and read between lifts. No new data capture is required
anywhere upstream.

**Harder — and accepted as a cost.** There is no per-crate audit trail. The app
cannot tell whether the crate the operator picked up was the one the map
described, so a mis-sort is still discovered at the customer's door. We accept
this for Phase 1 in exchange for an interaction fast enough to actually be used.

**Cart orientation becomes correctness-critical.** A position map is only right
if the operator and the app agree which end of the cart is which. Approached from
the far end the map is mirrored, and every cell is wrong in a way that looks
entirely plausible. The draft screen anchors this with a wheel graphic; whatever
the final form, orientation is a safety-critical element and not decoration.

**Encoding must not rest on colour alone.** The draft distinguishes streks by
cell colour with the strek number as redundancy. The number is doing the load
bearing work and must stay: adjacent streks render as similar hues, the
environment is cold and glare-prone, and around 8% of male operators have some
colour vision deficiency — against a workforce that is ~92% flex and cannot be
trained around it.

**Keep the confirmation step reachable.** Option (c) is only cheap if Phase 1
treats "how completion is confirmed" as a step in the flow rather than an
assumption baked into the screen. This is the same discipline
`docs/product-context.md` already asks for around cart mapping and Phase 2: keep
the seam, so the correction stays small.

**If this proves wrong.** Reversing to (a) after build means changing the central
screen and the interaction model, but not the data model — the cart manifest is
the same read either way. That is the main thing keeping this decision
affordable to get wrong, and it is worth preserving deliberately.

## New evidence, 2026-09-11 — an existing pattern we did not know about

This ADR was written believing the position map had no precedent in the design
system to be measured against. **That was wrong**, and the evidence arrived
after the decision was recorded, so it is appended here rather than rewritten
into the reasoning above.

`↳ Adding products to orders` in the Armscanner designs file contains a complete
load-carrier flow, in Dutch and English at equal fidelity:

| Screen | NL title |
| --- | --- |
| `Cart_overview` | *Karoverzicht* |
| `Select_cart` | *Selecteer een kar* |
| `View_contents` | *Overzicht van inhoud* |
| `Verify_load_carrier` | *Inhoud ladingdrager* |

**`Verify_load_carrier` is the same question this ADR asks** — how does an
operator confirm what is on a load carrier? — and it answers it as a **scrolling
list of full-width rows with a checkbox**, not as a spatial map. Rows are 486
wide and 72 or 96 tall, so two to three are visible in the 232px content region.

This does not reverse the decision, and it should not be read as doing so. The
argument for the map is unchanged: a list of crate identities is not glanceable
between lifts, and the operator's problem is *where a crate goes*, not *what is
on the cart*. Those are different questions, and the existing pattern answers
the other one.

What it does change is the standard of proof. Option (b) is now a **departure
from an established pattern** rather than the only available shape, so:

- The floor observation should also ask whether operators would accept a list.
  If crates are handled one at a time and read individually, the existing pattern
  may simply be correct, and cheaper.
- Any proposal for the map must say explicitly why `Verify_load_carrier` is not
  sufficient. "There was no precedent" is no longer available as a reason.
- `Load Carrier` in the component library already models crates on a carrier —
  23 variants, whole and half crates and bags, with `To map` / `Mapped` /
  `Not to map` states, and `Mapped Up` / `Mapped Down` / `Mapped Full` for half
  crates that stack two high. **Cart positions are therefore not a uniform grid
  of identical cells.** Any map must extend this component rather than invent a
  tile, and the stacking states in particular have no equivalent in a flat grid.

The `Mapped Up Scan down` variant is worth understanding before treating option
(b) as settled: it describes a per-position scanning interaction, which is closer
to option (c) than to (b). Someone has already drawn part of the fallback.

## Accepted provisionally, 2026-09-11

**Decision: option (b) is Accepted for Phase 1, on the assumptions listed below,
pending floor confirmation.**

Be clear about what changed, because it is *not* that the evidence arrived. The
original source brief and the draft screen it describes were read in full on
2026-09-11 (the screen is reproduced at
[`../images/draft-position-map.png`](../images/draft-position-map.png), and the
brief is summarised in `docs/product-context.md`). They answered two of the four
questions that were blocking the design of screen 3 — but they are the *origin*
of the position-map hypothesis, not independent support for it. Re-reading the
document that proposed something cannot confirm it.

What changed is the **posture**, taken deliberately: we accept the assumption
risk now so that design and specification work can proceed, rather than holding
seven unblocked screens hostage to a floor visit that has not been scheduled.
That is a judgement about sequencing, not a claim that the question is answered.

Recording it this way — Accepted, with the assumptions enumerated and a named
reversal trigger — is the honest form. The failure mode this ADR was written to
prevent was an assumption **made in a drawing and never written down**. Writing
it down is the mitigation; refusing to proceed was never the only one.

### The assumptions we are now building on

Each is provisional. Each is a thing the floor visit must check.

| # | Assumption | Source | If false |
| --- | --- | --- | --- |
| A1 | Crates stay in their picked positions between picking and the strekkenplein | Assumed by the draft; never observed | Option (c), then (a). This is the load-bearing one. |
| A2 | A picking cart has **18 positions**, in a 3×6 grid | Counted from the draft screen | Layout and legibility budget change; ≤8 is easier, >18 breaks the no-paging assumption |
| A3 | A cart typically spans about **4 streks** | Four distinct values (5, 6, 7, 9) in the draft | Beyond ~4, colour stops distinguishing and the number carries it alone |
| A4 | The operator approaches the cart from a consistent end, and the drawn cart graphic resolves the rest | Draft anchors with a wheel and handle | Mirrored maps; needs an orientation confirmation step |
| A5 | Position carries a **weight flag** (`> 10kg`) alongside the strek number | Legend and per-cell warning triangles in the draft | Cell design has spare room; no loss |

A2 in particular contradicts something this repository previously asserted.
`docs/phase-1-screens.md` warned that at 18 positions "the strek numbers stop
being readable within the 232px content region". The draft renders 18 positions
at approximately device proportions and they are legible. **The density concern
was overstated**, and that correction is worth keeping — it was an inference
presented with more confidence than it had earned.

### What reverses this

Unchanged from the original decision, and now the only question that blocks it:

> **Do crates stay in their picked positions between picking and the
> strekkenplein?**

Observed at one manual and one mechanised HSC. If they do not, option (c) is the
fallback and option (a) is the safe retreat. Every *Consequences* item above
still applies — in particular **keep the confirmation step reachable**, which is
what keeps this decision affordable to get wrong.

### What this does not change

- **ADR 0003 still stands.** Accepting a direction provisionally is not the
  evidence it asks for. The floor observation has still not happened, so staffing
  up to build against this is still building efficiently in an unchecked
  direction.
- **The `Verify_load_carrier` question is still open.** Design still owes us an
  answer to *why a map rather than the established list*. Accepting (b) does not
  retire that; it just stops it blocking specification work.

