# Adopting ai-dev-process

For the maintainer. Three situations: a new project, an existing project, and
an upgrade. In a session, `/ai-dev-process:adopt-process` walks through the
same steps and hands over every command with the values filled in; this page
is what it follows.

## Once per machine and account

```bash
git clone https://github.com/nicoschmidt/ai-dev-process.git ~/coding/ai-dev-process
gh auth refresh -s project      # board fields need the project scope
```

The plugin, once per claude.ai account: *Customize → Plugins → Add → Add
marketplace* → `nicoschmidt/ai-dev-process` → add **ai-dev-process** → turn
on *Sync automatically*. Claude Code picks it up at its next start through the
same account. Without claude.ai, in Claude Code only:

```bash
claude plugin marketplace add nicoschmidt/ai-dev-process
claude plugin install ai-dev-process@ai-dev-process
```

## A new project

1. **The repository.** Create it with a first commit, so `main` exists:

   ```bash
   gh repo create <owner>/<repo> --public --add-readme --license mit --clone
   cd <repo>
   ```

2. **Labels**, so the issue templates' labels exist. From the process checkout
   with `GH_REPO`, because the project has no scripts yet:

   ```bash
   GH_REPO=<owner>/<repo> bash ~/coding/ai-dev-process/kit/scripts/process/setup-labels.sh
   ```

3. **The adoption issue and branch.** Create the issue, read its number, then
   branch with it:

   ```bash
   gh issue create --label type:chore --title "chore: adopt ai-dev-process v0.1.0" \
     --body "Install the kit, fill in CLAUDE.md, set up board and ruleset."
   git switch -c chore/<number>-ai-dev-process-0.1.0
   ```

4. **Install**, at a release tag:

   ```bash
   git -C ~/coding/ai-dev-process fetch --tags
   git -C ~/coding/ai-dev-process switch --detach v0.1.0
   bash ~/coding/ai-dev-process/install.sh "$PWD"
   ```

5. **Fill in `CLAUDE.md` and `docs/vision.md`** — best in a session, which
   asks for each process parameter instead of guessing. Every `<…>` is a
   placeholder; none may survive the pull request.

6. **The board.** Create it and its two fact fields; the project number comes
   from the first command's output:

   ```bash
   gh project create --owner <owner> --title "<project title>"
   gh project link <number> --owner <owner> --repo <owner>/<repo>
   gh project field-create <number> --owner <owner> --name Size --data-type SINGLE_SELECT --single-select-options "S,M,L"
   gh project field-create <number> --owner <owner> --name Iteration --data-type SINGLE_SELECT --single-select-options "Backlog,000 Setting up"
   ```

   The board's default `Status` field needs the options `Backlog`, `Ready`,
   `In progress`, `In review`, `Done`: *Project → ⋯ → Settings → Status*.

7. **Commit, push, pull request**:

   ```bash
   bash scripts/process/check-kit.sh
   git add -A && git commit -m "chore: adopt ai-dev-process 0.1.0"
   git push -u origin HEAD
   gh pr create --title "chore: adopt ai-dev-process 0.1.0" --body "Closes #<number>"
   ```

8. **Repository settings**, once CI has run on the pull request:
   - `gh repo edit <owner>/<repo> --delete-branch-on-merge`
   - *Settings → Rules → Rulesets → New branch ruleset*: name `main`, enforcement
     *Active*, target *Include default branch*; enable *Require a pull request
     before merging*, *Require status checks to pass* with `CI passed`, and
     *Block force pushes*.

9. **The claude.ai project.** Create one, paste
   [claude-project-instructions.template.md](claude-project-instructions.template.md)
   into its instructions with the values filled in, and add **no** project
   knowledge documents: the repository is the source, and a copy there is a
   second ledger that goes stale.

10. **Every further clone** runs `git config core.hooksPath .githooks` once.

## An existing project

The installer overwrites every file at a managed path, so the order matters:
take inventory first, install second. In a session:
`/ai-dev-process:adopt-process` in *existing* mode. It diffs the project's
files against the kit, sorts every difference into generic (→ an upstream
issue), project-specific (→ `CLAUDE.md`) or obsolete, moves references such as
`scripts/gh-board.sh` → `scripts/process/gh-board.sh`, and only then installs.

The aim of that pull request is **no change in behaviour**. Anything that does
change meaning is listed in its body.

## An upgrade

Between iterations:

```bash
git -C ~/coding/ai-dev-process fetch --tags
git -C ~/coding/ai-dev-process tag --sort=-v:refname | head -3
```

Read `CHANGELOG.md` from the project's version (in `.ai-dev-process.lock`) to
the new one. Then, with an issue and its branch as always:

```bash
git -C ~/coding/ai-dev-process switch --detach v<new>
bash ~/coding/ai-dev-process/install.sh "<project>"
```

The installer refuses if a managed file was edited in the project. That edit
is either a generic learning (→ upstream issue) or a project matter
(→ *Process deviations* in `CLAUDE.md`); restore the file, then re-run.
