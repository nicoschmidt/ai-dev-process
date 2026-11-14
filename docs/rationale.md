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

**Ideas are issues, never board drafts.** Five ideas from one evening were
noted as draft items on a board. Drafts carry no labels and are not issues,
so no session that reads issues saw them, and neither did the retro, until
the board was exported by hand. *Origin: dnd-ai-dungeon-master, iteration
001 (#4).*

**Ready is read from the issue: labels and milestone.** The `Ready` status on
a board was the click that got forgotten: two issues were refined and
planned, still in Backlog, and work started on them anyway (#14). And the
board is readable only through GraphQL with the `project` scope, which a chat
session and a cloud session do not have, so the session that should have
stopped could not see why. Labels and the milestone are readable by every
session that can read the repository, and assigning the milestone is a
deliberate act of the maintainer in refinement. *Origin: schulplaner,
iteration 001; spike #16.*

**Size is not recorded.** The maintainer did not use it to choose work. What
it guarded, that nothing too large enters an iteration, is item 3 of the
definition of ready, a judgement made in refinement. *Origin: spike #16.*

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

**Facts arrive set, and the judgement is made where it can be seen.** The
label and the milestone arrive set in the block that creates the issue, so
the maintainer composes nothing. Whether an issue is ready is a judgement;
it used to be a status click kept apart from every command, so that a
handover would not make it for the maintainer. It is now the milestone,
assigned in a refinement command the maintainer reads before running it:
still the maintainer's act, and visible to every session afterwards.
*Origin: spike #16.*

**Names are read at run time.** Two broken handover scripts reached the
maintainer with board field names from memory. The same holds for milestone
titles and labels. *Origin: dnd-ai-dungeon-master, iteration 001.*

**Scripts that write to GitHub are run against a stand-in first.** A session
without credentials has otherwise never run the script at all. *Origin:
dnd-ai-dungeon-master, iteration 001.*

**Content beside the repository, tooling inside it.** Bodies inside the
repository would be a second task list. Tooling outside it drifts from the
rules it implements, cannot be tested in CI, and gets rewritten — with guessed
names — by the next session that does not find it. *Origin:
dnd-ai-dungeon-master, iteration 001.*

**Every project has a folder, and nothing names an absolute path.** A
checkout moved a day after setup, and the claude.ai instructions and the
handover files still named the old path. The documented `~/coding/<repository>`
matched none of the maintainer's projects, which each live in a folder of
their own with the repositories inside; and where that folder lives is one
developer's habit, not a fact of the project. Commands relative to the
project folder, and scripts that find it from their own location, are true on
every machine. The project folder is also where content beside the repository
belongs, instead of loose between other projects. *Origin: schulplaner,
setup.*

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

**An iteration is a milestone.** It used to be an option in a board field,
an epic issue and a planning file, three places to keep in step, and the
first of them invisible to most sessions. A milestone holds the goal in its
description and the scope as its issues, readable by every session over
REST; the file is left with what only a file can hold, the retro. *Origin:
spike #16.*

**Scope is the box by default, and iterations are cut small.** In spare-time
work a time box only produces a recurring sense of having missed it. A scope
box has nothing else that stops growth; the first answer was a cut order
planned ahead, but iterations stayed large and felt rigid, and the
maintainer wanted to bring in what mattered more without the plan blocking
it. Small iterations make growth cheap to see, and an iteration that ends
when its goal is met, moving what is open, needs no cut order. A project
with real deadlines sets the box to time. *Origin: dnd-ai-dungeon-master,
iteration 001, which grew; spike #16.*

**Scope may be added at any time, but never invisibly.** Requirements were
added to running iterations several times, in two projects: once by hand in
three places, twice inside open pull requests where neither the issue nor
the iteration showed them. The retro found them only because commit messages
said so. Adding is allowed because priorities really change; the issue in the
milestone before the work is what keeps it visible. *Origin:
dnd-ai-dungeon-master, iteration 001a; schulplaner, iteration 001 (#9).*

**When the goal is met, the iteration ends.** A goal was reached at the table
several times while the iteration stayed open, because everyone looked at
its open issues rather than its done criterion. A point in `discipline.md`
makes the check happen; an empty milestone is the other signal. *Origin:
dnd-ai-dungeon-master, iteration 001 (#7).*

**An MVP is a state, not an iteration.** A large iteration that is the MVP
grows and blocks everything behind it. Named in the vision, the MVP stays the
aim while small iterations reach it. *Origin: spike #16.*

**The retro reads evidence.** Memory finds what was annoying last week, not
what was costly.

**Learnings are marked `[project]` or `[generic]`.** Without the mark, a
project-specific lesson becomes a rule for every project, or a generic one
stays in one project's `CLAUDE.md` and is learned again elsewhere.

## Projects of several repositories

**One home repository for what belongs to the whole project.** Vision, ADRs
and iterations in two places become two ledgers within a week. A
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

**Data a script needs is in a file the script reads.** When projects still
had boards, "the owner's only board" stopped being true the day a second
project got one, and an environment variable to set before every run is a
rule that will be forgotten. So `.ai-dev-process.conf`, committed with the
repository, names the project's repositories. *Origin: the second board, for
compliance-traceability.*

**What a session needs lives in issues and milestones.** A gate holds only if
the session that should stop can see it. Issues, pull requests and milestones
are readable over REST by every session that can read the repository; a
board needs GraphQL and the `project` scope, which only a session on the
maintainer's machine has. *Origin: spike #16.*

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
