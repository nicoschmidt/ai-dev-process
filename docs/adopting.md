# Adopting ai-dev-process

For the maintainer. A project of one repository, a project of several, an
existing repository, and an upgrade. In a session,
`/ai-dev-process:adopt-process` walks through the same steps and hands over
every command with the values filled in; this page is what it follows.

## The project folder

Every project has a folder of its own, also a project of one repository. Its
repositories are subfolders under their repository names, and what is handed
over beside them (issue and pull request bodies, one-off scripts) lives there
too. Where the project folder lives is up to you; nothing in the process names
it. **Every block on this page starts and ends in the project folder**; where
it works inside a repository, it says so with `cd <repo>` and returns with
`cd ..`.

## Once per machine and account

```bash
gh auth refresh -s project      # board fields need the project scope
```

No checkout of ai-dev-process is needed: the installer is taken from the
release itself, fresh each time, into a temporary directory. In the terminal
the setup runs in, pick the newest release and fetch it:

```bash
git ls-remote --tags --refs https://github.com/nicoschmidt/ai-dev-process | sed 's|.*/||' | sort -V | tail -3
AIDP="$(mktemp -d)" && git -c advice.detachedHead=false clone -q --depth 1 \
  --branch v<version> https://github.com/nicoschmidt/ai-dev-process "$AIDP"
```

`$AIDP` lasts as long as that terminal; in a new one, fetch again.

The plugin, once per claude.ai account: *Customize → Plugins → Add → Add
marketplace* → `nicoschmidt/ai-dev-process` → add **ai-dev-process** → turn
on *Sync automatically*. Claude Code picks it up at its next start through the
same account. Without claude.ai, in Claude Code only:

```bash
claude plugin marketplace add nicoschmidt/ai-dev-process
claude plugin install ai-dev-process@ai-dev-process
```

## Roles

Every repository is installed with a role, recorded in `.ai-dev-process.lock`:

| Role | When | What it receives beyond the shared kit |
| --- | --- | --- |
| `single` | the project is this one repository (the default) | ADR and iteration templates, vision, ADR-0001, the project `CLAUDE.md` |
| `home` | the project's home among several repositories | the same as `single` |
| `member` | another repository of the project | a `CLAUDE.md` that imports the home one, a standalone `docs/architecture.md` |

Every role receives `.ai-dev-process.conf`, which names the board, the home
repository and the members, the same in every repository of the project. What
lives where is in `.claude/rules/process/repositories.md`.

## A project of one repository

1. **The repository**, with a first commit so `main` exists:

   ```bash
   gh repo create <owner>/<repo> --public --add-readme --license mit --clone
   ```

2. **The board.** The number comes from the first command's output:

   ```bash
   gh project create --owner <owner> --title "<project title>"
   gh project link <number> --owner <owner> --repo <owner>/<repo>
   gh project field-create <number> --owner <owner> --name Size --data-type SINGLE_SELECT --single-select-options "S,M,L"
   gh project field-create <number> --owner <owner> --name Iteration --data-type SINGLE_SELECT --single-select-options "Backlog,000 Setting up"
   ```

   The board's `Status` field needs the options `Backlog`, `Ready`,
   `In progress`, `In review`, `Done`: *Project → ⋯ → Settings → Status*.

3. **Labels**, so the issue forms' labels exist. Existing labels are left as
   they are:

   ```bash
   GH_REPO=<owner>/<repo> bash "$AIDP/kit/common/scripts/process/setup-labels.sh"
   ```

4. **The adoption issue and branch.** Create the issue, read its number, then
   branch with it:

   ```bash
   cd <repo>
   gh issue create --label type:chore --title "chore: adopt ai-dev-process v<version>" \
     --body "Install the kit, fill in CLAUDE.md and .ai-dev-process.conf, set up the ruleset."
   git switch -c chore/<number>-ai-dev-process-<version>
   cd ..
   ```

5. **Install** the release fetched above:

   ```bash
   bash "$AIDP/install.sh" <repo>
   ```

6. **Fill in** `.ai-dev-process.conf` (board, and this repository as
   `home_repo`), `CLAUDE.md` and `docs/vision.md` — best in a session, which
   asks for each process parameter instead of guessing. No `<…>` may survive
   the pull request.

7. **Commit, push, pull request**:

   ```bash
   cd <repo>
   bash scripts/process/check-kit.sh
   git add -A && git commit -m "chore: adopt ai-dev-process <version>"
   git push -u origin HEAD
   gh pr create --title "chore: adopt ai-dev-process <version>" --body "Closes #<number>"
   cd ..
   ```

8. **Repository settings**, once CI has run on the pull request:
   - `gh repo edit <owner>/<repo> --delete-branch-on-merge`
   - *Settings → Rules → Rulesets → New branch ruleset*: name `main`,
     enforcement *Active*, target *Include default branch*; enable *Require a
     pull request before merging*, *Require status checks to pass* with
     `CI passed`, and *Block force pushes*.

9. **The claude.ai project.** Paste
   [claude-project-instructions.template.md](claude-project-instructions.template.md)
   into its instructions with the values filled in (the project folder's name
   and its repositories, no absolute path), and add **no** project knowledge
   documents.

10. **Every further clone** runs `git -C <repo> config core.hooksPath .githooks`
    once.

## A project of several repositories

The same steps, with these differences:

- **Check them out in the project folder**, under their repository names. A
  member's `CLAUDE.md` imports `../<home>/CLAUDE.md`.
- **One board** for all of them: create it once (step 2), and run
  `gh project link` once per repository.
- **Per repository**: labels (step 3), its own adoption issue and branch
  (step 4), the install with its role, the pull request and the ruleset.

  ```bash
  bash "$AIDP/install.sh" --role home   <home>
  bash "$AIDP/install.sh" --role member <member>
  ```

- **`.ai-dev-process.conf` is identical** in every repository:
  `board_owner`, `board_number`, `home_repo`, `member_repos`.
- **The home repository** gets the project's `CLAUDE.md`, vision, ADRs and
  iterations. Its ADR-0002 records the repository layout: which repository
  holds what, which are public, and what may never move from private to
  public.
- **A member's `CLAUDE.md`** names the home directory in its import line and
  says what this repository is. Claude Code asks once to allow that import,
  because it lies outside the repository.
- **Merge order**: the home repository's adoption first, then the members.
  Their `CLAUDE.md` refers to it.
- **The claude.ai project** is one for the whole project. Its instructions
  list every repository and say which one is home.

A home repository may be created only for that purpose — a private one, for
instance, when the project's decisions and plans touch material the public
repositories must not show.

## An existing repository

The installer overwrites every file at a managed path, so the order matters:
take inventory first, install second. In a session:
`/ai-dev-process:adopt-process` in *existing* mode. It diffs the repository's
files against the kit, sorts every difference into generic (→ an upstream
issue), project-specific (→ `CLAUDE.md`) or obsolete, moves references to
files whose path changes, and only then installs. Documents that are really
iteration notes or decisions move to the home repository in an issue of their
own.

A repository with code but no process files of its own is the simple case:
the inventory is short, and the pull request mostly adds.

The aim of that pull request is **no change in behaviour**. Anything that does
change meaning is listed in its body.

## An upgrade

Between iterations, and every repository of a project to the same version.
Fetch the new release as in [Once per machine](#once-per-machine-and-account),
and read `"$AIDP/CHANGELOG.md"` from the project's version (in
`.ai-dev-process.lock`) to the new one. Then, with an issue and its branch in
each repository, in the project folder:

```bash
bash "$AIDP/install.sh" <repository>
```

The role is read from the lock; a lock from 0.1.0 is read as `single`. The
installer refuses if a managed file was edited in the repository. That edit is
either a generic learning (→ upstream issue) or a project matter
(→ *Process deviations* in `CLAUDE.md`); restore the file, then re-run.
