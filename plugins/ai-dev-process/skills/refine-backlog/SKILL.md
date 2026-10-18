---
name: refine-backlog
description: Run a refinement session that empties the idea inbox - close, merge, transfer or refine each open issue labelled idea until it meets the definition of ready, with every outcome handed over as one script. Use for "refinement", "Backlog aufräumen", "ideas durchgehen", or when ideas have piled up.
---

# Refinement session

Turns `idea` issues into ready work, or closes them. The rules are in
`.claude/rules/process/workflow.md` (definition of ready) and `handover.md`;
where this skill and a rule disagree, the rule wins.

## 1. Get the inbox

- **Claude Code:** read it yourself (read-only):

  ```bash
  gh issue list --label idea --state open --limit 100 --json number,title,body,labels,createdAt
  ```

- **Chat:** chat cannot read GitHub's list pages. Hand over the command above
  and ask the maintainer to paste its output, or to paste issue links.

Leave `process` ideas for the retro unless the maintainer wants one now.

## 2. Propose an outcome per idea

Present them as a short table — number, title, proposed outcome, one-line
reason — and let the maintainer decide, row by row or all at once:

| Outcome | When |
| --- | --- |
| **close** (not planned) | It no longer matters, or never will. Most ideas end here, and that is fine. |
| **merge** | An existing issue already covers it: comment there, close this as duplicate. |
| **transfer** | It is about the process in general → the process repository from `CLAUDE.md`. |
| **refine** | It is worth doing. Continue with step 3. |

## 3. Refine

For each idea to refine, write the body to the matching template — feature,
bug or spike, the headings exactly as the issue forms render them
(`### What and for whom`, `### Acceptance criteria`, …). Then check it
against the definition of ready:

- acceptance criteria are checkable statements ("the export contains one row per
  entry, with a header"), not intentions ("make exporting better")
- small enough for one pull request; if it is `L`, cut it into several issues
  now and refine those instead
- the ADR it depends on is named, or "none"; if an ADR is missing, the first
  issue is the ADR
- size (`S`, `M`, `L` — or whatever the board offers) and iteration are chosen

Ask about anything you would otherwise have to guess. A wrong acceptance
criterion costs more than a question.

## 4. Hand over one script

Write every body to a file beside the repository (`../issue-<n>-body.md`)
and one script `../refine-<YYYY-MM-DD>.sh` that applies all outcomes in
order. Real numbers, no placeholders:

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "<absolute path of the repository>"
source scripts/process/gh-board.sh
board_connect

# close
gh issue close 41 --reason "not planned" --comment "Superseded by #23."

# merge
gh issue comment 30 --body "Also from #42: include the totals row."
gh issue close 42 --reason "not planned" --comment "Duplicate of #30."

# transfer
gh issue transfer 43 nicoschmidt/ai-dev-process

# refine
gh issue edit 44 --title "Export the report as CSV" \
  --body-file "../issue-44-body.md" --remove-label idea --add-label type:feature
set_issue_fields 44 S "001 First release" || exit 1
```

Before handing it over, run it once against a stand-in: a `gh` shell function
that records its arguments instead of calling GitHub, and `bash -n` on the
file. Show the maintainer the recorded calls. Then hand over:

```bash
bash "../refine-<YYYY-MM-DD>.sh"
```

Moving refined issues to `Ready` stays the maintainer's click on the board.
After the script has run, the body files and the script are deleted — they
were content, and the issues now hold it.
