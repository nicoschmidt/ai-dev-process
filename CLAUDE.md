# Working agreements for AI assistants

This repository **is** the process. It follows its own rules, which here are
read from their source under `kit/` instead of from an installed copy:

@kit/.claude/rules/process/workflow.md
@kit/.claude/rules/process/handover.md
@kit/.claude/rules/process/decisions.md
@kit/.claude/rules/process/iterations.md
@kit/.claude/rules/process/discipline.md
@kit/.claude/rules/process/quality.md
@kit/.claude/rules/process/environments.md

A chat session reads those seven files and this one before it starts work.

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
| Board fields (facts) | none — this repository has no board yet |
| Process repository | this one |

## Definition of done additions

- `CHANGELOG.md` has an entry under `Unreleased` for every change under
  `kit/`, `templates/` or `plugins/`.
- `bash tests/run.sh` passes, which includes the kit's own script tests.

## Process deviations

- **No board.** Issues here carry no size or iteration; the board helpers in
  the kit are exercised by their tests, not used. Revisit when this
  repository has more than a handful of open issues.
- **`check-kit.sh` does not apply here.** The kit's files are the source, so
  there is no lock to check them against.

## Commands

```bash
git config core.hooksPath kit/.githooks   # once per clone
bash tests/run.sh                         # every test, as CI runs them
```
