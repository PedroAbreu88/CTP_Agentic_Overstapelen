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
| [`docs/figma-access.md`](docs/figma-access.md) | Before reading the UI designs. Covers the file key, why we use the REST API rather than the MCP server, and the traps in the components/styles endpoints. |
| [`docs/design-system.md`](docs/design-system.md) | Before proposing or building any UI. Generated inventory of the Armscanner Figma library — component sets, variants and semantic tokens. |
| [`docs/decisions/`](docs/decisions/) | Before revisiting a settled architectural choice, and when making one worth recording. |
| [`docs/agent-operating-model.md`](docs/agent-operating-model.md) | Before starting component work, or when deciding which agent should do something. Defines the `web` / `services` / `platform` split, the shared API seam, and how review works. |

A previous session's chat history is **not** a substitute for these documents. It
is machine-local, unreadable by teammates, and full of superseded reasoning. If
something is worth carrying forward, write it into `docs/` instead.

## Wait for an explicit request

**Do not start work that was not explicitly asked for.** Reading, searching, and
summarising to build context is always fine. Creating files, editing code,
filing issues, opening PRs, and committing are not — those need a request.

This applies with full force when a repository looks unfinished. A documented
backlog is not an instruction. `docs/ci-cd.md` § *Still to do*, the open
questions in `docs/product-context.md`, and any ADR marked *Proposed* are
records of known gaps, deliberately left open. Finding them is not the same as
being asked to close them.

When the next step is unclear, the correct move is to present scored options
(see below) and stop. Ending a turn with a question is a valid outcome, not a
failure to deliver.

Two specific traps, both seen in practice:

- **Autonomous or autopilot mode is not blanket authorisation.** It governs *how*
  work proceeds once a task is agreed — without check-ins on every step — not
  *whether* there is a task. Absent an agreed task, stop and ask.
- **"The user is unavailable, use your judgement" is not agreement.** Good
  judgement in that position usually means reporting findings and waiting, not
  picking a direction unilaterally. Prefer the reversible action; prefer no
  action over an unrequested one.

If in doubt: **ask, don't act.** An unwanted change costs more to unpick than a
question costs to answer.

## A list of options is a question, not a plan

**Never choose from your own option list on the user's behalf.** Presenting
scored options (see below) ends the turn. The user picks. This holds even when:

- the user appears unavailable, or a tool reports that they are;
- autonomous or autopilot mode is active;
- one option scores obviously higher than the rest;
- the action looks cheap, reversible, or "just a config file";
- you have already presented the same list once and had no reply.

Silence is not selection. An unanswered question stays unanswered — it does not
decay into consent for the highest-scoring option. Scoring an option `Recommend
9` is an argument for it, not permission to do it.

This applies with particular force to anything that changes the user's
environment rather than the repository: installing or configuring MCP servers,
plugins, skills or extensions, adding credentials, altering app or editor
settings, and any action that begins an authentication flow. Those live outside
the repository, so they are not reviewable in a pull request and not revertable
by `git`. Write the configuration, show it, explain what it will do — then stop
and let the user apply it.

If you genuinely cannot proceed without a decision, say what you are blocked on
and end the turn. Ending blocked is a correct outcome.

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
- **Order options by `Recommend`, highest first.** The reader should meet the
  strongest option before the weaker ones.
- Keep each justification to one short clause or sentence.
- Label options `A`, `B`, `C`, ... in the order presented, so `A` is always the
  best-scoring option.
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

## Closing off a session

Run through this before a session ends. Its purpose is to leave nothing valuable
trapped in a conversation that is about to disappear.

1. **Capture durable knowledge.** Anything learned that would cost real time to
   rediscover goes into `docs/`. If the session produced no lasting knowledge,
   say so explicitly rather than inventing a document.
2. **Commit and push.** Unpushed work exists on exactly one machine.
3. **Verify the working tree is clean** and no credentials reached the working
   tree or git history.
4. **Clean up scratch files.** Temporary scripts and intermediate output should
   not survive, in the repository or on disk.
5. **Open a pull request** describing what changed and *why*, including the dead
   ends — the reasoning is usually worth more than the diff.
6. **Decide whether to merge, deliberately.**

On that last point: merging is not automatic.

- **Merge** when the change is low-risk and something else is blocked until it
  lands. Documentation that new sessions depend on is the clearest case, because
  sessions branch from the default branch and cannot see unmerged work.
- **Leave open for review** when the change alters how other people work, carries
  real risk, or touches an area with an owner in `CODEOWNERS`.

The failure mode worth naming: documentation written to orient future sessions is
useless while it sits unmerged, because those sessions branch from the default
branch and never see it.
