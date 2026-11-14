---
name: adopt-process
description: Install ai-dev-process in a new or existing project of one or several repositories, or upgrade a project to a newer release - roles, issue, branch, install.sh, process parameters, .ai-dev-process.conf, labels, the first milestone, ruleset and claude.ai project instructions. Use for "neues Projekt aufsetzen", "Prozess übernehmen", "adopt the process", "upgrade ai-dev-process".
---

# Adopt or upgrade ai-dev-process

The installer is `install.sh` of `nicoschmidt/ai-dev-process`, taken from a
fresh clone of the release tag in a temporary directory. That installs
exactly the release, needs no path to a checkout of the process, and leaves
the maintainer's own checkout alone. The full human-facing guide is
`docs/adopting.md` there; this skill is the assistant's side of it. Adopting is work like any other: issue, branch, pull request — in
each repository.

## Decide first

- **The project folder**: its name (by default the project's name, as in the
  claude.ai project) and the repositories in it, under their repository
  names. Settle it before anything is written that names a repository's
  directory. Every command below runs in the project folder; none names an
  absolute path, because where that folder lives is the maintainer's
  (`repositories.md`).
- **Mode**: **new** (the repository is empty or nearly so), **existing** (it
  has code, data or its own process files), or **upgrade**
  (`.ai-dev-process.lock` names an older version).
- **Repositories**: one, or several. With several, which one is the **home**
  (vision, ADRs, iterations — `.claude/rules/process/repositories.md`)
  and which are **members**. A home repository may be one created only for
  that purpose. Ask; this is the maintainer's decision, and the first ADR in
  the home repository records it.
- **Visibility**: which repositories are public and which private. If both
  exist, the project's hard rules say what may never move from private to
  public, and a check in the public repository's CI enforces what it can.

## Common first steps

1. Pick the release, and fetch it into a temporary directory, in the
   terminal the rest of the handover runs in:

   ```bash
   git ls-remote --tags --refs https://github.com/nicoschmidt/ai-dev-process | sed 's|.*/||' | sort -V | tail -3
   AIDP="$(mktemp -d)" && git -c advice.detachedHead=false clone -q --depth 1 \
     --branch v<version> https://github.com/nicoschmidt/ai-dev-process "$AIDP"
   ```

2. **Per repository, hand over one command** to run in the project folder
   (home first), with real values:

   ```bash
   bash "$AIDP/setup-repository.sh" --role <single|home|member> <owner>/<repo>
   ```

   Add `--create public` or `--create private` for a repository that does not
   exist yet. The script clones the repository into the project folder, creates
   the labels, the milestone `000 Setting up`, the adoption issue in it and
   the branch carrying the issue's number, and installs the release. Every
   step checks what exists, so a failed run is run again. It stops before any
   commit and lists the placeholders left. Do not compose these steps by hand;
   the script is tested, and `docs/adopting.md` explains what it does.

## Fill in

With the maintainer — ask, do not guess:

- **`.ai-dev-process.conf`**, identical in every repository: `home_repo`,
  `member_repos`.
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

Then hand over, per repository, in the project folder:

```bash
bash "$AIDP/finish-setup.sh" <repository>
```

It refuses while `CLAUDE.md` or `.ai-dev-process.conf` holds a `<…>`
placeholder, then runs `check-kit.sh`, commits, pushes and opens the pull
request that closes the adoption issue. If the terminal was closed since
step 1, fetch the release again first. The repository settings (ruleset,
delete branch on merge) follow `docs/adopting.md`.

## existing

Before `setup-repository.sh`, take inventory — its install overwrites any
file at a managed path:

1. For each managed path
   (`git -C "$AIDP" ls-files kit | sed 's|^kit/[a-z]*/||'`)
   that exists in the repository, diff it against the kit.
2. Classify every difference, and every piece of the repository's own process
   text outside managed paths (an old `CLAUDE.md`, `docs/process.md`,
   scripts): **generic** (→ upstream issue), **project** (→ `CLAUDE.md` or a
   member's `CLAUDE.md`), or **obsolete**.
3. Documents that are really iteration notes, specs or decisions — checkpoint
   files, planning notes — belong in the home repository. Moving them is its
   own issue; in a public repository, check first that they hold nothing
   private.
4. Find references to paths that move (`grep -rn "<old path>" .`) and
   update them in the same pull request.

Rehearse the whole install against a fresh clone of `main` with a stand-in
`gh` before handing it over, and give the handover a precondition on the
commit it was prepared against. The aim of that pull request is no change in
behaviour; say so in its body, and list everything whose meaning changed.

## upgrade

Upgrade between iterations, not in the middle of one, and all repositories of
a project to the same version.

1. Fetch the new release (step 1 above), read `"$AIDP/CHANGELOG.md"` between
   the two versions, and say what each change means for this project.
2. **The milestone**: the upgrade is the first issue of the next iteration's
   milestone (`iterations.md`). If that milestone is not planned yet, plan it
   first (`plan-iteration`), or ask the maintainer which one.
3. **The provisional branch**: the upgrade's issue does not exist yet, so
   commit on `chore/ai-dev-process-<version>` in each repository. Install
   there; the role comes from the lock. The installer refuses if a managed
   file was edited; resolve that first (upstream issue or deviation), never
   by forcing.
4. A change that needs a new parameter, a new key in `.ai-dev-process.conf`,
   or makes a deviation obsolete is made on the same branch.
5. **Hand over one script** in the project folder that, for each repository
   (home first), creates the issue in the milestone, renames the branch to
   carry its number, pushes it and opens the pull request. The helpers come
   from the branch, which already holds the new release. Run it against a
   stand-in first; it must be safe to run twice:

   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   PROJECT="$(cd "$(dirname "$0")" && pwd)"
   VERSION=0.4.0
   MILESTONE="004 Session journal"
   for repo in <home> <member>; do
     cd "$PROJECT/$repo"
     source scripts/process/gh-issues.sh
     GH_REPO=""; issues_connect
     create_issue "type:chore" "$MILESTONE" "chore: upgrade ai-dev-process to $VERSION" \
       < "$PROJECT/issue-upgrade-$VERSION-body.md" || exit 1
     branch="chore/$LAST_ISSUE_NUMBER-ai-dev-process-$VERSION"
     if git rev-parse -q --verify "refs/heads/chore/ai-dev-process-$VERSION" >/dev/null; then
       git branch -m "chore/ai-dev-process-$VERSION" "$branch"
     fi
     git push -u origin "$branch"
     if [ -z "$(gh pr list --head "$branch" --state open --json number --jq '.[].number')" ]; then
       sed "s/#ISSUE_NUMBER/#$LAST_ISSUE_NUMBER/" "$PROJECT/pr-upgrade-$VERSION-body.md" \
         | gh pr create --base main --head "$branch" \
             --title "chore: upgrade ai-dev-process to $VERSION" --body-file -
     fi
   done
   ```

   The pull request body says `Closes #ISSUE_NUMBER`; the script fills in the
   number. Merge order: the home repository first.

### From a board (a lock before 0.3.0, `board_number` in the conf)

Since 0.3.0 an iteration is a milestone and nothing a session needs is kept
on a board. Before installing, carry what the board holds over:

1. **Read the board once**, on the maintainer's machine, the only place with
   GraphQL. Hand over, in the project folder, with the values from
   `.ai-dev-process.conf`:

   ```bash
   gh auth refresh -s read:project       # reading a board needs it, once
   gh project item-list <board_number> --owner <board_owner> --format json --limit 500 \
     --jq '.items[] | select(.status != "Done") | [.content.repository // "-", (.content.number // "draft" | tostring), .status // "-", .iteration // "-", .title] | @tsv' \
     > board-open-items.tsv
   ```

   Ask the maintainer to paste the file, or read it from the project folder.
2. **Propose the mapping**, one line per item, and let the maintainer decide:
   - each iteration with open items becomes a milestone of the same title, in
     every repository with items in it; its description is the goal sentence
     from the iteration's epic or iteration file
   - its open issues go into it; an epic is closed with a link to the
     milestone instead
   - items without an iteration get no milestone, which now means refined but
     not ready, or still an idea
   - an MVP epic becomes the MVP section of `docs/vision.md`, in the upgrade's
     pull request, and is closed with a link to it
   - a draft item becomes an `idea` issue, or is dropped
3. **Hand over one script** in the project folder that applies it with the
   new release's helpers (`source "$AIDP/kit/common/scripts/process/gh-issues.sh"`):
   `ensure_milestone`, `set_milestone`, `gh issue close <epic> --comment …`.
   Exercise it against a stand-in first; it must be safe to run twice.
4. **In the upgrade's pull request**, in every repository: remove
   `board_owner` and `board_number` from `.ai-dev-process.conf`, the board
   fields row from the process parameters in `CLAUDE.md`, and any deviation
   that names the board. An iteration file written as a plan stays as it is;
   its Result and Process learnings are filled in when the milestone closes.
5. **The board** may stay as the maintainer's view, grouped by milestone, or
   be closed (`gh project close <number> --owner <owner>`). The maintainer
   decides; no session relies on it.
6. The claude.ai project instructions name `.ai-dev-process.conf` as "the
   board and the repositories": update that line to "the repositories".

## The claude.ai project

One claude.ai project per project, however many repositories. Hand over
`docs/claude-project-instructions.template.md` from the release with every
value filled in: the project folder's name, every repository in it, and which
one is home. No absolute path. No
project knowledge documents: the repositories are the source.
