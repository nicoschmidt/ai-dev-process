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

No checkout of ai-dev-process is needed, and no extra `gh` scope: the installer is taken from the
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

Every role receives `.ai-dev-process.conf`, which names the home repository
and the members, the same in every repository of the project. What
lives where is in `.claude/rules/process/repositories.md`.

## A project of one repository

1. **The repository**, with a first commit so `main` exists:

   ```bash
   gh repo create <owner>/<repo> --public --add-readme --license mit --clone
   ```

2. **The first milestone**, which the adoption issue goes into. Iterations
   are milestones; there is no board to set up:

   ```bash
   gh api repos/<owner>/<repo>/milestones -f title="000 Setting up" \
     -f description="The process runs end to end, and the first iteration can be planned."
   ```

3. **Labels**, so the issue forms' labels exist. Existing labels are left as
   they are:

   ```bash
   GH_REPO=<owner>/<repo> bash "$AIDP/kit/common/scripts/process/setup-labels.sh"
   ```

4. **The adoption issue and branch.** Create the issue, read its number, then
   branch with it:

   ```bash
   cd <repo>
   gh issue create --label type:chore --milestone "000 Setting up" \
     --title "chore: adopt ai-dev-process v<version>" \
     --body "Install the kit, fill in CLAUDE.md and .ai-dev-process.conf, set up the ruleset."
   git switch -c chore/<number>-ai-dev-process-<version>
   cd ..
   ```

5. **Install** the release fetched above:

   ```bash
   bash "$AIDP/install.sh" <repo>
   ```

6. **Fill in** `.ai-dev-process.conf` (this repository as `home_repo`), `CLAUDE.md` and `docs/vision.md` — best in a session, which
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
- **The milestone `000 Setting up`** in every repository (step 2), with the
  same title.
- **Per repository**: labels (step 3), its own adoption issue and branch
  (step 4), the install with its role, the pull request and the ruleset.

  ```bash
  bash "$AIDP/install.sh" --role home   <home>
  bash "$AIDP/install.sh" --role member <member>
  ```

- **`.ai-dev-process.conf` is identical** in every repository: `home_repo`,
  `member_repos`.
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

### From a board, to 0.3.0 or later

Since 0.3.0 an iteration is a milestone, and nothing a session needs is kept
on a project board. A project whose `.ai-dev-process.conf` still names
`board_number` carries the board over before it installs; in a session,
`/ai-dev-process:adopt-process` in upgrade mode walks through it.

1. **Read the board's open items** once, in the project folder:

   ```bash
   gh auth refresh -s read:project       # reading a board needs it, once
   gh project item-list <board_number> --owner <board_owner> --format json --limit 500 \
     --jq '.items[] | select(.status != "Done") | [.content.repository // "-", (.content.number // "draft" | tostring), .status // "-", .iteration // "-", .title] | @tsv' \
     > board-open-items.tsv
   ```

2. **Each iteration with open items becomes a milestone** of the same title,
   in every repository with items in it, its goal in the description. Its
   open issues go into it; its epic is closed with a link to the milestone.
3. **Items without an iteration get no milestone**: refined but not ready,
   or still ideas. Draft items become `idea` issues or are dropped.
4. **An MVP epic** becomes the MVP section of `docs/vision.md` and is closed.
5. **In the upgrade's pull request**, in every repository: `board_owner` and
   `board_number` leave `.ai-dev-process.conf`, the board fields row leaves
   the process parameters in `CLAUDE.md`, and so does any deviation about the
   board. In the claude.ai project instructions, `.ai-dev-process.conf` is
   "the repositories", no longer "the board and the repositories".
6. **The board** may stay as your view, grouped by milestone, or be closed.
   No session relies on it.

Steps 2 to 4 are one handover script, idempotent and rehearsed against a
stand-in before it reaches you.
