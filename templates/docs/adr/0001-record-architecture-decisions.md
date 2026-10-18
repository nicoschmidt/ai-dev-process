# ADR-0001: Record architecture decisions

- **Status:** accepted
- **Date:** YYYY-MM-DD
- **Deciders:** Maintainer
- **Supersedes:** —
- **Superseded by:** —

## Context

This project is developed largely with AI assistance, across sessions that do
not share memory. An assistant that cannot see why a choice was made will
either re-litigate it or quietly violate it. The same is true of a human
returning to the project after a break.

## Decision drivers

- Continuity across sessions and across tools (Claude Code, chat).
- The reasoning behind a choice is more valuable than the choice itself.
- Decisions must live where the code lives, not in a chat history.

## Options considered

### Option A: Architecture Decision Records in the repository

Numbered markdown files under `docs/adr/`, written before the implementing
code, immutable once accepted.

- Good: versioned, reviewable in pull requests, readable by any session with
  repository access.
- Good: the history of superseded decisions survives.
- Bad: costs discipline; an unmaintained ADR set is worse than none.

### Option B: Keep decisions in chat history and issue comments

- Good: zero overhead at the moment of deciding.
- Bad: not readable by a fresh session, not diffable, not reviewable, and
  effectively lost within weeks.

## Decision

We choose **Option A**, following `.claude/rules/process/decisions.md`.

## Consequences

- Every architecturally significant pull request carries or references an
  ADR; the pull request template asks for it.
- `docs/architecture.md` is derived from accepted ADRs.
- The overhead is real and accepted: one short document per significant
  decision.

## Follow-up

- <the first decisions this project faces>
