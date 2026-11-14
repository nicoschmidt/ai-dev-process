---
name: close-iteration
description: Close an iteration with a retro built from evidence rather than memory - the milestone's issues, the process issues captured during it, the merged pull requests with their reviews and commits, what was added and what moves on - with every learning marked [project] or [generic], the milestone closed and the retro handed over. Use for "Retro", "Iteration abschließen", "close iteration", when an iteration's goal is reached, or when its milestone has no open issues left.
---

# Close an iteration

The rules are `.claude/rules/process/iterations.md`. The iteration is a
milestone; the retro is a file in `docs/iterations/` of the home repository,
from `TEMPLATE.md`, written now.

## 1. Gather the evidence

Memory is not an input; the repository is. Run these for every repository
with the milestone, with `--repo`; the start is the milestone's `created_at`.

```bash
gh api "repos/<owner>/<repo>/milestones?state=all&per_page=100" \
  --jq '.[] | select(.title == "<NNN title>") | {number, created_at, open_issues, closed_issues, description}'
gh issue list --repo <owner>/<repo> --milestone "<NNN title>" --state all --limit 200 \
  --json number,title,state,closedAt,labels
gh issue list --repo <owner>/<repo> --label process --state all --search "created:>=<start>" \
  --limit 100 --json number,title,body,state
gh pr list --repo <owner>/<repo> --state merged --search "merged:>=<start>" --limit 100 \
  --json number,title,author,reviews,comments,commits
```

A session that cannot run `gh` hands them over and asks for the output.

- **What reviews corrected**: the review comments, and the commits on each
  merged pull request with their authors and messages. A correction made in
  review is a commit of its own, often by the maintainer, or one whose
  reasoning says it was asked for in review.
- **What was added while it ran**: issues put into the milestone after the
  start (`gh api repos/<owner>/<repo>/issues/<n>/events --jq '.[] | select(.event == "milestoned") | .created_at'`).
- **What moves on**: the milestone's open issues.

## 2. Write the result

What shipped against the goal, what was added and why, what moves on and
where to, and whether the goal meets the done criterion. If it does not and
issues remain, the iteration is not over: say so instead of writing a retro.
If the goal is met with issues still open, it is over; they move on.

## 3. Write the process learnings

One line each: what happened, what follows. Mark each:

- `[project]`: only true here. It becomes an issue in this repository that
  changes `CLAUDE.md`: a parameter, a hard rule, or a process deviation.
- `[generic]`: another project would hit it too. It goes upstream
  (`upstream-learning`). Test: does it still make sense with every domain
  word removed?

Also note what worked and should stay. A rule that was never needed is a
candidate for removal, and that is a learning too.

## 4. Close it

Write `docs/iterations/NNN-<short-goal>.md` from `TEMPLATE.md` and its row in
the README's table on a local branch `docs/retro-NNN` in the home repository.
Its issue does not exist yet, so the handover script, in the project folder,
does the rest in this order:

1. `create_issue "type:chore" "<NNN title>" "docs: retro of <NNN title>"`,
   then rename the branch to `docs/<number>-retro-NNN` with the number it
   read
2. each open issue of the milestone to the next milestone
   (`set_milestone <n> "<next>"`) or back to refinement
   (`gh issue edit <n> --remove-milestone`)
3. close the milestone in every repository:
   `gh api -X PATCH "repos/<owner>/<repo>/milestones/<number>" -f state=closed`
4. the `[project]` issues, and the upstream transfers or drafts
5. push the branch and open the pull request, `Closes #<retro issue>`

Exercise it against a stand-in first. Captured `process` issues that became
learnings are closed with a link to the retro, or transferred; none stays open
unanswered.
