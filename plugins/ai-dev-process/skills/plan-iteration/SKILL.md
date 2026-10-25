---
name: plan-iteration
description: Plan the next iteration - a one-sentence goal that meets the project's done criterion, why this slice, what is out of scope, the cut order if it grows, an epic and ready issues - and hand it over. Use for "nächste Iteration planen", "plan iteration", "what's next", or when the previous retro is written.
---

# Plan an iteration

The rules are `.claude/rules/process/iterations.md`; the done criterion and
the iteration box are in `CLAUDE.md` under **Process parameters**.

## Before planning

- The previous iteration has a retro note. If not, that comes first
  (`close-iteration`).
- Check whether a newer ai-dev-process release exists than the one in
  `.ai-dev-process.lock`. Between iterations is the time to upgrade
  (`adopt-process`, upgrade mode) — suggest it, do not slip it into the plan.
- Read `docs/vision.md`, the iterations README's plan, and the open issues on
  the board.

## Steps

1. **Goal, one sentence**, naming what the users can do afterwards that they
   could not do before, and meeting the done criterion. If it needs "and"
   twice, it is two iterations.
2. **Why this slice**: what it proves, and why now rather than later.
3. **Out of scope**: what is deliberately deferred, and to where.
4. **If it grows**: the cut order, decided now while nobody is attached to
   anything. With a scope box nothing else stops growth.
5. **Scope**: the issues it needs. Missing ones are written now, ready by the
   definition of ready; open ADRs come first in the order.
6. **Write** `docs/iterations/NNN-<short-goal>.md` from `TEMPLATE.md` and add
   its row to the README's table, on a `docs/<epic>-plan-iteration-NNN` branch
   — in the home repository. The epic issue is created there first, so its
   number is known. Scope issues may live in any repository of the project;
   list them as `owner/repo#n`.
7. **Board**: the iteration needs an option in the board's `Iteration` field.
   That is a setting, not a command: *Project → ⋯ → Settings → Iteration →
   Add option*, named exactly as the issues will refer to it.
8. **Hand over** in this order: the epic issue, then the board option, then
   the scope issues (they reference the option), then the plan's pull request.

## A sound plan

- one goal, one sentence, meeting the done criterion
- every issue in scope is ready, or is an ADR or spike that comes first
- nothing `L` in scope
- the cut order exists
