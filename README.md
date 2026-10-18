# ai-dev-process

A way of working for one maintainer building software with AI assistants:
the maintainer defines vision, scope and issues in dialogue with Claude in
chat, Claude Code implements on branches, and the maintainer reviews and
merges on GitHub. It grew out of
[dnd-ai-dungeon-master](https://github.com/nicoschmidt/dnd-ai-dungeon-master)
and is meant to be reused, and improved, across projects.

## Three layers

| Layer | What it holds | Where it lives in a project | How it gets there |
| --- | --- | --- | --- |
| **Rules** — must hold in every session | workflow, handover, ADRs, iterations, discipline, done | `.claude/rules/process/*.md`, loaded by Claude Code automatically | copied by `install.sh`, pinned in `.ai-dev-process.lock` |
| **Procedures** — needed at a moment | capture an idea, refinement, handover, ADR, plan, retro, upstream, adopt | the `ai-dev-process` plugin's skills, in chat, Cowork and Claude Code | installed once per claude.ai account |
| **Mechanisms** — hold when a sentence is forgotten | pre-commit hook on `main`, managed-file check in CI, `CI passed` gate, ruleset | `.githooks/`, `scripts/process/`, `.github/` | copied by `install.sh`; ruleset by hand |

And what is particular to a project — what it is, its hard rules, its
process parameters and deviations — lives in that project's `CLAUDE.md`,
which this repository only provides a starting template for.

## This repository

```
kit/                      copied into every project on every install; managed, never edited there
  .claude/rules/process/  the binding rules
  .githooks/pre-commit    refuses commits on main
  .github/ISSUE_TEMPLATE/ idea, feature, bug, spike
  scripts/process/        board helpers, idea capture, labels, managed-file check, their tests
  docs/                   process walkthrough, ADR and iteration templates
templates/                copied once, where the project has no such file; project-owned afterwards
  CLAUDE.md               with Process parameters and Process deviations
  .github/                pull request template, CI with the `CI passed` gate
  docs/                   vision, architecture, ADR index and ADR-0001, iterations
plugins/ai-dev-process/   the plugin: one skill per procedure
.claude-plugin/           the marketplace that lists the plugin
install.sh                install or upgrade a project
docs/                     adopting, maintaining, rationale, claude.ai project instructions
tests/                    installer and plugin structure tests
```

## Use it

- **Install the plugin** once: claude.ai → *Customize → Plugins → Add → Add
  marketplace* → `nicoschmidt/ai-dev-process`, then add **ai-dev-process** and
  turn on *Sync automatically*. It reaches Claude Code through the account.
  In Claude Code alone:
  `/plugin install ai-dev-process --marketplace nicoschmidt/ai-dev-process`
- **Adopt it in a project:** [docs/adopting.md](docs/adopting.md), or ask in a
  session: `/ai-dev-process:adopt-process`.
- **Capture an idea** anywhere: New issue → *Idea*, or
  `/ai-dev-process:capture-idea`.

## Improve it

Learnings arrive from the projects' retros as issues here, labelled
`from:<project>`. They change the process through pull requests, a
`CHANGELOG.md` entry with the reason, and a release; projects upgrade between
iterations. See [docs/maintaining.md](docs/maintaining.md), and
[docs/rationale.md](docs/rationale.md) for why each rule exists.

## License

[MIT](LICENSE)
