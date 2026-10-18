---
name: upstream-learning
description: Send a generic process learning from a project to the ai-dev-process repository - by transferring the captured issue or drafting a new one, written without project specifics and with evidence, proposal and reason. Use when a retro or refinement marks something [generic], or the maintainer says a rule should change everywhere.
---

# Send a learning upstream

The process repository is named in `CLAUDE.md` (default
`nicoschmidt/ai-dev-process`). Learnings are never patched into the managed
files in a project; they change upstream and arrive with the next upgrade.

## Write it so it survives the move

A rule that arrives without its reason gets weakened by the next session that
has not felt the pain. Every upstream issue states:

- **Observation** — what happened, in which project, with links to the
  issues, pull requests or retro that show it
- **Proposal** — the rule, mechanism or skill change; prefer a mechanism (a
  script, a check, a hook) where one is cheap
- **Reason** — why it holds beyond this project; remove every domain word and
  check it still reads true
- **Cost** — what it adds to every project's sessions, and what it would
  break on upgrade

## Hand it over

Either transfer the captured issue, then add the missing sections:

```bash
gh issue transfer 43 nicoschmidt/ai-dev-process
gh issue edit <new number> --repo nicoschmidt/ai-dev-process \
  --body-file "../upstream-43-body.md" --add-label "from:<project repository name>"
```

The new number is printed by the transfer; the script reads it from there
instead of guessing. Or draft a new one:

```bash
gh label create "from:<project repository name>" --repo nicoschmidt/ai-dev-process --color BFD4F2 --force
gh issue create --repo nicoschmidt/ai-dev-process --label process \
  --label "from:<project repository name>" \
  --title "<the change, as a statement>" --body-file "../upstream-<slug>-body.md"
```

As always: real values, exercised against a stand-in, bodies beside the
repository. The project keeps no copy of the learning — the link in its retro
is enough.
