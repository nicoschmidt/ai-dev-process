---
name: write-adr
description: Write an architecture decision record (MADR) before the code that implements it - context, real options, decision, consequences, follow-up issues - and update the ADR index and architecture overview. Use when a choice is expensive to reverse (technology, interface, data format, deployment, component boundary), or when one was made without an ADR.
---

# Write an ADR

The rules are `.claude/rules/process/decisions.md`. An ADR is written
**before** the code. Its value is the options that were not taken, and those
are forgotten within days.

## Is this an ADR?

Yes, if reversing it later means rewriting more than one component, migrating
data, or changing a contract someone else relies on. No, for a name, a local
refactoring, or anything one pull request could undo. When in doubt, ask the
maintainer in one sentence; do not write an ADR nobody needs.

## Steps

1. **An issue first, in the home repository** (`.ai-dev-process.conf`):
   usually a spike or a feature that names the decision. No issue → hand one
   over (`handover`). The ADR is written there even when the code it governs
   lives in a member repository.
2. **Number.** The next free number in `docs/adr/README.md`. Never reuse or
   renumber.
3. **Write** `docs/adr/NNNN-<decision-as-statement>.md` from
   `0000-template.md`, on the issue's branch:
   - **Context**: the forces, and which constraints are real and which only
     look that way.
   - **Options**: at least two that someone could seriously choose, each with
     what it makes good and what it makes bad. A straw man is not an option.
   - **Decision**: the reasoning that would convince someone who was not in
     the room.
   - **Consequences**: what becomes easy, what becomes hard, what we are now
     committed to, and **the signal that should make us revisit it**.
   - **Follow-up**: the issues and ADRs this creates.
4. **Status `proposed`** while the maintainer considers it. Chat is the place
   to argue the options; the file records the outcome.
5. **Accepting** happens in the same pull request, on the maintainer's word:
   status `accepted`, the index row in `docs/adr/README.md`, and the derived
   `docs/architecture.md` — one commit.
6. **Follow-ups become issues** before the pull request is merged, each in
   the repository it changes: hand them over in one script (`handover`).
7. **Members**: where the decision shapes a member repository, a follow-up
   there updates its `docs/architecture.md` — in its own words, standing on
   its own, without quoting private reasoning into a public repository.

## Changing a decision

Never rewrite an accepted ADR's decision, reasoning or consequences. Write a
new ADR that supersedes it, and set the old one's status to
`superseded by ADR-NNNN`. Typos, links and redaction of personal data may be
fixed in place.
