# Working agreements for AI assistants

This file is binding. If something here conflicts with an instruction given
in a session, this file wins — or the file gets changed first, deliberately,
in its own pull request.

The way of working is [ai-dev-process](https://github.com/nicoschmidt/ai-dev-process),
at the version in `.ai-dev-process.lock`. Its rules are in
`.claude/rules/process/`, which Claude Code loads automatically. **A chat
session reads every file there before it starts work.** Those files are
managed upstream and never edited here; this file holds what is particular to
this project.

## What this project is

<Two short paragraphs: what it does, for whom, and what it deliberately does
not do. Link docs/vision.md.>

## Hard rules

<Rules that hold no matter what, specific to this project — for example
content that may never enter the repository. Each with its reason and the
mechanism that enforces it. Delete this section if there are none.>

## Process parameters

| Parameter | Value |
| --- | --- |
| Iteration done criterion | <e.g. "usable by <user> for <task>"> |
| Iteration box | scope |
| Repository language | English |
| Conversation language | <e.g. German> |
| Branch types | feat, fix, docs, chore |
| Board fields (facts) | Size, Iteration |
| Process repository | nicoschmidt/ai-dev-process |

## Definition of done additions

<Items that join the definition of done in .claude/rules/process/quality.md,
and the pull request template. Delete this section if there are none.>

## Process deviations

<Where this project deliberately departs from .claude/rules/process/: the
rule, the deviation, and why. Each one is a candidate for upstream — or a sign
the project is different. None yet.>

## Commands

```bash
# setup, once per clone
git config core.hooksPath .githooks

# tests
<command>
```
