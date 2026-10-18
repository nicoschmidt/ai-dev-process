# Maintaining ai-dev-process

How the process changes. It follows its own rules: issues, branches, pull
requests, reviews — see `CLAUDE.md`.

## Where a learning comes from

- a project's retro, marked `[generic]`, arriving as an issue with the label
  `from:<project>` (skill `upstream-learning`)
- an idea captured here directly, labelled `idea` and `process`
- a deviation in a project's `CLAUDE.md` that turns out to be wanted
  everywhere — or a second project needing the same deviation

A learning seen in one project is a hypothesis. Prefer to wait for the second
project before turning a project's habit into a rule for all of them, unless
the cost of not having it is already clear.

## Where a change goes

| It is… | It goes to | Because |
| --- | --- | --- |
| something that must hold in every session | `kit/.claude/rules/process/` | rules load always; skills only when they match |
| a sequence of steps for one moment | a skill in `plugins/ai-dev-process/skills/` | it costs context only when used |
| something a sentence keeps failing to hold | a mechanism: a script, check, hook or template under `kit/` | mechanisms hold when sessions forget |
| different per project | a parameter in `templates/CLAUDE.md`, referenced by the rule | the rule stays true everywhere |
| a starting point the project will own | `templates/` | copied once, never overwritten |

A skill never contradicts a rule. It may say *how*; the rule says *what*.

## A change, step by step

1. Issue, branch, as everywhere.
2. The change, with its reason — in the rule's own text or in
   `docs/rationale.md`.
3. `CHANGELOG.md` under `Unreleased`: what, why, origin.
4. `bash tests/run.sh`.
5. Pull request, review, merge.

## A release

When `Unreleased` holds something a project should have:

1. Decide the version by the rules at the top of `CHANGELOG.md`.
2. On a branch `chore/<issue>-release-<version>`: set `VERSION` and
   `plugins/ai-dev-process/.claude-plugin/plugin.json` to it (a test checks
   that both agree), and rename `Unreleased` to `<version> — <date>`.
3. After the merge, tag it on `main`:

   ```bash
   git switch main && git pull
   git tag -a v<version> -m "ai-dev-process <version>"
   git push origin v<version>
   ```

4. The plugin updates itself on accounts with *Sync automatically*; in
   claude.ai otherwise *Customize → Plugins → ai-dev-process → Check for
   updates*. The rules reach each project only by its own upgrade pull
   request, between iterations.

The plugin and the kit are released together, so a skill always matches the
rules of the same version. A project that has not upgraded yet may run a newer
skill against older rules; where they disagree, the rules in the project win.
