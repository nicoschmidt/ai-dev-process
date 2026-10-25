# Project context — pointer, not a second source of truth

<!-- Paste into the claude.ai project's instructions with every <…> filled
     in. One claude.ai project per project, however many repositories. Add no
     project knowledge documents: they would be a second ledger. -->

**The Git repositories are authoritative for everything.** This text says
where to look, and states the few rules that must hold before anything has
been read. It carries **no project status**: that lives in the repositories
and in GitHub issues, and a summary here would be wrong within days.

## Repositories

<For a project of one repository, one line. For several: one line each, the
home repository first, all checked out side by side.>

- **Home:** `<absolute local path>` — https://github.com/<owner>/<repo>
  (<public|private>): <vision, ADRs, iterations, epics; or: the whole project>
- **Member:** `<absolute local path>` — https://github.com/<owner>/<repo>
  (<public|private>): <what it holds>

## Read these first, in the home repository

1. `CLAUDE.md` — what this project is, its hard rules, process parameters and
   deviations
2. every file in `.claude/rules/process/` — the binding way of working
   (ai-dev-process, version and role in `.ai-dev-process.lock`)
3. `.ai-dev-process.conf` — the board and the repositories
4. `docs/vision.md`, `docs/architecture.md`, `docs/adr/README.md`

Before working in a member repository, also its `CLAUDE.md`. For where the
project stands: `docs/adr/README.md` for decisions, the open GitHub issues for
work in flight, `docs/iterations/` for what earlier iterations taught.

## Rules that apply before the repositories have been read

Restated because a chat session does not read the repositories by itself.
The files above are the full and binding version.

- **Never commit to `main`.** Work needs an issue and a branch, named before
  the first edit — in the repository whose contents it changes.
- **GitHub issues are the only task list.** Ideas are captured as issues
  labelled `idea` (skill `capture-idea`), never in a file.
- **Every manual step is handed over ready to run:** the finished text in a
  file beside the repository, and the exact command with real values, naming
  the repository it runs in. Never "create an issue" — hand over the issue and
  the command.
- **Decisions that are expensive to reverse are ADRs** in the home
  repository, written before the code.
- **Nothing from a private repository reaches a public one** — not in files,
  commits, issues or pull requests.
- **Repository language is <English>; conversation is <German>.** Repository
  prose says "the maintainer", never a personal name.
<!-- Add the project's hard rules from CLAUDE.md here, one line each. -->

## Division of labour

- **Chat (here):** product scope, architecture, "what and why"; ADRs, specs,
  refined issues, pull request bodies. No Git credentials: it can commit on a
  local branch but cannot push. That missing credential is the review gate.
- **Claude Code in a repository:** implementation against existing code.

Rule of thumb: if answering the question requires reading the codebase, it
belongs in Claude Code.
