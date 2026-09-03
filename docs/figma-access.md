# Figma access

How to read the UI designs from a local shell or an AI coding agent session.
Contains **no credentials** — every developer supplies their own token.

## Quickstart

Two scripts live in `tools/`. Neither takes the token as an argument, and
neither prints it.

```bash
# Validate the token only — the cheapest check that access works
./tools/figma-read.sh

# Read a file: pages, published components, published styles
./tools/figma-read.sh XMc8Glk3X9V3xh1uEiYoRe

# List the pages in the designs file
./tools/figma-flow.sh

# Summarise a flow's screens: layout regions, components used, on-screen text
./tools/figma-flow.sh Picking

# Regenerate docs/design-system.md from the component library
./tools/figma-extract.sh

# Is the committed extract still current?
./tools/figma-extract.sh --check
```

Exit codes: `2` when no token is found, `3` when `curl` or `node` is missing,
`1` on an API or transport failure.

All three share `tools/figma-lib.sh`, which reports the `retry-after` header on
a `429` — so a rate limit tells you when it clears instead of leaving you to
guess.

For the component vocabulary, prefer `docs/design-system.md` over either
script: it is committed, needs no token, and costs no API call.

## The files

There are **two**, and the distinction matters — reading the wrong one is the
most likely way to conclude there is no design system.

| | Designs | Library |
| --- | --- | --- |
| Name | Armscanner - UI designs | Armscanner - Library |
| File key | `XMc8Glk3X9V3xh1uEiYoRe` | `nsgOZTtYiHjPOxrt1ImVHv` |
| Contains | 38 pages of flows | 643 published components, 167 styles |
| Published components | **0** | 643 |

The designs file **consumes** the library: ~6,800 `INSTANCE` nodes and only 3
local components. So `/v1/files/XMc8.../components` returns an empty list, which
looks like a permissions failure but is not — the components are simply defined
elsewhere.

There is also a **Mobile Library** (`W1JNpZc1GCD2bw8lkwswss`, 663 components)
referenced by a handful of components. Armscanner is the relevant one.

Do not read either file to learn the component vocabulary — read
`docs/design-system.md`, which is generated from the library and needs no token.

VPN is not required; `api.figma.com` is reachable from the public internet.

The file key is the segment after `/design/` in the URL. Every REST call needs
it.

## We use the REST API, not the MCP server

Figma publishes an official MCP server at `https://mcp.figma.com/mcp`. It is
**not** what this project uses. The REST API is the decided route.

Recording why, so the choice is not silently re-litigated:

- **The REST API is inspectable.** A `curl` call is a thing you can read, log,
  and reason about. It fails in ways that are obvious.
- **The MCP server is per-developer environment configuration**, living outside
  the repository. It cannot be reviewed in a pull request, and one developer's
  working setup does not transfer to anyone else.
- **The MCP server's rate limits depend on seat type.** Figma's own guide states
  that Starter plans and View/Collab seats are capped at *6 tool calls per
  month*; only Dev or Full seats on paid plans get normal per-minute limits.
  That is a sharp cliff to build a workflow on.

The MCP server remains a reasonable option later, particularly for Dev Mode code
generation. If it is adopted, record the reasoning here and say what changed.

## Authentication

A **personal access token**, sent as an `X-Figma-Token` header. Create one at
Figma → Settings → Security → *Personal access tokens*, with at least
`file_read` scope.

```bash
curl -s -H "X-Figma-Token: $TOKEN" https://api.figma.com/v1/me
```

A `200` with your email and handle means the token works.

## Storing the token

Never in the repository, a dotfile in the repository, or a chat message. In
preference order:

```bash
# macOS Keychain — prompts, so the value never enters shell history
security add-generic-password -s figma -a "$USER" -w

# or an untracked file outside any repository
printf '%s' '<token>' > ~/.figma-token && chmod 600 ~/.figma-token

# or an environment variable in a shell you control
export FIGMA_TOKEN='<token>'
```

This mirrors the arrangement in `docs/confluence-access.md`, for the same
reasons.

## Endpoints worth knowing

| Endpoint | Returns |
| --- | --- |
| `/v1/me` | The authenticated user. The cheapest way to test a token. |
| `/v1/files/:key?depth=1` | File name, `lastModified`, and top-level pages without the whole node tree. |
| `/v1/files/:key/components` | **Published** components only. |
| `/v1/files/:key/styles` | **Published** styles — colours, type, effects. |
| `/v1/files/:key/nodes?ids=:id` | Specific nodes. `node-id=17-3` in a URL is `17:3` here. |
| `/v1/files/:key/variables/local` | Design variables. **Enterprise plan and a Dev or Full seat.** |

Two traps in that table:

- **`/components` and `/styles` return only *published* library items.** The
  designs file returns an empty list for both, because it consumes a library
  rather than defining one. That is not a permissions problem — query the
  library file key instead.
- **Node IDs change form.** The browser URL uses `node-id=17-3` with a hyphen;
  the API expects `17:3` with a colon.

A third, learned the expensive way: **the full designs file is 33 MB.** Never
`GET /v1/files/:key` without `depth`, and never commit the result. Use
`?depth=1` for structure, or `/nodes?ids=` for a specific subtree.

## Rate limits

Figma returns `{"status":429,"err":"Rate limit exceeded"}` — and, crucially,
**tells you exactly how long you are blocked for in the response headers.**
Nothing in the body says so. Always look at the headers:

```
retry-after: 291693
x-figma-plan-tier: enterprise
x-figma-rate-limit-type: low
x-figma-upgrade-link: https://www.figma.com/files?api_paywall=true
```

`retry-after` is in **seconds**. The value above is **3.4 days**. Earlier
sessions guessed "minutes", then "hours", and repeatedly retried into a block
that had days left to run — because nobody read the headers. The tools now
report this automatically; `tools/figma-lib.sh` does the work.

### The limit is a seat restriction, not the org plan

Note the two tier headers disagree: the plan is **enterprise**, but the rate
limit type applied is **low**. That combination, plus the `upgrade-link`, means
the restriction comes from the **seat**, not the organisation's plan.

Figma's own guidance is that Starter plans and **View or Collab seats** get
severely reduced API access, while **Dev or Full seats** on a paid plan get
normal per-minute limits. The observed behaviour matches: a single expensive
call bought a multi-day block, and even two small calls after six days of
inactivity triggered another.

**This is the single most important constraint on working with Figma here.**
Until the seat changes, treat the API as something you may touch a handful of
times per week, not per session.

Practical consequences:

- **Read `docs/design-system.md` instead.** It is committed, needs no token,
  and costs nothing. This is why it exists.
- Always pass `?depth=1`, or use `/nodes?ids=`, unless you genuinely need the
  entire tree. **`?depth=1` on the designs file is 13 KB; the same call without
  `depth` is 33 MB** — and that one call caused the multi-day block.
- Fetch each endpoint once and reuse the response from disk.
- **Never retry on a hunch.** Read `retry-after` and believe it.
- The buckets are roughly per-endpoint but not independent: `/components` and
  `/styles` kept working while `/v1/files/:key` was blocked, yet enough
  `/nodes` calls exhausted that bucket too. Budget the session, not the
  endpoint.

## Node IDs — `0:1` is not the document

There is no node id for the document root that `/nodes` will return. **`0:1` is
the first page**, which in the designs file is `↳ Login`. Asking for it and
treating the result as the document yields one page's frames, silently, with no
error.

To list pages, use `GET /v1/files/:key?depth=1` and read `document.children`.
That is the only reliable route, and at 13 KB it is cheap.

## Failure modes

| Symptom | Cause |
| --- | --- |
| `403` on `/v1/me` | Token is expired, revoked, or lacks the scope. Not a file permission problem. |
| `403` on a file | The token is valid but that account cannot see the file. |
| `404` on a file | Wrong file key — check for a copied URL fragment or a `branch` key. |
| `403` on `/variables/local` | Needs an Enterprise plan **and** a Dev or Full seat. Derive tokens from published styles instead. |
| Empty `components` list | Wrong file — you queried the designs file, not the library. |
| `429 Rate limit exceeded` | Read the `retry-after` header — it is authoritative and has been as long as **3.4 days**. See [Rate limits](#rate-limits). |

## What the designs are for

The Stack App targets an **arm-mounted scanner** — not a handheld, and not the
delivery application. See `docs/product-context.md` for why that distinction
changes the UI constraints. Read the designs before proposing UI, so proposals
match current standards rather than inventing a parallel set.
