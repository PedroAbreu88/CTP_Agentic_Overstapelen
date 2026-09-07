# Operations context — the organisation the Stack App runs inside

`docs/product-context.md` explains the app. This document explains the **operation
it lands in**: where overstapelen sits in the Albert Heijn process chain, who
actually performs it, which systems already hold the data, and who has to agree
before anything changes on the floor.

It exists because that knowledge lives in a different repository owned by a
different team, and a repository cannot depend on a network call to explain
itself.

## Provenance

| Field | Value |
| --- | --- |
| Source repository | [`RoyalAholdDelhaize/ah-product-toolkit`](https://github.com/RoyalAholdDelhaize/ah-product-toolkit) (internal) |
| Files read | `context/context-hsc-processes.md`, `context/context-hsc-processes-detail.md`, `context/context-persona-e-commerce-operations.md` |
| Commit read | `ac8defa0b804d41410b51acf77f35ae16c76aa7d` |
| Upstream owner | Dirk de Vries, Albert Heijn E-commerce |
| Upstream `CODEOWNERS` | `@RoyalAholdDelhaize/technl-ctp-team-fulfillment` |
| Upstream status | `draft` — process docs v2.0, effective 2026-03-05; personas last updated 2026-06-24 |
| Ultimate source | *Fulfilment - Processes & systems v2.pdf*, HSC Operations Manual, CWMS technical documentation, HR job descriptions |

**We changed nothing there and should not.** That repository is a Product Owner
toolkit — skills, templates and shared context for POs — not a specification for
this app. It is the system of record for the material below; this file is a
distillation for the parts that bear on the Stack App. When the two disagree,
upstream wins, and this file should be re-derived rather than argued with.

### Reliability, honestly

Not all of the source carries the same weight, and treating it as uniform would
be a mistake:

- Role descriptions **Districtmanager → Planner** come from official HR job
  descriptions. Reliable.
- Roles **Facility Coordinator onwards** are explicitly marked *AI-generated from
  process analysis, requires review and validation*. Do not build on them.
- Both process documents are marked `status: draft`.
- Everything is *current-state* description. None of it anticipates Stickerfree
  phase 2.

## Where overstapelen sits in the process chain

The operation runs nine process domains under **CWMS** (Consumer Warehouse
Management System): Inbound, Filling, Order Picking, Outbound, Quality, Circuit
Management, Assets, Safety, Administration.

Our app sits at the boundary between the third and fourth:

```text
Filling → Order Picking → [ Finishing ] → Outbound → Loading & delivery
                                ↑
                        the Stack App
```

The single most useful sentence in the source, for us:

> *"Finishing transfers totes from pick carts to delivery carts based on holding
> area needs."*

That is **overstapelen**, described in the operation's own vocabulary. Two
consequences:

1. **The process has an existing name and an existing role owner.** In CWMS
   language the process is *Finishing* and the role is **Finisher**, alongside
   Picker, Allrounder/Runner, Process Lead and Team Lead. Our documentation says
   "the operator". Searching Confluence, Jira or CWMS documentation for
   *overstapelen* alone will miss material filed under *Finishing*.
2. **Our terminology and theirs differ.** They say *totes* and *delivery carts*;
   we say *kratten* and *strekkarren*. Same objects. Worth stating explicitly
   before someone concludes there are two processes.

Preceding step, and directly relevant to open question #1:

> *"Picker links totes to cart positions and follows scan flow: item scan,
> location scan, repeat."*

So **tote → cart position linkage already exists in CWMS today**. That is the
mechanism a "position map from one scan" would rest on — it does not have to be
invented, only read and trusted. Whether it is trustworthy *at the moment of
overstapelen*, after handling and transport, is still a floor question, not a
desk one.

## Who actually does this work

The reporting line around our user, from the org structure:

```text
VP e-Commerce Operations
└── Districtmanager e-Commerce Operations (9 FTE)
    ├── Manager HSC Fulfilment (9 FTE)
    │   └── Teamlead Fulfilment
    │       ├── Floor Operator (Meewerkend Voorman)
    │       └── Shopper (I / II)
    └── Proces Lead Manueel & Mechanisatie
```

The HR task lists make the identification concrete. Under *Ondersteunende taken*
for **Shopper I / Allrounder / Floor Operator**:

> *"Voorbereiding: kratten uitklappen, ladingdrager op pickkar, **stickers**,
> karren op strek"*
> *"Afhandeling: karren op strek klaarzetten"*

**The sticker step we are removing is written into the official job
description.** Stickerfree phase 2 therefore has an HR and training artefact to
update, outside this repository and outside our control, but on someone's
critical path. Worth naming early rather than discovering at go-live.

| Role | Relevance to us |
| --- | --- |
| **Shopper I / II** | Performs picking and the supporting overstapelen tasks. Primary user. |
| **Allrounder / Floor Operator** | Same tasks plus quality, counting, second-pick, and **onboarding new staff**. Our first-line trainer and likeliest pilot participant. |
| **Teamlead Fulfilment** | Briefs shoppers and allrounders each shift, handles incidents. Owns the fallback in practice. |
| **Proceslead Manueel** | Chairs the HSC day-start, monitors production, steers disruptions. Gatekeeper for changing the manual flow. |
| **Proceslead Mechanisatie** | MHSC-only. Owns mechanised disruptions and **vendor coordination** (Autostore, robot picking). Gatekeeper for anything touching the reject lane in phase 2. |
| **Manager HSC Fulfilment** | Accountable for fulfilment results and compliance; runs the full employee cycle. |

### The 92% number

Manager HSC Fulfilment and Teamlead Fulfilment both carry the split **vast : flex
= 8% : 92%**, and the source's own summary notes a flex workforce "ranging from
40–92%".

This is the most design-relevant fact in the entire source, and it is not in
`docs/product-context.md`.

Roughly nine in ten people using this app are flexible staff, from agencies the
Teamlead onboards continuously. It follows that:

- **Training cannot be a dependency.** Any design whose safety rests on "the
  operator was trained" is resting on a population that turns over constantly.
- **The app must be self-evident on first use**, in the cold, in gloves, on a
  534×320 screen, glanced at between crate lifts.
- **Error recovery must be obvious to a first-day user**, not just to an
  experienced one.
- Adoption and error-rate measurements must distinguish new staff from
  experienced staff, or the pilot will measure the wrong thing.

This sharpens rather than contradicts what `product-context.md` already says
about the device and the environment.

## Systems already in play

| System | What the source says | Why we care |
| --- | --- | --- |
| **CWMS** | The warehouse management system across all nine domains; picking application; holds the tote → cart position link | Leading candidate for the authoritative crate → strek assignment (open question #2) |
| **BOFF** | Status and NA (not-available) tooling; outbound holding-area checks validate expected totes against **BOFF lists** | Second candidate, and already the system that answers "which totes should be here" |
| **Swisslog / Autostore / robot picking** | Mechanised HSC automation, vendor-supported | Owns the reject lane that phase 2 addresses |
| **SLOT** | Slotting integration used by Filling | Upstream; not ours |
| **DAPP, ATN route forms, manifests** | Outbound and carrier documentation | Downstream; not ours |

Neither CWMS nor BOFF is confirmed as *the* source of the crate → strek
assignment — the source document describes processes, not data ownership. But
open question #2 is now a short list to verify rather than an open field.

## Sites

Mechanised HSCs are named: **Swisslog at Barendrecht and Zwolle**. All others are
manual, using handheld scanner-based picking.

`product-context.md` says the app is most valuable in mechanised sites, and
phase 2 (reject lane) only exists there. So the pilot-site question (#5) is
effectively a choice between Barendrecht and Zwolle for the mechanised case —
subject to the caveat that a mechanised pilot pulls in Swisslog vendor
coordination, while a manual site does not.

## Baselines we can measure against

Published targets, useful as the "before" side of a pilot (#5):

| Process | Metric | Target |
| --- | --- | --- |
| Order Picking | Pick accuracy | > 99.5% |
| Outbound | Load time per batch | < 15 min |
| Circuit Management | Count accuracy | > 99.8% |
| Quality | HACCP compliance | 100% |

A mis-sorted crate degrades pick-to-delivery accuracy and shows up in Outbound
holding-area checks against BOFF lists. Those checks are the existing detection
mechanism for exactly the failure this app prevents — which makes them a
plausible measurement point that needs no new instrumentation.

## Who has to agree before the floor changes

The source is explicit about change impact, and it maps almost exactly onto our
rollout:

- **Order picking changes** are core and affect all fulfilment targets; they
  require **training all pickers and allrounders**. Against a 92% flex workforce,
  that is a recurring cost, not a one-off event.
- **Mechanised HSCs require vendor coordination (Swisslog)**; manual HSCs are
  "easier to update and customize per location".
- **Safety changes need HSC management and H&S approval.**
- **Outbound changes affect delivery SLAs**; notify logistics and DAPP teams.

Read together with `product-context.md`'s requirement for an agreed fallback when
the app is unavailable (#4): the fallback is not a technical decision. It is an
agreement with the **Proceslead** and **Teamlead Fulfilment**, who are the people
who actually steer disruptions during a shift.

## What this does not answer

Being clear about this matters more than the material it does answer. Of the six
open questions in `product-context.md`, the source moves three and leaves three
untouched:

| # | Question | Effect |
| --- | --- | --- |
| 1 | Scan every crate, or position map? | **Narrowed.** Tote → cart position linkage exists in CWMS. Still needs floor observation to know if it survives to overstapelen. |
| 2 | Authoritative source of crate → strek | **Narrowed.** CWMS and BOFF are the candidates. Data ownership unconfirmed. |
| 3 | Stable scannable crate identifier post-sticker | **Untouched.** Current-state docs describe a world with stickers. |
| 4 | Fallback when the app is unavailable | **Owner identified** (Proceslead / Teamlead Fulfilment), content still undecided. |
| 5 | Pilot HSC and baseline | **Narrowed.** Barendrecht or Zwolle if mechanised; baseline metrics above. |
| 6 | Is phase 2 committed? | **Untouched.** A programme decision, not an operational one. |

## Re-reading the source

Read-only, and never from inside this repository:

```bash
git clone --depth 1 https://github.com/RoyalAholdDelhaize/ah-product-toolkit.git \
  /tmp/ah-product-toolkit
```

Requires access to the internal `RoyalAholdDelhaize` organisation. If the upstream
documents move past commit `ac8defa`, re-derive this file rather than patching it
— the point of recording the SHA is to make that check cheap.

The same repository also holds Product Owner **templates** (user story,
refinement, release note) and a `jira-and-confluence-agent` profile. Not distilled
here because they are ways-of-working rather than product context, but they are
the natural starting point if we formalise refinement for this app — the
refinement template's *Definition of Ready* already asks for testable acceptance
criteria, known dependencies, identified risks and monitoring, which is a
reasonable bar for work on a process the floor cannot stop for.
