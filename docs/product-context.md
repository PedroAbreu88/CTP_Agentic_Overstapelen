# Product context — the Stack App

What this repository is for, in plain terms. Read this before `docs/ci-cd.md`;
that document explains *how* we ship, this one explains *what* and *why*.

> **Status:** early. The problem is well understood, the solution is a draft, and
> several decisions listed under [Open questions](#open-questions) are genuinely
> undecided. Treat anything here not marked as decided as a starting point for
> discussion.

## What we are building

The **Stack App** — Dutch *overstapelen* — is an isolated application that
digitally supports one physical warehouse process. It is part of **Stickerfree
phase 2**.

It holds no master data of its own, changes no upstream system, and could be
withdrawn without unpicking anything around it. That isolation is deliberate and
worth protecting.

## Glossary

The domain is Dutch and the terms do not translate cleanly. They are used
untranslated throughout the code and documentation.

| Term | Meaning |
| --- | --- |
| **Overstapelen** | Transferring picked crates from a picking cart onto their designated strekkar. The process this app supports. |
| **Strek** | A delivery route segment. Every crate is destined for exactly one strek. |
| **Strekkar** | The roll container that collects all crates for one strek. |
| **Strekkenplein** | The floor area where strekkarren are staged and loaded. |
| **HSC** | Home Shopping Centre. Either *manual* or *mechanised*. |
| **Picking cart** | The cart a picker fills with crates. Mapped during picking, so the system knows which crates are on it. |
| **Reject lane** | Mechanised-HSC lane collecting crates that fell out of the automated flow. |
| **Stickerfree** | The programme removing physical stickers from crates. Phase 2 is what creates the need for this app. |

## The problem

Today an operator doing overstapelen reads a **physical sticker** on each crate
to know which strekkar it belongs to. Stickerfree phase 2 removes that sticker.

Without a digital replacement, the remaining options are all bad: reprint
stickers (defeats the programme), consult a paper list (slow and error-prone), or
guess. A mis-sorted crate is expensive — it surfaces at the customer's door as a
missing or wrong order, long after the cheap moment to catch it has passed.

The information itself is not missing. The pick cart is **already mapped during
picking**, so the system knows which crates are on it and which strek each
belongs to. The app's job is to surface knowledge that already exists, at the
moment and place the operator needs it.

## Phase 1 — overstapelen from picking carts

1. The operator scans **any** crate on the cart.
2. The app resolves the pick cart and batch from that single scan.
3. The app shows which strek the crates belong to.
4. The cart is emptied onto the strekkarren.

Scanning *any* crate rather than a designated one is the point: no hunting for a
particular crate, and one scan per cart rather than one per crate.

Applies to manual and mechanised HSCs. Most valuable in mechanised sites, and
anywhere stickers are absent.

## Phase 2 — the reject lane (mechanised HSC)

Crates from the reject lane are loaded onto a picking cart and taken to the
strekkenplein. The flow is identical to Phase 1 with one addition: **the cart was
never mapped by picking**, so the operator maps it while loading.

Because the only real difference is *where the cart mapping comes from*, Phase 2
should be a small extension rather than a second application — **provided Phase 1
puts cart mapping behind an interface** instead of assuming picking is the only
source. This is the main thing Phase 1 should do to avoid rework.

## Constraints that shape the design

These come from the platform (see `docs/ci-cd.md`) and from the physical
environment. They are not negotiable and they rule out otherwise reasonable
designs.

- **The Android app cannot be rolled back.** It ships through Play Store review
  and old versions stay installed on devices for weeks. APIs must be
  **additive-only and versioned**; a breaking change strands handhelds on the
  warehouse floor.
- **Database changes follow expand → migrate → contract** (Flyway). Never a
  destructive change in a single release.
- **The floor does not stop.** If the app is unavailable, a defined fallback must
  already be agreed with Operations. Operators cannot wait for a fix.
- **Scanning happens with gloves, in the cold, at speed.** The UI must be
  readable at arm's length in a hurry. This is not a desktop application.

## Platform

React + Capacitor Android app on warehouse handhelds, Kotlin backend services,
PostgreSQL for app state, existing Oracle data read but never mastered here,
Argo CD GitOps onto KaaS, images in ACR. Full detail in `docs/ci-cd.md`.

## Open questions

These block a meaningful estimate. None should be answered from a desk.

1. **Scan every crate, or read a position map from one scan?** The biggest single
   design decision. Scanning each crate is unambiguous and gives an audit trail
   but costs a scan per crate. A position map is far faster but depends on crates
   staying in their picked positions. This drives throughput, error rate, and
   hardware needs, and should be settled by observing the floor.
2. Which system is the authoritative source of the crate → strek assignment, and
   how is it read?
3. Do crates carry a stable, scannable identifier once stickers are gone?
4. What is the agreed fallback when the app is unavailable?
5. Which HSC is the pilot, and what baseline do we measure against?
6. Is Phase 2 committed, or deferred until Phase 1 has floor data?

## Where things live

| Artefact | Location |
| --- | --- |
| Draft solution proposal | [Confluence — Solution proposal (Agentic)](https://confluence-aholddelhaize.atlassian.net/wiki/spaces/CTPBOFAFFL/pages/151013721984/Solution+proposal+Agentic) |
| Confluence space | `CTPBOFAFFL` |
| How to read/write Confluence | `docs/confluence-access.md` |
| Delivery and environments | `docs/ci-cd.md` |
| Agent working conventions | `AGENTS.md` |

Confluence is the system of record for the proposal itself. This file exists so
the repository can explain its own purpose without a network call.
