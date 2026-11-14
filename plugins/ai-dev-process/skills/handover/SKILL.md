---
name: handover
description: Hand a GitHub-facing step to the maintainer ready to run - a new issue with its label and milestone set, a pull request after work on a branch, or the cleanup after a merge. Use whenever work needs to reach GitHub, before saying "create an issue" or "open a PR", which are never acceptable on their own.
---

# Handover

The contract is `.claude/rules/process/handover.md`: the maintainer reads,
judges and pastes; the assistant composes everything. A handover is
**content in a file beside the repository** plus **one copy-paste block with
real values**. Never an instruction.

Before writing any command, check the facts it depends on instead of
remembering them: the remote (`git remote get-url origin`), the current branch,
the issue number, the milestone titles
(`gh api "repos/<owner>/<repo>/milestones" --jq '.[].title'`), the
repositories in `.ai-dev-process.conf`.

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
   source scripts/process/gh-issues.sh
   issues_connect
   create_issue "type:feature" "003 Export" "Export the report as CSV" \
     < ../issue-export-csv-body.md || exit 1
   echo "issue: #$LAST_ISSUE_NUMBER"
   ```

   Several issues go in one script, in dependency order. `create_issue`
   reuses an issue whose title is exactly the same, open or closed, so a
   script that failed halfway is run again as it is.
   The milestone is checked before anything is created. An idea, or an issue
   not planned yet, gets `""` instead of a milestone.
3. Exercise it against a stand-in `gh` (a function recording its arguments;
   it answers `gh issue list` with `[]` and the milestone lookup with the
   milestone) and `bash -n` before handing it over.
4. Hand over, to run in the project folder:

   ```bash
   bash create-export-csv.sh
   ```

The milestone is the maintainer's decision that the issue is ready. Say which
milestone each issue goes into, so it is read before it is run.

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
   sure of.

## A correction in review

The pull request is open and the maintainer asks for a change
(`workflow.md`, corrections in review). If it looks like an extension rather
than a refinement, say so once, and do as the maintainer decides.

1. Commit the correction on the same branch. Its reasoning starts with
   "At the maintainer's request in review:" and says what changed and why.
2. Write the amended criterion to `comment-<issue>-review.md` in the project
   folder.
3. Hand over, to run in the project folder:

   ```bash
   cd <repository>
   git push
   gh issue comment 44 --body-file ../comment-44-review.md
   cd ..
   rm comment-44-review.md
   ```

   A plain `git push`: the commit is added on top, nothing is rewritten.

## After the merge

```bash
cd <repository>
bash scripts/process/after-merge.sh feat/44-export-csv
cd ..
```

It switches to `main` and fast-forwards it, deletes the branch locally and
on the remote only where it is at the merged pull request's last commit, and
removes `pr-44-body.md` from the project folder. Whatever it keeps, it says
why. It works under every merge method; `git branch -d` does not after a
rebase or squash merge.

## Where a command is impossible

A review, a merge, a repository setting: name the exact path through the
interface — for example *Settings → Rules → Rulesets → New branch ruleset*.
