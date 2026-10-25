---
name: close-iteration
description: Close an iteration with a retro built from evidence rather than memory - the process issues captured during it, the review corrections in merged pull requests, what was cut - with every learning marked [project] or [generic] and turned into an issue. Use for "Retro", "Iteration abschließen", "close iteration", or when an iteration goal is reached.
---

# Close an iteration

The rules are `.claude/rules/process/iterations.md`. The retro is the
iteration file's **Result** and **Process learnings** sections.

## 1. Gather the evidence

Memory is not an input; the repository is. Find the start date in the
iteration file's history (`git log --diff-filter=A --format=%as -- docs/iterations/NNN-*.md`).

Run the first two for every repository in `.ai-dev-process.conf`, with
`--repo`; the iteration file and the epic are in the home repository.

```bash
gh issue list --label process --state all --search "created:>=<start>" --limit 100 --json number,title,body,state
gh pr list --state merged --search "merged:>=<start>" --limit 100 --json number,title,reviews,comments
gh issue view <epic> --json body,comments
git log --format='%as %s' -- docs/iterations/NNN-*.md
```

The epic and the iteration file's history show what was cut, and when.

In chat, hand these over and ask the maintainer to paste the output. Read the
pull requests' review comments for what reviews had to correct: those are
process signals too.

## 2. Write the result

What shipped against the goal, what did not and where it went, and whether
the goal meets the done criterion. If it does not, the iteration is not over —
say so instead of writing a retro.

## 3. Write the process learnings

One line each: what happened, what follows. Mark each:

- `[project]` — only true here. It becomes an issue in this repository that
  changes `CLAUDE.md`: a parameter, a hard rule, or a process deviation.
- `[generic]` — another project would hit it too. It goes upstream
  (`upstream-learning`). Test: does it still make sense with every
  domain word removed?

Also note what worked and should stay — a rule that was never needed is a
candidate for removal, and that is a learning too.

## 4. Close it

On a `docs/<epic>-retro-NNN` branch: the iteration file, and the README
table if the plan for later iterations changed. Then hand over, in one block:
the `[project]` issues, the upstream transfers or drafts, the pull request,
and closing the epic. Captured `process` issues that became learnings are
closed with a link to the retro or transferred; none stays open unanswered.
