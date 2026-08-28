# AGENTS.md

Conventions for AI coding agents working in this repository.

## Start here

Read these before doing substantive work. They exist because the knowledge was
expensive to acquire and is not recoverable from the code alone.

| Document | Read it when |
| --- | --- |
| [`docs/product-context.md`](docs/product-context.md) | **Always, first.** What the Stack App is, the Dutch domain glossary, the two phases, and what is still undecided. Without it the repository does not explain its own purpose. |
| [`docs/ci-cd.md`](docs/ci-cd.md) | Touching delivery, environments, or anything deployed. Also documents constraints that shape application design. |
| [`docs/confluence-access.md`](docs/confluence-access.md) | Before any Confluence call. Documents non-obvious failure modes that otherwise cost a long debugging cycle. |
| [`docs/decisions/`](docs/decisions/) | Before revisiting a settled architectural choice, and when making one worth recording. |

A previous session's chat history is **not** a substitute for these documents. It
is machine-local, unreadable by teammates, and full of superseded reasoning. If
something is worth carrying forward, write it into `docs/` instead.

## Presenting options and proposals

Whenever you present options, proposals, approaches, or trade-offs, score **every**
option against the five variables below. This is not optional and applies to
architecture decisions, tooling choices, refactor strategies, and any other
"here are your options" moment.

### The five variables

| Variable | Scale | Meaning |
| --- | --- | --- |
| Recommend | 0-10 | How strongly the option is recommended |
| Complexity | 0-10 | 0 = trivial, 10 = very complex |
| Urgency | 0-10 | How time-critical the option is |
| This session | Y / N | Whether it can actually be executed here and now |
| Process efficiency | -10 to +10 | Net gain or loss to the overall software development process |

`Process efficiency` is the differentiator: it measures the lasting effect on how
the team ships software, not the effort of the task itself. A quick fix can be
`Recommend 8` and still be `Process efficiency -2`.

`This session` must be honest. If an option depends on an approval, a credential,
a restart, or anything else outside the agent's control, it is `N` — even when the
code itself is trivial.

### Required output format

Do **not** render the scores as a table. One block per option: a bold heading,
then one indented bullet per variable, with the score in bold followed by an
em dash and a short justification.

```markdown
**A — Short option name**
  - **Recommend 8** — cleanest long-term integration, vendor-maintained.
  - **Complexity 3** — one config entry plus a browser login.
  - **Urgency 5** — start the approval request now, that is the slow part.
  - **This session: N** — needs admin approval and a restart to activate.
  - **Process efficiency +7** — becomes queryable context in every session.
```

Rules:

- Never use a table for the scores.
- Always indent the variable lines under the option heading.
- Keep each justification to one short clause or sentence.
- Label options `A`, `B`, `C`, ... in the order presented.
- Include the do-nothing / status-quo option when it is genuinely on the table.
- Close the set of options with a single-line **Play:** recommending what to do.

## Scratch files

Planning notes, task breakdowns, and session artifacts do not belong in this
repository. Keep them in the agent's session state directory unless the user
explicitly asks for a committed document.

## Secrets

Never commit credentials, API tokens, or personal access tokens. When an
integration needs a token, have the user place it in an untracked file outside
the repository and read it from the environment.

## Confluence

This project's documentation lives in Confluence Cloud. Connection details,
authentication, and troubleshooting are in [`docs/confluence-access.md`](docs/confluence-access.md).
Read it before attempting a Confluence call — it documents the non-obvious
failure modes, which otherwise cost a long debugging cycle.

## Keeping context alive

Session history does not transfer between sessions, machines, or people. Written
documents are the only mechanism that does.

When you learn something durable — a working integration, a non-obvious failure
mode, a decision and its reasoning — write it into `docs/` and commit it. Prefer
extending an existing document over creating a new one. Record contested
decisions in `docs/decisions/` following the criteria in its README.
