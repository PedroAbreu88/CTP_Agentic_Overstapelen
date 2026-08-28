# Jira access

How to read and write Jira from a local shell or an AI coding agent session.
Contains **no credentials** — every developer supplies their own token.

## The instance is not the Confluence one

This is the trap, and it costs a long detour if you assume otherwise.

| | Confluence | Jira |
| --- | --- | --- |
| Host | `confluence-aholddelhaize.atlassian.net` | `jira-eu-aholddelhaize.atlassian.net` |
| API root | `/wiki/rest/api` | `/rest/api/2` or `/rest/api/3` |

They are **separate Atlassian sites**. Calling `/rest/api/3/myself` on the
Confluence host returns `404 "Page not found"`, which reads like a permissions or
path problem but simply means Jira is not installed there. Guessing hostnames
(`jira-aholddelhaize`, `ah`, `ahold`, `technl`, …) returns
`"Site temporarily unavailable"` — that is Atlassian's response for a site that
does not exist, not a transient outage.

The `-eu-` segment is the part nobody guesses. It was found by searching
Confluence for pages mentioning Jira and reading a link out of one.

## Authentication

The **same API token as Confluence** works, with the same account email. There
is no separate Jira credential.

```bash
TOKEN=$(security find-generic-password -s confluence-api-token -w)
curl -s -u "you@ah.nl:$TOKEN" -H "Accept: application/json" \
  "https://jira-eu-aholddelhaize.atlassian.net/rest/api/3/myself"
```

A `200` with your `accountId` confirms it. See `docs/confluence-access.md` for
how the token is stored and why the SSO address is not the API username.

## The project

**`AODB`** — *CTP Cluster - eCommerce Backoffice*. It matches the `CTPBOFAFFL`
Confluence space.

The account can see 871 projects, and searching them for `devices`,
`armscanner`, `fulfillment`, `stickerfree` or `overstapelen` does **not** find
it. The reliable way to identify the right project is to look at what you have
worked on:

```bash
curl -s -u "you@ah.nl:$TOKEN" -H "Accept: application/json" -G \
  --data-urlencode 'jql=assignee = currentUser() OR reporter = currentUser() ORDER BY updated DESC' \
  --data-urlencode 'fields=key,summary,project' \
  "https://jira-eu-aholddelhaize.atlassian.net/rest/api/3/search/jql"
```

## Creating an issue

Two mandatory custom fields are easy to miss, and creation fails without them:

| Field | Name | Values |
| --- | --- | --- |
| `customfield_13301` | Portfolio Lane | Customer Value Driver, Non-Strategic Product Management, **Tech Enabler**, Maintenance |
| `customfield_12002` | NL CTP Team Name | 18 options, including *Devices and Apps - Delivery app* and **Devices and Apps - Fulfillment 1** |

Confirm the current list rather than trusting this table:

```bash
curl -s -u "you@ah.nl:$TOKEN" -H "Accept: application/json" \
  "https://jira-eu-aholddelhaize.atlassian.net/rest/api/3/issue/createmeta?projectKeys=AODB&expand=projects.issuetypes.fields"
```

**Use the Stack App's own team, not the one on your recent tickets.** Most
recent AODB issues use *Devices and Apps - Delivery app*; overstapelen is an HSC
fulfillment process on an arm scanner and is explicitly **not** the delivery
app, so it belongs to *Devices and Apps - Fulfillment 1*.

### Prefer API v2 for the description

`/rest/api/3/issue` requires the description in **Atlassian Document Format** — a
nested JSON tree that is tedious to build and easy to get subtly wrong.
`/rest/api/2/issue` accepts a plain string with wiki markup (`h2.`, `*bold*`,
`{{code}}`, `*` bullets), which is far simpler and renders identically.

```bash
curl -s -u "you@ah.nl:$TOKEN" \
  -H "Content-Type: application/json" -X POST \
  --data @issue.json \
  "https://jira-eu-aholddelhaize.atlassian.net/rest/api/2/issue"
```

`201` returns the new issue key.

## Statuses

There is **no "To Do"** status. New Story issues open in **`Backlog`**, which is
the equivalent — its status category is `new`. The other new-category statuses
are `Refinement` and `To Refine`.

## Failure modes

| Symptom | Cause |
| --- | --- |
| `404 "Page not found"` on `/rest/api/3/...` | You called the Confluence host. Jira is on `jira-eu-…`. |
| `404 "Site temporarily unavailable"` | That Atlassian site does not exist. Not a transient error. |
| `400` on issue creation | A mandatory custom field is missing — check `createmeta`. |
| Description renders as literal JSON | You posted ADF to v2, or a plain string to v3. |
