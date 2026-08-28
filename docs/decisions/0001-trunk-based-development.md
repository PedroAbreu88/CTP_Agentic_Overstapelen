# 0001 — Trunk-based development

**Status:** Accepted
**Date:** 2026-08-28

## Context

Delivery runs on `main` with short-lived branches, promoted through environments
by Argo CD. The rationale lives in `docs/ci-cd.md`, but the alternative we
rejected was never written down — so the question resurfaced, and someone had to
reconstruct the reasoning from scratch.

The specific proposal was a long-lived `develop` branch: accumulate changes
there, merge to `main` at release time. The motivation was reasonable — work that
is not yet merged is invisible to newly created agent sessions, because those
sessions branch from the default branch.

Two properties of this project shape the answer:

- **Concurrency is high and bursty.** An agentic team opens many short-lived
  pull requests at once, often touching unrelated areas.
- **Environments are not derived from branches.** Argo CD reconciles from
  Kustomize overlays, and promotion is a tag bump committed into an overlay.
  Preview environments come from the ApplicationSet PR generator, one namespace
  per labelled pull request.

## Options considered

### Trunk-based development (chosen)

One long-lived branch. Short-lived branches merge within hours. `main` is always
releasable. Incomplete work merges behind feature flags rather than waiting on a
branch.

Fits the delivery model already in place: overlays pin an image tag, so a moving
`main` never *is* the desired state for production. Short-lived branches diverge
little, so concurrent agent work rarely conflicts.

The cost is real and worth stating: it requires small pull requests, fast review,
tests trusted enough to keep `main` releasable, and feature flags to hide
unfinished work.

### Long-lived `develop` branch (git-flow style) — rejected

Rejected for three reasons.

1. **It does not solve the stated problem.** Sessions would branch from
   `develop` instead of `main`; unmerged work stays invisible either way. The
   boundary moves, it does not disappear.
2. **It conflicts with the promotion model.** Production is promoted by
   committing an image tag into an overlay, gated by a git tag and required
   reviewers. Adding `develop` means a second promotion path plus a permanent
   `develop` → `main` merge that drifts.
3. **It serialises concurrent work.** A shared integration branch queues changes
   that are currently independent, which is precisely the cost `docs/ci-cd.md`
   set out to avoid.

### Base new sessions on a feature branch — adopted as a complement, not a replacement

For the genuine exception where work cannot merge yet, create the session from
that branch. This handles the exception without reshaping the branching model,
and is cheap because it is per-case.

## Decision

Keep trunk-based development on `main`.

Address the original concern differently: **do not bundle context documentation
into pull requests that need lengthy review.** Documentation intended to orient
future sessions is low-risk and should merge quickly, precisely because sessions
branch from the default branch and cannot see unmerged work.

## Consequences

**Easier.** Concurrent agent work stays independent. No cross-branch merges, no
second promotion path, no drift. Preview environments remain per-pull-request.

**Harder.** `main` must stay green — a broken `main` poisons the shared staging
signal. Feature flags become mandatory rather than optional, especially for the
Capacitor Android app, which cannot be rolled back once installed and therefore
needs a way to disable behaviour after shipping.

**Accepted cost.** Trunk-based development degrades badly when review is slow: a
pull request left open for a week is git-flow with extra steps and none of its
coordination. Keeping pull requests small and review fast is not a nicety here,
it is the mechanism that makes this work.

**The failure mode this decision names.** Documentation written to orient future
sessions is useless while unmerged. See the session close-off checklist in
`AGENTS.md`.
