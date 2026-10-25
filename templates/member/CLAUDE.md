# Working agreements for AI assistants

This repository is a **member** of a project of several repositories. What
holds for the whole project — what it is, its hard rules, its process
parameters — is in the home repository's `CLAUDE.md`, imported here from the
checkout beside this one:

@../<home repository directory>/CLAUDE.md

Claude Code asks once to allow that import, because it lies outside this
repository. If the home repository is not checked out beside this one, stop
and say so: without it, the project's hard rules are missing from the session.

The way of working is [ai-dev-process](https://github.com/nicoschmidt/ai-dev-process),
at the version in `.ai-dev-process.lock`, in `.claude/rules/process/`. The
board and the other repositories are named in `.ai-dev-process.conf`.

## What this repository is

<One paragraph: what it holds, for whom, whether it is public or private, and
how it is used together with the other repositories.>

## Hard rules for this repository

<Rules that hold here in addition to the project's — for example what may
never leave this repository, or never enter it. Each with its reason and the
mechanism that enforces it. Delete this section if there are none.>

## Definition of done additions

<Items for this repository only, mirrored in .github/pull_request_template.md.
Delete this section if there are none.>

## Process deviations

<Where this repository departs from .claude/rules/process/ or from the home
repository's parameters: the rule, the deviation, and why. None yet.>

## Commands

```bash
# setup, once per clone
git config core.hooksPath .githooks

# tests
<command>
```
