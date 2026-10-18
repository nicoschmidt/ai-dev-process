# Changelog

Every change to `kit/`, `templates/` or `plugins/` is listed here with its
reason and, where it came from a project, its origin. Projects read the
entries between their version and the new one before upgrading.

Versions follow `MAJOR.MINOR.PATCH`:

- **MAJOR** — an upgrade needs the project to change something: a new
  required parameter, a rule that reverses an old one, a moved path.
- **MINOR** — a new rule, skill, template or mechanism that works without
  project changes.
- **PATCH** — wording, a fixed script, a clarified reason.

Before 1.0.0 a MINOR may also break; the entry says so.

## Unreleased

## 0.1.0 — 2026-10-18

Extracted from dnd-ai-dungeon-master, where the process was developed over
its setup and first iteration. Where a rule there was already generic, its
wording is kept; where it named the project, it now names a parameter.

### Added

- **Rules** in `kit/.claude/rules/process/`: workflow, handover, decisions,
  iterations, discipline, quality, environments. Split by topic so that a
  project's `CLAUDE.md` holds only what is particular to the project.
- **Process parameters and deviations** in the `CLAUDE.md` template: the
  iteration done criterion, the iteration box, languages, branch types, board
  fields, and definition-of-done additions. Why: in the original these were
  written into the rules ("playable", "spare time"), which made the rules
  untrue for any other project.
- **Idea capture** *(new, not in the original)*: the `idea` label and issue
  form, `capture-idea.sh`, the `capture-idea` skill, and a definition of ready
  that an idea has to pass before work starts. Why: observations made between
  sessions were forgotten before the retro. An issue is where every other work
  item already lives, it can be created from a phone in seconds, and it keeps
  the rule that GitHub issues are the only task list.
- **Dictated ideas may be created directly** by an assistant with
  credentials *(new)*. Why: capture has to cost seconds, and an idea commits
  nobody to anything; every other GitHub step stays with the maintainer.
- **Retro from evidence** *(new)*: the retro reads the `process` issues, the
  merged pull requests' reviews and what was cut, and marks each learning
  `[project]` or `[generic]`. Why: a retro from memory finds what was
  annoying last week, not what was costly.
- **Managed files and `.ai-dev-process.lock`**, `install.sh` and
  `check-kit.sh` *(new)*. Why: a rule edited locally in one project silently
  forks the process; the lock makes that visible in CI, and upgrades refuse to
  overwrite such an edit.
- **Pre-commit hook** refusing commits on `main` *(new)*. Why: in the original,
  three commits reached `main` under a rule alone; a git hook holds for every
  session that commits, including chat sessions that do not load Claude Code
  hooks.
- **Plugin** with the skills `capture-idea`, `refine-backlog`, `handover`,
  `write-adr`, `plan-iteration`, `close-iteration`, `upstream-learning`,
  `adopt-process`. Why: procedures are needed at a moment, not in every
  session, and a plugin reaches chat, Cowork and Claude Code from one install.
- **Board helpers** `gh-board.sh`, `show-board.sh`, `set-issue-fields.sh` and
  their stand-in test, moved from `scripts/` to `scripts/process/`, and
  `setup-labels.sh` *(new)*.
- **Templates**: `CLAUDE.md`, pull request template, CI with the `CI passed`
  gate, vision, architecture, ADR index and ADR-0001, iterations README and
  000-setting-up.
