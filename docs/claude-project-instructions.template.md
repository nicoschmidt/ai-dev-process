# Project context — pointer, not a second source of truth

<!-- Paste into the claude.ai project's instructions with every <…> filled
     in. Add no project knowledge documents: they would be a second ledger. -->

**The Git repository is authoritative for everything.** This text says where
to look, and states the few rules that must hold before anything has been
read. It carries **no project status**: that lives in the repository and in
GitHub issues, and a summary here would be wrong within days.

## Repository

- Local: `<absolute path on the maintainer's machine>`
- Remote: https://github.com/<owner>/<repo>

## Read these first, in the repository

1. `CLAUDE.md` — what this project is, its hard rules, process parameters and
   deviations
2. every file in `.claude/rules/process/` — the binding way of working
   (ai-dev-process, version in `.ai-dev-process.lock`)
3. `docs/vision.md`, `docs/architecture.md`, `docs/adr/README.md`

For where the project stands: `docs/adr/README.md` for decisions, the open
GitHub issues for work in flight, `docs/iterations/` for what earlier
iterations taught.

## Rules that apply before the repository has been read

Restated because a chat session does not read the repository by itself. The
files above are the full and binding version.

- **Never commit to `main`.** Work needs an issue and a branch, named before
  the first edit.
- **GitHub issues are the only task list.** Ideas are captured as issues
  labelled `idea` (skill `capture-idea`), never in a file.
- **Every manual step is handed over ready to run:** the finished text in a
  file beside the repository, and the exact command with real values. Never
  "create an issue" — hand over the issue and the command.
- **Decisions that are expensive to reverse are ADRs**, written before the
  code.
- **Repository language is <English>; conversation is <German>.** Repository
  prose says "the maintainer", never a personal name.
<!-- Add the project's hard rules from CLAUDE.md here, one line each. -->

## Division of labour

- **Chat (here):** product scope, architecture, "what and why"; ADRs, specs,
  refined issues, pull request bodies. No Git credentials: it can commit on a
  local branch but cannot push. That missing credential is the review gate.
- **Claude Code in the repository:** implementation against existing code.

Rule of thumb: if answering the question requires reading the codebase, it
belongs in Claude Code.
