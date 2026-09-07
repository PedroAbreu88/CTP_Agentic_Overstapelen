# Confluence access

How to read Confluence from a local shell or an AI coding agent session.
Contains **no credentials** — every developer supplies their own API token.

## Instance

| Property | Value |
| --- | --- |
| Type | Confluence **Cloud** |
| Base URL | `https://confluence-aholddelhaize.atlassian.net/wiki` |
| Cloud ID | `a37f255c-b08e-4c8a-b47e-3cbe6809e726` |
| VPN required | No — reachable from the public internet |

## Authentication

Basic auth with your **Atlassian account email** and a personal API token.

> **Gotcha — the SSO address is not the API username.**
> Logging in through single sign-on with `<user>@emea.royalahold.net` does not
> mean that address works with the API. Use the email on the Atlassian account
> itself (for example `firstname.lastname@ah.nl`). The SSO address returns
> `403 "caller cannot access Confluence"`, which looks like a permissions
> problem but is really the wrong username.

Confirm which address is yours:

```bash
curl -s -u "you@ah.nl:$TOKEN" -H "Accept: application/json" \
  "https://confluence-aholddelhaize.atlassian.net/wiki/rest/api/user/current"
```

A `200` with your `accountId` and `publicName` means the pair is correct.

## Storing the token

Create the token at <https://id.atlassian.com/manage-profile/security/api-tokens>
and set an expiry. Store it in the macOS Keychain — never in the repo, a dotfile,
or a chat message.

```bash
security add-generic-password -a "$USER" -s confluence-api-token -w
```

Read it back in scripts:

```bash
TOKEN=$(security find-generic-password -s confluence-api-token -w)
```

Rotate or remove:

```bash
security delete-generic-password -s confluence-api-token
```

### Verify the token is intact

A classic Atlassian token starts with `ATATT3xFfGF0` and is **192 characters**.
A short value is a truncated paste, and it fails in a confusing way — see
troubleshooting below.

```bash
security find-generic-password -s confluence-api-token -w | wc -c
```

> **Gotcha — the clipboard trap.**
> Any recipe of the form `... -w "$(pbpaste)"` breaks if you *copy* the command
> into your terminal, because copying replaces the token in the clipboard with
> the command text. Copy the token last, then type the command by hand, or use
> the interactive `-w` form above which prompts for the value.

## Reading a page

Prefer the v2 API. Page IDs come from the page URL:
`/wiki/spaces/<SPACE>/pages/<PAGE_ID>/<slug>`.

```bash
TOKEN=$(security find-generic-password -s confluence-api-token -w)
BASE="https://confluence-aholddelhaize.atlassian.net/wiki"

curl -s -u "you@ah.nl:$TOKEN" -H "Accept: application/json" \
  "$BASE/api/v2/pages/<PAGE_ID>?body-format=storage"
```

Useful `body-format` values:

- `storage` — Confluence XHTML storage format, best for parsing.
- `atlas_doc_format` — ADF JSON. An empty page returns
  `{"type":"doc","content":[{"type":"paragraph"}],"version":1}`.
- `view` / `export_view` — rendered HTML; may be empty when `storage` is empty.

Search with CQL:

```bash
curl -s -u "you@ah.nl:$TOKEN" -H "Accept: application/json" \
  --get --data-urlencode 'cql=space=CTPBOFAFFL and type=page' \
  "$BASE/rest/api/search"
```

## Publishing from this repository

`docs/proposal.md` is **the source of truth** for the Solution proposal. The
Confluence page (`151013721984`) is a rendering of it, and carries a banner
saying so. Edit the Markdown, raise a pull request, then publish:

```bash
./tools/confluence-publish.sh --check    # convert and compare, change nothing
./tools/confluence-publish.sh            # publish
```

The script resolves a token the same way the Figma tools do — `$CONFLUENCE_TOKEN`,
then the Keychain, then `~/.confluence-token` — and takes the account email from
`$CONFLUENCE_EMAIL` or `git config user.email`.

`tools/md-to-storage.mjs` does the conversion. It handles a deliberately small
subset of Markdown and **throws on anything else**, with a line number, rather
than silently dropping content. A converter that quietly skips what it does not
understand produces a page missing a paragraph nobody notices for a month.
Adding syntax means adding a rule.

Two behaviours worth knowing before you debug them:

- **It refuses to overwrite a browser edit.** Every version the tool creates is
  stamped `Published from docs/proposal.md`. If the live version's message lacks
  that stamp, someone edited the page directly, and the script stops rather than
  clobbering their work. Reconcile the change into the Markdown, or pass
  `--force` if you are certain it is safe.
- **Re-running with no changes does nothing.** This is less obvious than it
  sounds: Confluence rewrites what you send. It injects an `ac:macro-id` into
  every macro, reflows whitespace, and normalises character entities **in both
  directions** — it decoded our literal `⚠` and encoded our literal em dash. A
  byte comparison therefore never matches, so the tool would bump the version on
  every run and fill the page history with no-op edits. The comparison decodes
  entities on both sides before comparing.

Comments on the Confluence page are safe — they are not touched by publishing,
and are the right way for reviewers to give feedback.

## Troubleshooting

| Symptom | Cause |
| --- | --- |
| `403 "caller cannot access Confluence"` for every request, **including with deliberately invalid credentials** | The token is malformed or truncated, so it is discarded before evaluation. Check the length is 192. |
| `403` with a valid token | Wrong username — you are probably using the SSO address instead of the Atlassian account email. |
| `404` on a page that exists in the browser | Either a genuinely wrong page ID, or the account lacks permission. Confluence hides pages rather than returning `403`. |
| Body is empty but the request returns `200` | The page really is empty. Check `atlas_doc_format` for a lone empty paragraph. |

**Diagnostic tip:** when a call fails, repeat it with a deliberately bogus token.
If the response is identical, the credential is not being evaluated at all and
the problem is the token, not permissions or scope.

## Known state

`security find-generic-password` reads the Keychain without re-prompting once
`/usr/bin/security` has been approved, so any shell session on the same machine
can reuse a stored token. The token is per-machine and per-user; it does not
transfer to CI or to teammates. Shared automation needs a secrets manager or a
dedicated service account instead.
