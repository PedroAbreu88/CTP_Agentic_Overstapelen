# Phase 1 — the screen inventory

What screens overstapelen needs, what each is for, and which are blocked on
something. **This is a scoping document, not a design.** It deliberately
contains no layouts, no component choices and no copy.

That restraint is the point. [ADR 0004](decisions/0004-position-map-over-per-crate-scan.md)
records that the position-map direction was set by a draft screen rather than by
floor observation, and warns that a drawing makes an unconfirmed decision look
settled. Listing the screens is useful now; drawing them mostly is not.

Read with `docs/product-context.md` for the domain and `docs/ui-patterns.md` for
how Armscanner screens are composed.

## The flow, in the operator's terms

The operator arrives at the strekkenplein with a full picking cart, empties it
onto the strekkarren, and moves to the next cart. Phase 1 supports exactly that:

1. Scan **any** crate on the cart.
2. The app resolves the cart and shows where each crate belongs.
3. The cart is emptied.
4. Confirm, and go again.

Everything below is either a step in that loop, a way the loop fails, or an
interruption to it.

## The inventory

`Ready` means it can be specified now. `Blocked` names what it waits on.

| # | Screen | Purpose | Status |
| --- | --- | --- | --- |
| 1 | **Scan prompt** | Resting state. Tells the operator to scan any crate on the cart. | **Ready** — `Collect_default` is the model |
| 2 | **Scanning / resolving** | Feedback between scan and answer. May be sub-second and not a screen at all. | **Ready** |
| 3 | **Position map** | The cart drawn as positions, each showing its strek. The core screen. | **Blocked** — ADR 0004 unconfirmed, *and* cart geometry |
| 4 | **Cart complete** | Confirms the cart is empty and returns to (1). | **Ready** — `Verify_load_carrier` is the model |
| 5 | **Unknown crate** | Scanned crate resolves to no cart. | **Ready** — follow the error toast |
| 6 | **Wrong cart** | Scanned crate belongs to a different cart than the one in progress. | **Ready** — follow the error toast |
| 7 | **Cart already done** | The cart was already emptied, by this operator or another. | **Blocked** — needs a product decision |
| 8 | **Backend unavailable** | What the operator sees when the app cannot answer. | **Blocked** — open question 4 |
| 9 | **Interruptions** | Break, quit, resume, freezer check. | **Ready** — reuse, do not invent |
| 10 | **Onboarding** | Three-screen introduction, shown on first use. | **Ready** — house pattern, see below |

Seven of ten are ready to specify. The three that are not are the ones that
matter: the position map is the product, and screens 7 and 8 are the difference
between an app the floor trusts and one it works around.

**Screen 10 was not in the first version of this list, and should have been.**
Every flow in the designs file ships `Onboarding_1/2/3` — a three-screen
carousel with a 145×145 illustration and `_🖇️Pagination - Pantry`, paged with
`P1`. Against a workforce that is ~92% flex with continuous onboarding, and a
constraint that says training cannot be a dependency, skipping this would be a
deliberate departure from house style. It is also entirely unblocked.

## What each blocker actually is

### Screen 3 — an unconfirmed decision, and two numbers nobody has

**First, this screen may not be the right screen at all** — and there are now
two reasons rather than one.

ADR 0004 is *Proposed*, not *Accepted*. It is confirmed or reversed by observing
whether crates stay in their picked positions between picking and the
strekkenplein. If they do not, option (c) — a confirming scan per strekkar —
becomes the design, and option (a) is the safe retreat.

**And the design system already answers a nearby question differently.**
`Verify_load_carrier` confirms the contents of a load carrier as a scrolling
list with a checkbox, not a spatial map. The map may still be right — *where a
crate goes* is a different question from *what is on the cart*, and only the
first needs to be glanceable — but it is now a departure from an established
pattern, and any proposal has to say why the list is insufficient.

**Second, two numbers.** How many positions does a picking cart have, and how
many streks does a cart typically span? Neither is recorded anywhere in this
repository.

They are not detail. At 8 positions the map is glanceable at a distance; at 18
the strek numbers stop being readable within the 232px content region, and
either the no-paging assumption or the whole position-map approach has to give.
The strek spread decides whether colour can group positions at all — beyond
about four streks, adjacent hues stop being distinguishable in a cold, glare-lit
aisle, and the number has to carry the meaning alone.

Also unresolved, and cheaper to answer: **does the operator always approach the
cart from the same end?** ADR 0004 names cart orientation as
correctness-critical, because a mirrored map is wrong in a way that looks
entirely plausible.

### Screens 5–7 — the error convention already exists

An earlier draft of this document said there was no error precedent. That was
wrong, and the mistake is instructive: `00. System states` is a **section
header** with no children, and its content lives in the `↳ Error toast` and
`↳ Warning` pages listed beneath it. There are 20 screens between them.

The convention is two-tier, and screens 5 and 6 should follow it rather than
invent anything:

- **`🧬 Toast`** in the bottom region, 518×56 at 534 (80 for two lines), for a
  recoverable error the operator corrects and continues past. A
  `🧬 Toast with location` variant pairs an `attention` icon with
  `Product location - Pantry`, so the error can say *where to go* — directly
  useful for "this crate belongs to the cart over there".
- **`🧬 Dialog - Feedback`** as a modal, 502×284, for something that must be
  acknowledged before continuing.

Screen 5 (unknown crate) and screen 6 (wrong cart) are both recoverable, so both
are toasts, and both are specifiable now.

Screen 7 still needs a **product** decision, not a design one: if a cart is
already marked done, is that recoverable (toast) or must it be acknowledged
(modal)? The answer depends on whether two operators can work the same
strekkenplein at once, which nobody has confirmed.

### Screen 8 — the same hole as open question 4

`docs/product-context.md` asks what the agreed fallback is when the app is
unavailable, and lists *"the floor does not stop"* as non-negotiable. The
toast/warning split above covers a **bad scan**; a backend outage is a different
failure, and nothing in the file addresses it. Until Operations agrees the
fallback, this screen cannot be specified — it is a screen that describes a
process we have not defined.

## What can be done now, and why it is worth doing

Screens 1, 2, 4, 5, 6, 9 and 10 do not depend on cart geometry or on ADR 0004
being confirmed. They are the frame around the map: how the operator learns the
flow, starts it, knows the app heard them, recovers from a bad scan, finishes,
and takes a break.

**Almost all of them now have a named model to copy**, which was not true when
this document was first written:

| Screen | Follow |
| --- | --- |
| 1 Scan prompt | `Collect_default` — heading plus *"Scan or add manually"* |
| 4 Cart complete | `Verify_load_carrier` — contents plus a confirming checkbox |
| 5, 6 Scan errors | `🧬 Toast` / `🧬 Toast with location` in the bottom region |
| 9 Interruptions | `↳ Break / Quit activity`, reused wholesale |
| 10 Onboarding | `Onboarding_1/2/3`, three screens paged with `P1` |

That changes the nature of the specification work. It is now mostly **matching
an existing flow**, not inventing one — which is faster, far easier for design
to review, and much less likely to produce something the floor rejects as
unfamiliar.

Screen 9 should be **reuse, not design**. `↳ Break / Quit activity` already
draws break, quit, resume and freezer-check for both device sizes. The only open
question is which dialog components are current, since some of those screens use
`[OLD]` variants the library says not to use.

## Explicitly out of scope for this list

- **Phase 2, the reject lane.** Identical flow with cart mapping from a
  different source. The only thing Phase 1 owes it is putting cart mapping
  behind an interface — an architectural obligation, not a screen.
- **Task selection and division selection.** Whether overstapelen is reached
  through the existing task list is unconfirmed, and `↳ Select division` is
  empty in Figma. Both belong to the surrounding app rather than to this flow.
- **Any per-crate confirmation.** ADR 0004 option (c) adds one scan per
  strekkar and is the named fallback if position drift turns out to be real.
  Not designed now, but the flow should not be shaped so as to make it
  expensive to add later.

## Questions this raises

For the floor visit:

1. How many positions does a picking cart have?
2. How many streks does a typical cart span?
3. Do crates stay in their picked positions between picking and the
   strekkenplein? (ADR 0004's confirming question.)
4. Is the cart always approached from the same end?
5. Can two operators work the same strekkenplein simultaneously?

For design:

6. Does the toast/warning convention extend to a **backend outage**, or does
   that need a third treatment?
7. Which dialog components are current, given `[OLD]` variants are in use —
   including on the `↳ Warning` screens themselves?
8. What were `Load Carrier`'s `To map` / `Mapped` / `Not to map` states drawn
   for, and does a cart-mapping screen exist anywhere we have not looked?
9. **Why is a position map better than `Verify_load_carrier`?** Design has
   already solved "confirm the contents of a load carrier" as a list. We should
   be able to answer this before proposing a map.
10. What are the agreed NL/ENG terms for `strek`, `strekkar` and
    `strekkenplein`? `kar` and `ladingdrager` are already established.

For Operations:

8. What is the agreed fallback when the app is unavailable?
