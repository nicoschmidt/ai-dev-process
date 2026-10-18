---
name: adopt-process
description: Install ai-dev-process in a new or existing project repository, or upgrade a project to a newer release - issue, branch, install.sh, filling in the process parameters, labels, board, ruleset and claude.ai project instructions. Use for "neues Projekt aufsetzen", "Prozess übernehmen", "adopt the process", "upgrade ai-dev-process".
---

# Adopt or upgrade ai-dev-process

The installer is `install.sh` in a local checkout of
`nicoschmidt/ai-dev-process`, normally `~/coding/ai-dev-process`. The full
human-facing guide is its `docs/adopting.md`; this skill is the assistant's
side of it. Adopting is work like any other: issue, branch, pull request.

## Which mode

- **new** — the project repository is empty or nearly so
- **existing** — the project has its own process files already
- **upgrade** — `.ai-dev-process.lock` exists and names an older version

## Common first steps

1. Fetch and pick the release in the process checkout:
   `git -C ~/coding/ai-dev-process fetch --tags && git -C ~/coding/ai-dev-process tag --sort=-v:refname | head -3`
2. An issue in the project: "chore: adopt ai-dev-process vX.Y.Z" or
   "chore: ai-dev-process vA → vB" (`handover`), and once its number is
   known, the branch `chore/<n>-ai-dev-process-<version>`.

## new

1. Run the installer on the branch:
   `git -C ~/coding/ai-dev-process switch --detach vX.Y.Z && bash ~/coding/ai-dev-process/install.sh <project>`
2. Fill in `CLAUDE.md` with the maintainer — ask, do not guess: what the
   project is, hard rules, the done criterion for an iteration, the iteration
   box, the conversation language, extra definition-of-done items. Mirror the
   extra items into `.github/pull_request_template.md`.
3. Start `docs/vision.md` from what the maintainer says; leave honest
   placeholders rather than invented text. Date ADR-0001.
4. Hand over the GitHub setup in one block, with real values:

   ```bash
   cd "<project>"
   bash scripts/process/setup-labels.sh
   gh project create --owner <owner> --title "<project title>"
   # read the new project's number from the output, then:
   gh project link <number> --owner <owner> --repo <owner>/<repo>
   gh project field-create <number> --owner <owner> --name Size --data-type SINGLE_SELECT --single-select-options "S,M,L"
   gh project field-create <number> --owner <owner> --name Iteration --data-type SINGLE_SELECT --single-select-options "Backlog,000 Setting up"
   gh repo edit <owner>/<repo> --delete-branch-on-merge
   ```

   Split it where a value is only known from a previous step's output — the
   project number — rather than guessing it. Then the ruleset, which is a
   setting: *Settings → Rules → Rulesets → New branch ruleset*, target the
   default branch, require a pull request, require the status check
   `CI passed` (it appears after CI has run once), block force pushes.
5. The claude.ai project: hand over `docs/claude-project-instructions.template.md`
   from the process checkout with every value filled in, to paste into the
   project's instructions. No project knowledge documents: the repository is
   the source.
6. `bash scripts/process/check-kit.sh`, commit, pull request (`handover`).

## existing

Before running the installer, take inventory — the installer overwrites any
file at a managed path:

1. List the managed paths (`git -C ~/coding/ai-dev-process ls-files kit`) and,
   for each that exists in the project, diff it against the kit.
2. Classify every difference: **generic** (the kit already says it, or should
   → upstream issue), **project** (→ `CLAUDE.md`: hard rule, parameter,
   definition-of-done addition or deviation), or **obsolete**.
3. Find the project's own process text outside managed paths (its old
   `CLAUDE.md`, `docs/process.md`, scripts) and do the same. The new
   `CLAUDE.md` keeps only what is particular to the project.
4. Find references that move: `grep -rn "scripts/gh-board.sh" .` and similar,
   and update them in the same pull request.
5. Then install and continue as in **new** from step 2, skipping what exists.

The goal of this pull request is no change in behaviour. Say so in its body,
and list every rule whose wording changed meaning, if any did.

## upgrade

1. Read `CHANGELOG.md` in the process checkout between the two versions, and
   say what each change means for this project.
2. Install on the branch. The installer refuses if a managed file was edited
   here; resolve that first (upstream issue or deviation), never by forcing.
3. If a change needs a new parameter or makes a deviation obsolete, update
   `CLAUDE.md` in the same pull request.
4. `bash scripts/process/check-kit.sh`, commit, pull request.

Upgrade between iterations, not in the middle of one.
