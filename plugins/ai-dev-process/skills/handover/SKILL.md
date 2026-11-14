---
name: handover
description: Hand a GitHub-facing step to the maintainer ready to run - a new issue with its board fields set, a pull request after work on a branch, or the cleanup after a merge. Use whenever work needs to reach GitHub, before saying "create an issue" or "open a PR", which are never acceptable on their own.
---

# Handover

The contract is `.claude/rules/process/handover.md`: the maintainer reads,
judges and pastes; the assistant composes everything. A handover is
**content in a file beside the repository** plus **one copy-paste block with
real values**. Never an instruction.

Before writing any command, check the facts it depends on instead of
remembering them: the remote (`git remote get-url origin`), the current branch,
the issue number, the board in `.ai-dev-process.conf`, the board's field and
option names (`bash scripts/process/show-board.sh`).

Every block runs in the project folder and names no absolute path: it starts
with `cd <repository>` (the repository's directory in the project folder) and
ends with `cd ..`, so the next block starts there again; a `gh` call aimed at
another repository carries `--repo`. A script lives in
the project folder and starts with `cd "$(dirname "$0")/<repository>"`, so it
runs from anywhere. An issue in another repository of the project is created
with `GH_REPO=<owner>/<repo>` in front of the script.

## A new issue

1. Write the body to `issue-<slug>-body.md` in the project folder, following
   the issue form's headings. Acceptance criteria must be checkable.
2. Write `create-<slug>.sh` in the project folder:

   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   cd "$(dirname "$0")/<repository>"
   source scripts/process/gh-board.sh
   board_connect
   create_issue "type:feature" "M" "001 First release" \
     "Export the report as CSV" < "../issue-export-csv-body.md" || exit 1
   echo "issue: #$LAST_ISSUE_NUMBER"
   ```

   Several issues go in one script, in dependency order. `create_issue`
   reuses an issue whose title is exactly the same, open or closed, so a
   script that failed halfway is run again as it is.
3. Exercise it against a stand-in `gh` (a function recording its arguments;
   it answers `gh issue list` with `[]`) and `bash -n` before handing it
   over.
4. Hand over, to run in the project folder:

   ```bash
   gh auth refresh -s project   # once per machine; gh auth login does not grant it
   bash create-export-csv.sh
   ```

Status is never set. Moving the card to `Ready` is the maintainer's click.

## A pull request

The branch exists and carries the commits. The pull request number is
unknown until it exists, so the body file is named after the issue.

1. Write `pr-<issue>-body.md` in the project folder from
   `.github/pull_request_template.md`:
   what changes and why in one paragraph, `Closes #<issue>`, how it was
   verified (which tests, what was checked by hand), the definition of done
   with only the true items ticked, and what deserves a close look.
2. Hand over, in this order, to run in the project folder:

   ```bash
   cd <repository>
   git push -u origin feat/44-export-csv
   gh pr create --base main --head feat/44-export-csv \
     --title "feat: export the report as CSV" \
     --body-file "../pr-44-body.md"
   cd ..
   ```

3. Tell the maintainer what to look at first — the one place you are least
   sure of. Then the card goes to `In review` by their click.

## After the merge

```bash
cd <repository>
git switch main && git pull
git branch -d feat/44-export-csv
git push origin --delete feat/44-export-csv   # if it still exists
git fetch --prune
cd ..
rm pr-44-body.md
```

## Where a command is impossible

A review, a merge, a repository setting: name the exact path through the
interface — for example *Settings → Rules → Rulesets → New branch ruleset*.
