# Agent operating model

How agent work is divided in this repository, and how it gets reviewed. Read
`docs/product-context.md` first — this document assumes the domain.

## Why the division is what it is

The seams are not invented. Two of the three already exist in CI:
`.github/workflows/ci.yml` filters on exactly `web/**` and `services/**` and
runs a matrix over discovered service directories, and
`.github/workflows/images.yml` discovers exactly `web/Dockerfile` and
`services/*/Dockerfile`. Agents follow those boundaries so that concurrent PRs
touch disjoint files.

The third seam — delivery — is what the other two depend on and neither should
own.

## The agents

Profiles live in `.github/agents/`. Each declares its scope and, more usefully,
what it must *not* touch.

| Agent | Owns | Cannot design around |
| --- | --- | --- |
| **web** | `web/` — React + Capacitor handheld app | The Android app cannot be rolled back; gloves, cold, speed, arm's length |
| **services** | `services/<name>/` — Kotlin, PostgreSQL, Oracle reads | Additive-only versioned APIs; expand → migrate → contract; Oracle never mastered |
| **platform** | `deploy/`, `.github/workflows/` | Git is the only path to the cluster; production ships from an immutable tag |
| **pr-reviewer** | Nothing — read-only | Reports high-confidence defects only; noise costs more than it looks |

## The shared seam

The `web/` ↔ `services/` API contract is the only artefact two building agents
both depend on, and therefore the only place they can silently diverge.

The rule: **services moves first, additively, and tells web.** Web never changes
its side of the contract unilaterally. This follows from the rollback
constraint rather than from taste — handhelds run old builds for weeks, so the
service must satisfy several client versions at once.

## Sequencing

Agents cannot usefully run in parallel until the seams physically exist. With no
`web/`, `services/` or `deploy/base` content, three agents would write into the
same empty directories and collide.

So: **one agent until a walking skeleton exists**, then parallel work along the
boundaries above.

## Review

Review capacity — not code production — is the binding constraint. Adding
building agents without addressing it deepens a queue rather than shortening it.

The gate on `main`:

- **A pull request is required.** No direct pushes.
- **The aggregate `CI` check must pass.** `ci.yml` exposes a single `CI` status
  regardless of which components a PR touches, precisely so branch protection
  can require one thing.
- **Approvals are deliberately not required.** This repository is personally
  owned with a single collaborator, and the team named in `CODEOWNERS`
  (`@RoyalAholdDelhaize/technl-ctp-team-devices-apps`) has no access to it.
  Requiring approvals would deadlock every PR, including an agent's, because
  nobody can approve their own work.

That last point is why **pr-reviewer** matters more than it first appears. With
human approval unenforceable, automated review is the judgement layer in front
of the CI gate rather than a nice-to-have on top of it.

If this repository later moves under the `RoyalAholdDelhaize` organisation, the
`CODEOWNERS` team becomes real, and required code-owner review should be turned
on — at which point pr-reviewer becomes a first pass in front of a human again,
which is the healthier arrangement.

## Preview environments

`deploy/preview/applicationset.yaml` creates an Argo CD Application per open PR
labelled `preview`, each in its own namespace, and prunes it when the PR closes.
This exists so concurrent agent PRs never contend for a shared environment —
worth preserving as agent count grows.

Note the `preview` label is opt-in, so draft and spike PRs do not burn cluster
quota.

## What blocks scaling up

Not agent capacity. Six questions in `docs/product-context.md` are open, and #1
— scan every crate, or read a position map from one scan — drives throughput,
error rate, hardware needs, and most of the `web` agent's work. It should be
settled by observing the floor.

Agents started before it lands will build the wrong thing efficiently.
