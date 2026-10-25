# Rationale

Why each rule exists. A rule that travels to a project without its reason is
weakened by the first session that has not felt the cost it prevents. When a
rule changes, its entry here changes in the same pull request.

Each entry: the rule, why, and where it was learned.

## Work items

**GitHub issues are the only task list.** A second list — a TODO file, a
markdown backlog, a list in a branch — drifts from the first within days, and
then neither is trusted. *Origin: dnd-ai-dungeon-master, setup.*

**Ideas are captured as issues labelled `idea`, and refined separately.**
Observations made between sessions were gone by the retro. Capture in a file
beside the repository is invisible on the phone and to other sessions; a file
in a long-lived branch is a second task list and conflicts with everything.
An issue costs seconds and lives where the rest of the work does. *Origin:
dnd-ai-dungeon-master, after iteration 001.*

**An idea is never worked on as it is.** Without the definition of ready,
the inbox becomes a back door around refinement, and work starts on
acceptance criteria nobody wrote.

## Branches and gates

**Never commit to `main`, without threshold.** The original rule was
conditional — "once the first feature branch exists" — and never took effect,
because no branch was created; three commits went to `main` under it. A rule
with a precondition is a rule whose escape hatch has already been written.
*Origin: dnd-ai-dungeon-master, before the process.*

**A missing credential is a stronger gate than a rule.** The chat session
cannot push, so nothing reached GitHub without the maintainer acting. Where a
gate can be a mechanism — a credential, a hook, a ruleset — it should be.
*Origin: dnd-ai-dungeon-master, setup.*

**Never merge your own pull request.** The review is the only point at which
a second judgement enters a one-person project.

## Handover

**Manual ownership is not manual composition.** Keeping GitHub steps manual
was right; expecting the maintainer to also write the issue and pull request
bodies was not. "Create an issue" is an instruction, not a deliverable.
*Origin: dnd-ai-dungeon-master, setup.*

**Facts are set, judgements are not.** Size and iteration are facts about the
work and arrive set. Status is a judgement about whether the work is there
yet, and handing it over as a command would hand over the judgement with it.

**Board names are read at run time.** Two broken handover scripts reached the
maintainer with field names from memory. *Origin: dnd-ai-dungeon-master,
iteration 001.*

**Scripts that write to GitHub are run against a stand-in first.** A session
without credentials has otherwise never run the script at all. *Origin:
dnd-ai-dungeon-master, iteration 001.*

**Content beside the repository, tooling inside it.** Bodies inside the
repository would be a second task list. Tooling outside it drifts from the
rules it implements, cannot be tested in CI, and gets rewritten — with guessed
names — by the next session that does not find it. *Origin:
dnd-ai-dungeon-master, iteration 001.*

**Numbers are read, not predicted.** GitHub numbers issues and pull requests
in one sequence, which broke a branch-naming assumption twice. *Origin:
dnd-ai-dungeon-master, setup.*

## Decisions

**ADRs before the code.** Written afterwards, the options not taken are
already forgotten, and those are the record's value.

**Immutability has a scope.** "An accepted ADR is immutable" would have
forbidden redacting a personal name from a heading. What is protected is the
decision, its reasoning and its consequences. *Origin: dnd-ai-dungeon-master,
setup.*

## Iterations

**Scope is the box by default, and scope is cut rather than stretched.** In
spare-time work a time box only produces a recurring sense of having missed
it; but a scope box has nothing else that stops growth, so the cut order is
planned before it is needed. A project with real deadlines sets the box to
time. *Origin: dnd-ai-dungeon-master, iteration 001, which grew.*

**The retro reads evidence.** Memory finds what was annoying last week, not
what was costly.

**Learnings are marked `[project]` or `[generic]`.** Without the mark, a
project-specific lesson becomes a rule for every project, or a generic one
stays in one project's `CLAUDE.md` and is learned again elsewhere.

## Projects of several repositories

**One home repository for what belongs to the whole project.** Vision, ADRs,
iterations and epics in two places become two ledgers within a week. A
project of one repository is its own home, so the rule costs it nothing.
*Origin: compliance-traceability, a public and a private repository with a
third, private one created as home.*

**Members import the home `CLAUDE.md` instead of copying it.** A copy of the
parameters in every repository drifts; an import is one file. The price is
that the repositories must be checked out beside each other, and a session
without the home checkout is told to stop rather than work without the hard
rules.

**Nothing flows from private to public.** In a project with licensed or
confidential material, a leak is rarely a file: it is a sentence in a commit
message, an issue title, a pull request summary. The rule names those
channels because they are where it happens.

**A member's architecture stands on its own.** A reader of a public member
may never see the private home repository. A summary that only links to ADRs
there explains nothing to them.

## Facts scripts read

**The board is named in `.ai-dev-process.conf`, not found.** "The owner's
only board" stopped being true the day a second project got a board, and an
environment variable to set before every run is a rule that will be
forgotten. Data a script needs belongs in a file the script reads, committed
with the repository. *Origin: the second board, for compliance-traceability.*

**Existing labels are left as they are.** Creating labels with `--force`
silently recoloured a project's own labels. A setup step must not overwrite
what the project already decided; updating is an explicit option.
*Origin: dnd-ai-dungeon-master, adopting 0.1.0.*

## Distribution

**Rules are files in the project, not plugin content.** A plugin cannot carry
instructions that load in every session — only skills, which load when they
match. A rule that only exists in a skill holds only sometimes: the
conditional rule again. Files in the repository are also what a chat session
reads, and what a pull request reviews together with the scripts.

**Managed files are never edited in a project.** A local edit forks the
process silently; the next upgrade would either overwrite it or never happen.
The lock makes the fork visible, and the deviation section gives the project
a legitimate place to differ.

**Upgrades happen between iterations.** A rule that changes mid-iteration
changes the meaning of work already planned under the old one.
