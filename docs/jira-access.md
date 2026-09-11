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

**NL CTP Team Name cannot be left empty.** It is required by the field
configuration, so creation fails without it — and it cannot be cleared
afterwards either. Both of these `PUT` bodies against
`/rest/api/2/issue/AODB-12345` return `400 "NL CTP Team Name is required"`:

```json
{ "fields": { "customfield_12002": null } }
```

```json
{ "update": { "customfield_12002": [ { "set": null } ] } }
```

`editmeta` agrees, reporting the field as `"required": true` with `set` as its
only operation:

```bash
curl -s -u "you@ah.nl:$TOKEN" -H "Accept: application/json" \
  "https://jira-eu-aholddelhaize.atlassian.net/rest/api/2/issue/AODB-12345/editmeta"
```

Only a Jira admin can change that. There is no "none" or "unassigned" option in
the dropdown.

This matters because the team field is one of two things that decide which boards
an issue appears on — see *The board* below for the other.

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

## The board

The project's current state lives on **board 24968 — *Devices & Apps - agentic
team*** (kanban, filter `67634`):

<https://jira-eu-aholddelhaize.atlassian.net/jira/software/c/projects/AODB/boards/24968>

Its filter is the non-obvious part:

```jql
project = AODB
AND labels = "D&Aagenticteam"
AND "nl ctp team name[dropdown]" IN ("Devices and Apps - Delivery app", "Devices and Apps - Fulfillment 1")
ORDER BY created DESC
```

**The label is what distinguishes this board.** Its two sibling boards select on
the team field alone, so the wrong assumption is easy to make:

| Board | Filter | Selects on |
| --- | --- | --- |
| 24968 *Devices & Apps - agentic team* | `67634` | `D&Aagenticteam` label **and** team in {Delivery app, Fulfillment 1} |
| 4212 *Devices & Apps - Fulfillment Apps* | `39833` | team = *Devices and Apps - Fulfillment 1* |
| 4214 *Devices & Apps - Delivery Apps* | `28235` | team = *Devices and Apps - Delivery app* |

So an issue for this project needs **both**:

- `labels: ["D&Aagenticteam"]` — without it the issue never reaches the agentic
  board. Note the `&` and the capitalisation; labels are exact-match.
- `customfield_12002: "Devices and Apps - Fulfillment 1"` — mandatory anyway
  (see above), and the correct team for overstapelen.

The consequence is that every issue also appears on board 4212. That is expected,
not a mistake.

> This filter has been edited at least once during the project — an earlier
> version omitted the team clause entirely. Read it rather than trusting the
> table above:

```bash
curl -s -u "you@ah.nl:$TOKEN" -H "Accept: application/json" \
  "https://jira-eu-aholddelhaize.atlassian.net/rest/agile/1.0/board/24968/configuration"
# then, with the filter id from .filter.id:
curl -s -u "you@ah.nl:$TOKEN" -H "Accept: application/json" \
  "https://jira-eu-aholddelhaize.atlassian.net/rest/api/2/filter/67634"
```

To confirm an issue actually landed on the board, query the board rather than the
project — that tests the real filter:

```bash
curl -s -u "you@ah.nl:$TOKEN" -H "Accept: application/json" -G \
  --data-urlencode 'jql=key=AODB-12345' \
  "https://jira-eu-aholddelhaize.atlassian.net/rest/agile/1.0/board/24968/issue"
```

### Stories are the source of truth for state

The board records **what exists, what is in flight, and what is done**. It is the
authoritative answer to "where is the project now".

It is *not* the place for reasoning. Why something is built a particular way
belongs in `docs/`, and contested choices in `docs/decisions/` — a design
rationale buried in a Jira comment is invisible from the repository and to a new
agent session. Link the two directions: reference the issue key from a commit or
PR, and reference the document from the issue.

## Statuses

There is **no "To Do"** status for Story. New Story issues open in **`Backlog`**,
which is the equivalent — its status category is `new`. The other new-category
statuses are `Refinement` and `To Refine`.

### Statuses are per issue type, and the difference bites

**A Story cannot hold every status the board displays.** This is not a
permissions problem and no amount of retrying fixes it — the workflow scheme
gives different issue types entirely different status sets.

| Issue type | Statuses available |
| --- | --- |
| Story, Task, Spike, Decision, Question | Backlog, Refinement, To Refine, Refined, Design, In Progress, To Test, Verify, Closed |
| **Feature** | In Analysis, Review, Open, To Do, On Hold, Impediment, In Progress, Selected for Development, Development done, Closed |
| **Epic** | Analysis, Discovery, Vision, Review One Pagers, Approved One Pagers, Ready, Implement, Done, Rejected |

Read it rather than trusting the table — this is the authoritative endpoint, and
it is the fastest way to answer "why can't I move this card there":

```bash
curl -s -u "you@ah.nl:$TOKEN" -H "Accept: application/json" \
  "https://jira-eu-aholddelhaize.atlassian.net/rest/api/2/project/AODB/statuses"
```

Two practical consequences:

- **Dragging a card on the board is a workflow transition.** If the target
  column's statuses are not in that issue type's workflow, the drop is rejected.
  The card does not move and the error reads like a permissions failure.
- **`/rest/api/2/issue/{key}/transitions` is the per-issue answer.** It lists
  what *this* issue can reach right now. If a status is absent there, no API call
  and no drag will reach it.

### Changing issue type is not an escape hatch

`editmeta` on an AODB Story reports `issuetype` with `Story` as its only allowed
value, so a Story cannot be converted to a Feature through the edit API. The UI's
*Move* operation is a different, more privileged path.

### Linking issues — the direction is the opposite of what it reads like

`POST /rest/api/2/issueLink` takes `inwardIssue` and `outwardIssue`, and the
relationship reads:

> **`inwardIssue`** *&lt;outward description&gt;* **`outwardIssue`**

So to record "AODB-1 **blocks** AODB-2", the *blocker* goes in `inwardIssue`:

```json
{
  "type": { "name": "Blocks" },
  "inwardIssue":  { "key": "AODB-1" },
  "outwardIssue": { "key": "AODB-2" }
}
```

Getting this backwards is silent — the link is created successfully and reads
plausibly in the UI, just pointing the wrong way. Always read it back before
trusting it:

```bash
curl -s -u "you@ah.nl:$TOKEN" -H "Accept: application/json" \
  "https://jira-eu-aholddelhaize.atlassian.net/rest/api/2/issue/AODB-1?fields=issuelinks"
```

A link is deleted by its own id, not by the issues it joins:
`DELETE /rest/api/2/issueLink/{linkId}`.

Useful types in this instance — list them all at `/rest/api/2/issueLinkType`:

| Type | Outward | Inward |
| --- | --- | --- |
| `Work item split` | split to | split from |
| `Blocks` | blocks | is blocked by |
| `Relates` | relates to | relates to |
| `Dependency` | depends on | is needed for |

`Work item split` is the right type when one ticket is broken into several —
it says *why* the siblings exist, which `Relates` does not.

## The board columns

Board 24968's column → status mapping, read on 2026-09-11 **after** the
`Needs Decision` column was adjusted to admit Stories:

| Column | Statuses | Story can reach? |
| --- | --- | --- |
| Backlog | *(none mapped)* | — |
| **Needs Decision** | `Backlog` (12204), `Analysis` (12710), `In Analysis` (14907) | ✅ via `Backlog` |
| Todo Human | `To Do` (10500), `Impediment` (11101) | ❌ Feature-only |
| Todo AI | `Open`, `On Hold`, `Refined`, `Refinement`, `To Refine`, `Review One Pagers`, `Discovery`, `Vision`, `Approved One Pagers` | ✅ |
| Queued AI | `Review`, `Implement`, `Ready`, `Selected for Development` | ❌ |
| Development AI | `Design`, `In Progress`, `To Test` | ✅ |
| Preview AI | `Verify`, `Development done` | ✅ |
| Canary AI | *(none mapped)* | — |
| Production AI | `Done` | ❌ |
| Canceled | `Closed`, `Rejected` | ✅ via `Closed` |

**The consequence nobody expects: every new Story lands in `Needs Decision`.**
New Stories open in `Backlog`, and `Backlog` is mapped to that column. Promoting
one to `Todo AI` means transitioning it to `Refinement`, `To Refine` or
`Refined`.

That is arguably the right default — nothing becomes AI-actionable until a human
has looked at it — but it is a behaviour change, not a display change, and it
will surprise anyone who created an issue before 2026-09-11.

**`Todo Human` remains unreachable for Stories.** Both its statuses are
Feature-only, so a Story can say "needs a decision" but not "a human should do
this". If that distinction starts mattering, the fix is either another column
remap or a workflow-scheme change to add `To Do` to the Story workflow — the
latter needs a Jira admin.

The columns are also a lump of several workflows: `Todo AI` holds Epic statuses
(`Vision`, `Discovery`) alongside Story ones. Read the live configuration rather
than assuming the mapping is curated:

```bash
curl -s -u "you@ah.nl:$TOKEN" -H "Accept: application/json" \
  "https://jira-eu-aholddelhaize.atlassian.net/rest/agile/1.0/board/24968/configuration"
```

## Failure modes

| Symptom | Cause |
| --- | --- |
| `404 "Page not found"` on `/rest/api/3/...` | You called the Confluence host. Jira is on `jira-eu-…`. |
| `404 "Site temporarily unavailable"` | That Atlassian site does not exist. Not a transient error. |
| `400` on issue creation | A mandatory custom field is missing — check `createmeta`. |
| `400 "NL CTP Team Name is required"` on edit | You tried to clear the team. It cannot be emptied; only an admin can relax the field configuration. |
| Issue created but absent from the agentic board | Missing or misspelled `D&Aagenticteam` label, or a team outside the two the board's filter allows. |
| Description renders as literal JSON | You posted ADF to v2, or a plain string to v3. |
| A card will not drag into a column | That column's statuses are not in the issue type's workflow. Check `/project/AODB/statuses`, not permissions. |
| A transition ID exists but returns `400` | Transitions are per-issue and per-status. Re-read `/issue/{key}/transitions` from the *current* status. |
| An issue link points the wrong way | `inwardIssue` takes the *outward* description. The blocker goes in `inwardIssue`. Fails silently — read it back. |
