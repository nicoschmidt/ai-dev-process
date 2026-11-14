---
name: plan-iteration
description: Plan the next iteration - a small milestone with a one-sentence goal that meets the project's done criterion, in every repository with issues in it, and the ready issues in it - and hand it over as one script. Use for "nächste Iteration planen", "plan iteration", "what's next", or when the previous retro is written.
---

# Plan an iteration

The rules are `.claude/rules/process/iterations.md`; the done criterion and
the iteration box are in `CLAUDE.md` under **Process parameters**. The plan is
the milestone: its goal in the description, its scope the issues in it. There
is no plan file and no epic; the iteration file is written when the milestone
closes (`close-iteration`).

## Before planning

- The previous milestone is closed and has its retro. If not, that comes
  first (`close-iteration`).
- Check whether a newer ai-dev-process release exists than the one in
  `.ai-dev-process.lock`. If one does, suggest the upgrade: it becomes the
  first issue of the milestone being planned (`adopt-process`, upgrade
  mode), and the maintainer decides.
- Read `docs/vision.md` (the MVP the iterations work towards), the open
  milestones, and the refined issues that are in none yet, in every
  repository of the project:

  ```bash
  gh api "repos/<owner>/<repo>/milestones?state=all&per_page=100" \
    --jq '.[] | "\(.title)  [\(.state), \(.open_issues) open]  \(.description)"'
  gh issue list --repo <owner>/<repo> --state open --search "no:milestone -label:idea" \
    --json number,title,labels
  ```

  A session that cannot run `gh` hands these over and asks for the output.

## Steps

1. **Goal, one sentence**, naming what the users can do afterwards that they
   could not do before, and meeting the done criterion. If it needs "and"
   twice, it is two iterations. Cut small: a handful of issues. The MVP is
   reached by several iterations, not by one large one.
2. **Title**: `NNN <short goal>`, where `NNN` follows the highest milestone
   number in the project. The same title in every repository that gets
   issues in it.
3. **Why this slice, and what is out of scope**: said in the conversation;
   what is worth keeping goes into the milestone's description after the goal
   sentence, in a line or two.
4. **Scope**: the issues it needs. Missing ones are written now, ready by the
   definition of ready: `type:` label, checkable criteria, `Needs:`. ADRs and
   spikes come first: they get the lower numbers, or the others name them in
   `Needs:`.
5. **Hand over one script** in the project folder, exercised against a
   stand-in `gh` and `bash -n` first:

   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   cd "$(dirname "$0")/<home repository>"
   source scripts/process/gh-issues.sh
   issues_connect

   ensure_milestone "003 Export" "Users can take the report into a spreadsheet." || exit 1
   create_issue "type:feature" "003 Export" "Export the report as CSV" \
     < ../issue-export-csv-body.md || exit 1
   set_milestone 41 "003 Export" || exit 1      # refined earlier, now planned
   ```

   `ensure_milestone` creates the milestone in the home repository and every
   member from `.ai-dev-process.conf`; name the repositories after the
   description to limit it to those with issues in it. Issues of a member
   repository follow `GH_REPO=<owner>/<member>` in the script. Hand over:

   ```bash
   bash plan-003.sh
   ```

Putting an issue into the milestone is the maintainer's decision that it is
ready. The script names every one, so it is read before it is run.

## A sound plan

- one goal, one sentence, meeting the done criterion
- small: a handful of issues
- every issue in it is ready, or an ADR or spike that comes first
- the milestone exists in every repository with issues in it
