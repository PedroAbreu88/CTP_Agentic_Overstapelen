# AGENTS.md

Conventions for AI coding agents working in this repository.

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
