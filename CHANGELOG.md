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

## 0.2.0 — 2026-10-25

Projects of several repositories, and the board named instead of guessed.
No project has to change anything to upgrade from 0.1.0: a 0.1.0 lock is read
as role `single`, the new `.ai-dev-process.conf` is created from its template,
and the board helpers behave as before until it is filled in.

### Added

- **Roles** `single`, `home` and `member`, chosen with
  `install.sh --role` and recorded in `.ai-dev-process.lock`; an upgrade keeps
  the role. Why: a project of a public and a private repository needs one
  place for its vision, ADRs and iterations, and the other repositories must
  not grow their own. *From compliance-traceability.*
- **`.claude/rules/process/repositories.md`**: what lives in the home
  repository and what in a member, one board for all, one issue and pull
  request per repository under an epic in the home repository, repositories
  checked out side by side, and nothing from a private repository reaching a
  public one. Why: those are the decisions every project of several
  repositories would otherwise make again, and the private-to-public channels
  are where leaks happen.
- **`.ai-dev-process.conf`**, project-owned and the same in every repository
  of a project: `board_owner`, `board_number`, `home_repo`, `member_repos`.
  `gh-board.sh` reads the board from it; `PROJECT_OWNER` and `PROJECT_NUMBER`
  still override it for one run. Why: with a second board, the helpers could
  no longer find the board on their own, and an environment variable to set
  before every run would be forgotten.
- **Member templates**: a `CLAUDE.md` that imports the home repository's
  from the checkout beside it, and a `docs/architecture.md` that stands on its
  own. Why: a copy of the project's parameters in every repository drifts, and
  a reader of a public member may never see the home repository.
- **`setup-labels.sh --update`** for deliberately updating existing labels.

### Changed

- **`setup-labels.sh` leaves existing labels alone** by default. Why: with
  `--force` it recoloured a project's own labels. *From
  dnd-ai-dungeon-master, adopting 0.1.0.*
- **The kit and the templates are split by role**: `kit/common/` and
  `kit/home/`; `templates/all/`, `templates/home/` and `templates/member/`.
  The paths installed in a project are unchanged. In a clone of this
  repository the hook path is now `kit/common/.githooks`.
- **Rules** `workflow`, `decisions`, `iterations`, `handover`, `discipline`
  and `environments` name the home repository where it matters; a handover
  block names the repository it runs in.
- **Skills** `capture-idea`, `refine-backlog`, `handover`, `write-adr`,
  `plan-iteration`, `close-iteration` and `adopt-process` work across the
  repositories in `.ai-dev-process.conf`. `refine-backlog` gains a *move*
  outcome, which never transfers from a private repository to a public one.
- **`docs/adopting.md`** covers roles, projects of several repositories, and
  existing repositories with code but no process; the claude.ai instructions
  template lists every repository.

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
