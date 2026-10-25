---
name: adopt-process
description: Install ai-dev-process in a new or existing project of one or several repositories, or upgrade a project to a newer release - roles, issue, branch, install.sh, process parameters, .ai-dev-process.conf, labels, board, ruleset and claude.ai project instructions. Use for "neues Projekt aufsetzen", "Prozess übernehmen", "adopt the process", "upgrade ai-dev-process".
---

# Adopt or upgrade ai-dev-process

The installer is `install.sh` in a local checkout of
`nicoschmidt/ai-dev-process`, normally `~/coding/ai-dev-process`. The full
human-facing guide is its `docs/adopting.md`; this skill is the assistant's
side of it. Adopting is work like any other: issue, branch, pull request — in
each repository.

## Decide first

- **Mode**: **new** (the repository is empty or nearly so), **existing** (it
  has code, data or its own process files), or **upgrade**
  (`.ai-dev-process.lock` names an older version).
- **Repositories**: one, or several. With several, which one is the **home**
  (vision, ADRs, iterations, epics — `.claude/rules/process/repositories.md`)
  and which are **members**. A home repository may be one created only for
  that purpose. Ask; this is the maintainer's decision, and the first ADR in
  the home repository records it.
- **Visibility**: which repositories are public and which private. If both
  exist, the project's hard rules say what may never move from private to
  public, and a check in the public repository's CI enforces what it can.

## Common first steps

1. Fetch and pick the release in the process checkout:
   `git -C ~/coding/ai-dev-process fetch --tags && git -C ~/coding/ai-dev-process tag --sort=-v:refname | head -3`
2. **The board first**, once for the whole project, since the issues need it.
   Hand over, with real values; the number comes from the first command's
   output, so split the block there rather than guess it:

   ```bash
   gh project create --owner <owner> --title "<project title>"
   gh project field-create <number> --owner <owner> --name Size --data-type SINGLE_SELECT --single-select-options "S,M,L"
   gh project field-create <number> --owner <owner> --name Iteration --data-type SINGLE_SELECT --single-select-options "Backlog,000 Setting up"
   gh project link <number> --owner <owner> --repo <owner>/<repo>    # once per repository
   ```

   Then the `Status` options, a setting: *Project → ⋯ → Settings → Status* —
   `Backlog`, `Ready`, `In progress`, `In review`, `Done`.
3. Per repository: labels without touching existing ones
   (`GH_REPO=<owner>/<repo> bash ~/coding/ai-dev-process/kit/common/scripts/process/setup-labels.sh`),
   then an issue "chore: adopt ai-dev-process vX.Y.Z" with size and
   iteration, and once its number is known, the branch
   `chore/<n>-ai-dev-process-<version>`. Write the handover as one script per
   repository that reads the number from GitHub (`handover`).

## Install

Per repository, on its branch, with its role:

```bash
git -C ~/coding/ai-dev-process switch --detach vX.Y.Z
bash ~/coding/ai-dev-process/install.sh --role <single|home|member> <repository>
```

Then fill in, with the maintainer — ask, do not guess:

- **`.ai-dev-process.conf`**, identical in every repository: `board_owner`,
  `board_number`, `home_repo`, `member_repos`.
- **The home repository's `CLAUDE.md`** (or the single one's): the
  Repositories section, what the project is, hard rules, process parameters,
  definition-of-done additions. Mirror the additions into
  `.github/pull_request_template.md`.
- **Each member's `CLAUDE.md`**: the import line pointing at the home
  repository's directory beside it, what this repository is, its own hard
  rules and definition-of-done additions.
- **`docs/vision.md`** in the home repository from what the maintainer says;
  honest placeholders rather than invented text. Date ADR-0001. ADR-0002
  records the repository layout when there are several.

Every `<…>` placeholder is gone before the pull request. Then
`bash scripts/process/check-kit.sh`, commit, pull request (`handover`).

## existing

Before running the installer, take inventory — it overwrites any file at a
managed path:

1. For each managed path
   (`git -C ~/coding/ai-dev-process ls-files kit | sed 's|^kit/[a-z]*/||'`)
   that exists in the repository, diff it against the kit.
2. Classify every difference, and every piece of the repository's own process
   text outside managed paths (an old `CLAUDE.md`, `docs/process.md`,
   scripts): **generic** (→ upstream issue), **project** (→ `CLAUDE.md` or a
   member's `CLAUDE.md`), or **obsolete**.
3. Documents that are really iteration notes, specs or decisions — checkpoint
   files, planning notes — belong in the home repository. Moving them is its
   own issue; in a public repository, check first that they hold nothing
   private.
4. Find references that move (`grep -rn "scripts/gh-board.sh" .` and similar)
   and update them in the same pull request.

Rehearse the whole install against a fresh clone of `main` with a stand-in
`gh` before handing it over, and give the handover a precondition on the
commit it was prepared against. The aim of that pull request is no change in
behaviour; say so in its body, and list everything whose meaning changed.

## upgrade

1. Read `CHANGELOG.md` in the process checkout between the two versions, and
   say what each change means for this project.
2. Install on the branch, in every repository of the project; the role comes
   from the lock. The installer refuses if a managed file was edited; resolve
   that first (upstream issue or deviation), never by forcing.
3. A change that needs a new parameter, a new key in `.ai-dev-process.conf`,
   or makes a deviation obsolete is made in the same pull request.

Upgrade between iterations, not in the middle of one, and all repositories of
a project to the same version.

## The claude.ai project

One claude.ai project per project, however many repositories. Hand over
`docs/claude-project-instructions.template.md` from the process checkout with
every value filled in, including every repository and which one is home. No
project knowledge documents: the repositories are the source.
