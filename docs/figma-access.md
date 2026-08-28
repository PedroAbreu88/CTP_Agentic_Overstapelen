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
| `/v1/files/:key/variables/local` | Design variables. **Enterprise plan only.** |

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

Figma rate-limits aggressively and returns `{"status":429,"err":"Rate limit
exceeded"}`.

The limit is **cost-based, not a simple request count**, and `GET /v1/files/:key`
without a `depth` parameter is by far the most expensive call available. One
full read of the designs file — 33 MB — exhausted the budget for **over two
hours**, blocking even cheap follow-up calls.

Practical consequences:

- Always pass `?depth=1`, or use `/nodes?ids=`, unless you genuinely need the
  entire tree. You almost never do.
- Fetch each endpoint once and reuse the response from disk.
- **Recovery is much slower than the wording suggests.** One undepthed `GET
  /v1/files/:key` on the 33 MB designs file left that endpoint returning `429`
  for **over two hours**, and repeated retries appeared to extend it rather
  than shorten it. Treat a 429 as "come back later", not "wait and retry".
- **The buckets are per-endpoint, but they are not independent.** `/components`
  and `/styles` kept working while `/v1/files/:key` was blocked — but enough
  calls to `/nodes` exhausted that bucket too. Budget the whole session, not
  each endpoint.
- Prefer reading `docs/design-system.md`, which needs no API call at all.

## Failure modes

| Symptom | Cause |
| --- | --- |
| `403` on `/v1/me` | Token is expired, revoked, or lacks the scope. Not a file permission problem. |
| `403` on a file | The token is valid but that account cannot see the file. |
| `404` on a file | Wrong file key — check for a copied URL fragment or a `branch` key. |
| `403` on `/variables/local` | Not Enterprise. Derive tokens from published styles instead. |
| Empty `components` list | Wrong file — you queried the designs file, not the library. |
| `429 Rate limit exceeded` | Cost-based limit exhausted. Can take hours to clear, and retries appear to extend it. See [Rate limits](#rate-limits). |

## What the designs are for

The Stack App targets an **arm-mounted scanner** — not a handheld, and not the
delivery application. See `docs/product-context.md` for why that distinction
changes the UI constraints. Read the designs before proposing UI, so proposals
match current standards rather than inventing a parallel set.
