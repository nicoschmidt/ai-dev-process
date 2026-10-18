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
the issue number, the board's field and option names
(`bash scripts/process/show-board.sh`).

## A new issue

1. Write the body to `../issue-<slug>-body.md`, following the issue form's
   headings. Acceptance criteria must be checkable.
2. Write `../create-<slug>.sh`:

   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   cd "<absolute path of the repository>"
   source scripts/process/gh-board.sh
   board_connect
   create_issue "type:feature" "M" "001 First release" \
     "Export the report as CSV" < "../issue-export-csv-body.md" || exit 1
   echo "issue: #$LAST_ISSUE_NUMBER"
   ```

   Several issues go in one script, in dependency order.
3. Exercise it against a stand-in `gh` (a function recording its arguments)
   and `bash -n` before handing it over.
4. Hand over:

   ```bash
   gh auth refresh -s project   # once per machine; gh auth login does not grant it
   bash "../create-export-csv.sh"
   ```

Status is never set. Moving the card to `Ready` is the maintainer's click.

## A pull request

The branch exists and carries the commits. The pull request number is
unknown until it exists, so the body file is named after the issue.

1. Write `../pr-<issue>-body.md` from `.github/pull_request_template.md`:
   what changes and why in one paragraph, `Closes #<issue>`, how it was
   verified (which tests, what was checked by hand), the definition of done
   with only the true items ticked, and what deserves a close look.
2. Hand over, in this order:

   ```bash
   cd "<absolute path of the repository>"
   git push -u origin feat/44-export-csv
   gh pr create --base main --head feat/44-export-csv \
     --title "feat: export the report as CSV" \
     --body-file "../pr-44-body.md"
   ```

3. Tell the maintainer what to look at first — the one place you are least
   sure of. Then the card goes to `In review` by their click.

## After the merge

```bash
cd "<absolute path of the repository>"
git switch main && git pull
git branch -d feat/44-export-csv
git push origin --delete feat/44-export-csv   # if it still exists
git fetch --prune
rm "../pr-44-body.md"
```

## Where a command is impossible

A review, a merge, a repository setting: name the exact path through the
interface — for example *Settings → Rules → Rulesets → New branch ruleset*.
