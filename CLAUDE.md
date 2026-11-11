# Working agreements for AI assistants

This repository **is** the process. It follows its own rules, which here are
read from their source under `kit/common/` instead of from an installed copy:

@kit/common/.claude/rules/process/workflow.md
@kit/common/.claude/rules/process/handover.md
@kit/common/.claude/rules/process/decisions.md
@kit/common/.claude/rules/process/iterations.md
@kit/common/.claude/rules/process/discipline.md
@kit/common/.claude/rules/process/quality.md
@kit/common/.claude/rules/process/environments.md
@kit/common/.claude/rules/process/repositories.md

A chat session reads those files and this one before it starts work.

## What this repository is

The reusable way of working described in `README.md`: binding rules, the
procedures as a Claude plugin, and the mechanisms that back them, installed
into project repositories by `install.sh`. Its users are the maintainer's
projects and the sessions working in them.

## Hard rules

- **Nothing project-specific.** No domain words, no names of a project's
  components, no copied project content. Every rule must read true with the
  project's domain removed; the project-specific part goes into a parameter
  in the `CLAUDE.md` template instead.
- **Every rule carries its reason.** A rule added or changed without a
  reason in `docs/rationale.md` (or the rule's own text) is not done. A rule
  without a reason is weakened by the first session that cannot see why it
  exists.
- **Every change is a release concern.** A change under `kit/`, `templates/`
  or `plugins/` gets a `CHANGELOG.md` entry under `Unreleased`, with its
  reason and its origin (`from:<project>` issue, if any).
- **Kit, template, or plugin — decide deliberately.** Kit files are managed
  and overwrite the project's copy on every install. Template files are
  copied once and then belong to the project. Procedures belong in skills;
  rules that must hold in every session belong in the kit. See
  `docs/maintaining.md`.

## Process parameters

| Parameter | Value |
| --- | --- |
| Iteration done criterion | a tagged release that a project has upgraded to |
| Iteration box | scope |
| Repository language | English |
| Conversation language | German |
| Branch types | feat, fix, docs, chore |
| Board fields (facts) | none — no board; a release is a milestone (see deviations) |
| Process repository | this one |

## Definition of done additions

- `CHANGELOG.md` has an entry under `Unreleased` for every change under
  `kit/`, `templates/` or `plugins/`.
- `bash tests/run.sh` passes, which includes the kit's own script tests.

## Process deviations

- **Milestones instead of a board.** Each release is a milestone, titled
  with its version, with its goal as one sentence in the description. An
  issue belongs to a release by its milestone; issues carry no size. Item 5
  of the definition of ready reads here: the issue is in a release's
  milestone. Why: every session can read milestones over the REST API, while
  a board needs GraphQL, which chat sessions and cloud sessions cannot use;
  and the board's states repeated what issues and pull requests already
  show. This repository is the pilot for #16. The board helpers in the kit
  are exercised by their tests, not used.
- **`check-kit.sh` does not apply here.** The kit's files are the source, so
  there is no lock to check them against.

## Commands

```bash
git config core.hooksPath kit/common/.githooks   # once per clone
bash tests/run.sh                         # every test, as CI runs them
```
