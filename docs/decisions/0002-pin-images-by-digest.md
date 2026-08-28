# 0002 — Pin production images by digest, not by tag

**Status:** Proposed
**Date:** 2026-08-28

## Context

Argo CD reconciles each environment to an image reference committed into a
Kustomize overlay. Promotion is a commit that rewrites that reference; the
overlay's git history is the deployment audit trail.

The overlays currently declare `images: []` because no components have landed
yet. That makes this the cheapest possible moment to decide how images are
referenced — once manifests and promotion workflows exist, changing it means
touching both.

The relevant property: **container registry tags are mutable.** A tag like
`:abc123` is a label, not an identity. Re-pushing that tag in ACR changes what
the cluster pulls, with **no commit anywhere in git**. The GitOps guarantee —
that git is the single source of truth for what is running — quietly does not
hold. An image digest (`@sha256:...`) is content-addressed and cannot be
repointed.

This matters more than usual here because production rollback is a re-point to a
previously built image rather than a rebuild. A rollback target that has been
silently overwritten is a bad way to discover the difference.

## Options considered

### Pin by digest in the production overlay (proposed)

Kustomize supports `digest:` alongside `newTag:`:

```yaml
images:
  - name: <registry>/<component>
    digest: sha256:<...>
```

The reference is immutable and verifiable. What git says is running is what is
running. Rollback targets stay valid indefinitely.

Cost: digests are unreadable to humans, so the promotion workflow must resolve
the tag to a digest and record both — the digest for the cluster, the tag in the
commit message for people. That is a small amount of workflow logic, and it is
much cheaper to write now than to retrofit.

### Enable immutable tags in ACR — complementary, not sufficient

ACR can lock tags against overwriting. Worth enabling regardless, as
defence in depth.

Not sufficient alone: it is a registry-side setting that can be changed or missed
per-repository, and it is invisible from the git history. It makes overwriting
harder; digest pinning makes it impossible to go unnoticed.

### Keep pinning by tag — rejected

Simplest and most readable, and honest about the trade-off: it is fine right up
until a tag is overwritten, at which point the failure is silent and the audit
trail is wrong. Since the cost of choosing otherwise is near zero today and
non-trivial later, taking the readable option now is borrowing against a
predictable debt.

## Decision

**Proposed:** pin production by digest, and enable ACR tag immutability as
defence in depth. Staging may keep tag-based pinning for readability, since it
tracks `main` automatically and is not a rollback target.

Marked *Proposed* rather than *Accepted* because no components exist yet and the
promotion workflows have not been written. It should be confirmed or rejected
when the first component lands — that is the moment it becomes real.

## Consequences

**Easier.** Git becomes a genuinely authoritative record of what is running.
Rollback targets cannot be silently altered. Supply-chain tampering via tag
overwrite is closed off.

**Harder.** Overlay diffs become unreadable at a glance. The promotion workflow
must resolve tag to digest, and commit messages must carry the human-readable
version or deployment history becomes hard to follow.

**If deferred.** Retrofitting means changing overlays and both promotion
workflows at once, at a point when they are load-bearing. That is the argument
for settling it before the first component lands, not after.
