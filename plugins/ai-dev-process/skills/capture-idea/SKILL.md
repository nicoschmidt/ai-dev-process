---
name: capture-idea
description: Capture an idea, wish or process observation as a GitHub issue labelled idea, in seconds and without refining it. Use when the maintainer says "Idee:", "capture", "notier dir", "remind me", or mentions in passing something to change later.
---

# Capture an idea

Capture is cheap on purpose. An idea noticed in passing is worth seconds now
and is gone by the next session. Refinement is a separate step
(`refine-backlog`); do not start it here.

## Steps

1. **Pick the repository.** The project the session is about. Use the
   process repository named in `CLAUDE.md` (default
   `nicoschmidt/ai-dev-process`) only when the maintainer says the idea is
   about the process in general. When unsure, stay in the project and add
   `process`: the retro decides later.
2. **Label.** Always `idea`. Add `process` when it is about the way of working
   — rules, handover, sessions, reviews, tooling — rather than the product.
3. **Title.** One line, at most ~70 characters, in the repository language
   (usually English, even when dictated in German). A noun phrase or an
   imperative: "Retro reads review comments of merged PRs".
4. **Details.** One to three lines, only from what the maintainer said. Do not
   invent acceptance criteria, size, or a solution they did not mention.
5. **Create or hand over**, depending on the environment:
   - **Claude Code, or any session with an authenticated `gh`:** create it
     directly. A dictated idea is the one GitHub step an assistant may take
     itself (`.claude/rules/process/workflow.md`).

     ```bash
     bash scripts/process/capture-idea.sh --process "<title>" "<details>"
     ```

     Without `--process` for product ideas. Where the script is missing (the
     project has not adopted the kit yet):
     `gh issue create --repo <owner>/<repo> --label idea --title "<title>" --body "<details>"`
   - **Chat without credentials:** give one prefilled link that opens the Idea
     form; the maintainer taps **Create**. URL-encode every value (spaces as
     `%20`, `#` as `%23`, line breaks as `%0A`):

     ```
     https://github.com/<owner>/<repo>/issues/new?template=idea.yml&labels=idea,process&title=<title>&details=<details>
     ```

     `details` is the id of the form's text field. Add the terminal command
     from above as the alternative.
6. **Confirm in one line**: the title, the labels, the link. Then return to
   what the session was doing.

## Do not

- discuss whether the idea is good — that is refinement's job
- capture several ideas as one issue; one idea, one issue
- put the idea in a file, a branch or a TODO list, ever
