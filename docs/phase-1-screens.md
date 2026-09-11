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
| 1 | **Scan prompt** | Resting state. Tells the operator to scan any crate on the cart. | **Ready** |
| 2 | **Scanning / resolving** | Feedback between scan and answer. May be sub-second and not a screen at all. | **Ready** |
| 3 | **Position map** | The cart drawn as positions, each showing its strek. The core screen. | **Blocked** — ADR 0004 unconfirmed, *and* cart geometry |
| 4 | **Cart complete** | Confirms the cart is empty and returns to (1). | **Ready** |
| 5 | **Unknown crate** | Scanned crate resolves to no cart. | **Blocked** — no error precedent |
| 6 | **Wrong cart** | Scanned crate belongs to a different cart than the one in progress. | **Blocked** — no error precedent |
| 7 | **Cart already done** | The cart was already emptied, by this operator or another. | **Blocked** — needs a decision |
| 8 | **Backend unavailable** | What the operator sees when the app cannot answer. | **Blocked** — open question 4 |
| 9 | **Interruptions** | Break, quit, resume, freezer check. | **Ready** — reuse, do not invent |

Nine, of which four are ready and five are blocked — and the blocked ones are
not evenly weighted. Screen 3 is the product; screens 5–8 are the difference
between an app the floor trusts and one it works around.

## What each blocker actually is

### Screen 3 — an unconfirmed decision, and two numbers nobody has

**First, this screen may not be the right screen at all.** ADR 0004 is
*Proposed*, not *Accepted*. It is confirmed or reversed by observing whether
crates stay in their picked positions between picking and the strekkenplein. If
they do not, option (c) — a confirming scan per strekkar — becomes the design,
and option (a) is the safe retreat. Cart dimensions do not unblock this screen
on their own.

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

### Screens 5–7 — there is no error precedent to follow

The `00. System states` page in Figma is **empty**. No error, warning or
degraded state has been designed for any Armscanner flow, so whoever specifies
these is proposing the first of their kind. `Toast - Nadine` and `Toast -
Pantry` exist as components; nothing shows when or how they are used.

This needs design's involvement rather than ours alone. It is a house-style
decision with consequences well beyond overstapelen.

Screen 7 additionally needs a **product** decision, not a design one: if a cart
is already marked done, is that an error, a warning, or simply information? The
answer depends on whether two operators can work the same strekkenplein at once,
which nobody has confirmed.

### Screen 8 — the same hole as open question 4

`docs/product-context.md` asks what the agreed fallback is when the app is
unavailable, and lists *"the floor does not stop"* as non-negotiable. Until
Operations agrees the fallback, this screen cannot be specified — it is a
screen that describes a process we have not defined.

## What can be done now, and why it is worth doing

Screens 1, 2, 4 and 9 do not depend on cart geometry or on ADR 0004 being
confirmed. They are the frame around the map: how the operator starts, how they
know the app heard them, how they finish, and what happens when they take a
break.

Specifying them has a second benefit. They exercise the conventions — physical
key bindings, bilingual copy, the 232px budget, the modal interruption pattern —
against a real flow, which is the cheapest way to find out whether
`docs/ui-patterns.md` is actually sufficient to design from.

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

6. Who owns the error and degraded-state house style, given `00. System states`
   is empty?
7. Which dialog components are current, given `[OLD]` variants are in use?

For Operations:

8. What is the agreed fallback when the app is unavailable?
