# Architecture decisions

Records of decisions that were **genuinely contested** — where a reasonable person
could have chosen otherwise, and where the reasoning will not be obvious later.

## When to add one

Add an ADR when all three are true:

1. There was a real choice, with at least one credible alternative.
2. The decision is expensive or awkward to reverse.
3. The reasoning has **no natural home** in an existing document.

Point 3 matters most. The CI/CD choices are explained in `docs/ci-cd.md` and the
Confluence auth approach in `docs/confluence-access.md`, where they are more
useful than they would be here. Do not duplicate them.

## When not to add one

- Decisions with an obvious single answer.
- Anything already explained where someone would naturally look for it.
- Backfilling old decisions to make the folder look established. An
  authoritative-looking log that is actually stale is worse than no log, because
  people trust it.

## Format

One file per decision, `NNNN-short-title.md`, numbered sequentially. Never edit a
decision once accepted — supersede it with a new one and link them, so the
reasoning trail stays intact.

```markdown
# NNNN — Title

**Status:** Proposed | Accepted | Superseded by [NNNN](NNNN-other.md)
**Date:** YYYY-MM-DD

## Context
What forced a decision. The constraints and pressures in play.

## Options considered
Each credible option, with its trade-offs. Include the one we rejected and why —
that is usually the most valuable part later.

## Decision
What we chose.

## Consequences
What this makes easy, what it makes hard, and what we accept as a cost.
```

## Expected first entry

The Stack App interaction design — **scan every crate, or read a position map
from a single scan** — is the first decision that meets all three criteria. It
drives throughput, error rate, and hardware needs, and it is listed as open
question 1 in `docs/product-context.md`. Record it here once floor observation
settles it.
