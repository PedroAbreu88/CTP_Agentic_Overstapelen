# Figma access

How to read the UI designs from a local shell or an AI coding agent session.
Contains **no credentials** — every developer supplies their own token.

## Quickstart

`tools/figma-read.sh` does the reading. It never takes the token as an argument
and never prints it.

```bash
# Validate the token only — the cheapest check that access works
./tools/figma-read.sh

# Read a file: pages, published components, published styles
./tools/figma-read.sh XMc8Glk3X9V3xh1uEiYoRe
```

Exit codes: `2` when no token is found, `3` when `curl` or `node` is missing,
`1` on an API or transport failure.

## The file

| Property | Value |
| --- | --- |
| File | **Armscanner — UI designs** |
| File key | `XMc8Glk3X9V3xh1uEiYoRe` |
| URL | <https://www.figma.com/design/XMc8Glk3X9V3xh1uEiYoRe/Armscanner---UI-designs> |
| VPN required | No — `api.figma.com` is reachable from the public internet |

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

- **`/components` and `/styles` return only *published* library items.** A file
  full of local components that were never published to a library will return an
  empty list, which looks like a permissions problem but is not.
- **Node IDs change form.** The browser URL uses `node-id=17-3` with a hyphen;
  the API expects `17:3` with a colon.

## Failure modes

| Symptom | Cause |
| --- | --- |
| `403` on `/v1/me` | Token is expired, revoked, or lacks the scope. Not a file permission problem. |
| `403` on a file | The token is valid but that account cannot see the file. |
| `404` on a file | Wrong file key — check for a copied URL fragment or a `branch` key. |
| `403` on `/variables/local` | Not Enterprise. Derive tokens from published styles instead. |
| Empty `components` list | Nothing is published, rather than nothing existing. |

## What the designs are for

The Stack App targets an **arm-mounted scanner** — not a handheld, and not the
delivery application. See `docs/product-context.md` for why that distinction
changes the UI constraints. Read the designs before proposing UI, so proposals
match current standards rather than inventing a parallel set.
