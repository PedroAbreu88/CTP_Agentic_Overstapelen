# 0003 — A four-seat pilot cell, gated on floor evidence

**Status:** Proposed
**Date:** 2026-09-07

## Context

The Stack App needs a team that can both deliver it and run it, at a quality bar
where a mis-sorted crate reaches a customer's door. The question was what that
team should look like.

Three things constrain the answer, and only the first was obvious at the outset.

**Most of the work is blocked on evidence, not capacity.** Six open questions in
`docs/product-context.md` remain, and #1 — scan every crate, or read a position
map from a single scan — drives throughput, error rate and hardware needs.
`docs/agent-operating-model.md` already concludes that agents started before it
lands "will build the wrong thing efficiently". The same applies to people. It
also notes that the seams (`web/`, `services/`, `deploy/base`) do not physically
exist yet, so parallel work would collide in empty directories.

**Training is not available as a mitigation.** `docs/operations-context.md`
records an 8:92 vast-to-flex split across HSC Fulfilment, with agency staff
onboarded continuously. Roughly nine in ten users are new. Any design whose
safety depends on an experienced operator is not safe, and no amount of training
budget fixes a population that turns over constantly. This makes interaction
design a first-class, full-time concern rather than a shared specialism — and
adds an obligation nobody was carrying: measuring first-day error rates
separately from experienced-user rates.

**We are building inside CWMS's process domain, not beside it.** Overstapelen is
what CWMS calls *Finishing*. The tote → cart position link already exists
("picker links totes to cart positions"), and BOFF already validates totes at the
outbound holding area. So the scarce input is access to CWMS and BOFF knowledge,
not Kotlin capacity: a team fully staffed on engineering with no CWMS contact
stalls on questions #1 and #2 at any headcount. The floor gatekeepers are
likewise named and shift-based — Proceslead Manueel, Proceslead Mechanisatie
(who also carries Swisslog vendor coordination), Teamlead Fulfilment.

Taken together, the binding constraint is **borrowed access** — to floor time and
to CWMS knowledge. Review capacity, identified in `docs/agent-operating-model.md`
as the constraint on agent work, remains real but is no longer first in line.

## Options considered

### A four-seat pilot cell with two named external dependencies (chosen)

Product owner / floor analyst, a dedicated interaction designer, a full-stack
lead, and a part-time CWMS/BOFF integration analyst. Two external dependencies
named as commitments rather than goodwill: a Proceslead for floor access, and a
CWMS/BOFF contact for data ownership. Scale to five or six once question #1 is
settled and the seams exist.

Targets both scarce inputs directly and keeps engineering headcount proportional
to the number of decisions actually made. The cost is a single full-stack lead —
a bottleneck and a bus factor for as long as the cell lasts.

### Three seats, buying CWMS knowledge as a service — rejected

The same cell without the integration analyst, obtaining CWMS and BOFF answers
through scheduled consultation with the teams that own them.

Rejected as the primary plan, but only narrowly, and it may prove to have been
right. If CWMS data ownership turns out to be well documented, this is a few
conversations and the fourth seat is waste. The reason it was not chosen is that
a dependency without an owner is the one that fails quietly: consultation covers
answering known questions, not discovering that the position link is unreliable
after transport. If the analyst finds the ground firm within a few weeks, drop
the seat rather than defend it.

### A combined "operator experience" seat — rejected

One person owning floor observation, arm-scanner interaction design and adoption
measurement, on the reasoning that all three read the same evidence and splitting
them costs handoffs.

Genuinely attractive, and rejected on availability rather than logic. The
combination — warehouse process observation plus constrained-device interaction
design plus measurement design — is rare enough that requiring it would delay the
cell. It also concentrates the project's highest-risk knowledge in one person. If
such a person is available, this becomes the better option and this ADR should be
superseded.

### A full squad of six or seven now — rejected

Product owner, tech lead, frontend/Capacitor, Kotlin, dedicated UX, QA, and a
permanent integration engineer, staffed immediately.

Rejected because nothing in the operations context argued for acceleration.
Questions #3 (a stable scannable identifier once stickers are gone) and #6
(whether phase 2 is committed) are untouched by anything we have learned, so most
of those seats would wait on decisions rather than make them. It also compounds
the unresolved review problem: `docs/agent-operating-model.md` records that
required approvals are pinned at `0` because the `CODEOWNERS` team is in another
organisation, so more producers do not currently mean more reviewers.

### Leave the earlier three-seat plan unchanged — rejected

Proceed with product owner, full-stack lead and shared UX, treating the
operations findings as background reading.

Rejected because it carries a named, quantified risk with nobody assigned to it.
Shared UX was defensible before the 92% figure; after it, the flex workforce is
the single largest determinant of whether this app works on the floor.

## Decision

Staff a four-seat pilot cell:

| Seat | Owns |
| --- | --- |
| **Product owner / floor analyst** | The six open questions; floor observation; stakeholder relationships; Jira and Confluence |
| **Interaction designer** (dedicated) | Arm-scanner UX built from `docs/design-system.md`; the first-day-user standard; how adoption and error rates get measured |
| **Full-stack lead** | The walking skeleton across `web/` and `services/` until the seams exist and agents can work in parallel |
| **CWMS/BOFF integration analyst** (part-time) | Question #2; whether the tote → cart position link survives handling until overstapelen |

With two dependencies named as commitments:

- **A Proceslead** — floor access, disruption steering, and the fallback
  agreement behind question #4. Proceslead Mechanisatie if the pilot is
  mechanised, which additionally pulls in Swisslog vendor coordination.
- **A CWMS/BOFF contact** — data ownership for the crate → strek assignment.

Deliberately not staffed at this stage: platform, which is borrowed from EEP and
reached only through git; SRE; and dedicated QA, which folds into the scaling
gate rather than preceding it.

**The gate:** add a Kotlin service engineer and a frontend/Capacitor engineer who
owns the Play Store release path once question #1 is settled *and* `web/`,
`services/` and `deploy/base` have content. Both conditions, not either.

## Consequences

**Easier.** Every open question has a named owner, and both slow external
conversations start immediately rather than after staffing completes. Headcount
tracks decisions rather than anticipating them. Once the skeleton exists, the
seams in `docs/agent-operating-model.md` let agent work parallelise without
adding people.

**Harder.** A single full-stack lead is both a throughput bottleneck and a bus
factor. There is no dedicated QA before the gate, so test discipline rests on the
lead and on CI — uncomfortable given that the Android app cannot be rolled back.
A part-time analyst may under-serve the CWMS question if data ownership turns out
to be genuinely murky, in which case integration becomes a workstream and this
ADR should be superseded rather than stretched.

**Accepted costs.** Review capacity stays unresolved: approvals remain pinned at
`0`, automated review is the judgement layer, and that does not improve until the
repository moves under `RoyalAholdDelhaize` and the `CODEOWNERS` team becomes
real. A mechanised pilot at Barendrecht or Zwolle adds vendor lead time that a
manual site would not. And the Stickerfree programme owns an HR and training
artefact — the sticker step appears verbatim in the official job description —
which this cell can flag but cannot close.

**Revisit when** question #1 lands, the CWMS analyst reports on data ownership,
or a combined operator-experience candidate becomes available.
