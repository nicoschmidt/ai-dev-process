#!/usr/bin/env bash
# Finish the setup of a repository that setup-repository.sh prepared and whose
# project files are filled in: check, commit, push, open the pull request.
#
#   bash finish-setup.sh <repository directory>
#
# Run it in the project folder. It refuses while CLAUDE.md or
# .ai-dev-process.conf still holds a <…> placeholder. Safe to run again.

set -euo pipefail

die() { echo "finish: $*" >&2; exit 1; }

[ "$#" -eq 1 ] || die "usage: bash finish-setup.sh <repository directory>"
[ -d "$1/.git" ] || die "no repository in '$1'. Run this in the project folder."
command -v gh >/dev/null || die "gh is not installed."
cd "$1"

[ -f .ai-dev-process.lock ] || die "no .ai-dev-process.lock here; run setup-repository.sh first."
VERSION="$(sed -n 's/^version //p' .ai-dev-process.lock)"
BRANCH="$(git symbolic-ref --short -q HEAD || true)"
ISSUE="$(sed -n 's|^chore/\([0-9][0-9]*\)-ai-dev-process-.*|\1|p' <<<"$BRANCH")"
[ -n "$ISSUE" ] || die "on '$BRANCH', not on a branch chore/<issue>-ai-dev-process-<version>."

left="$(grep -nE '<[^!/<>][^<>]*>' CLAUDE.md .ai-dev-process.conf 2>/dev/null | grep -v '<https\?://' || true)"
if [ -n "$left" ]; then
  echo "finish: placeholders are left; nothing was committed:" >&2
  echo "$left" | sed 's/^/  /' >&2
  exit 1
fi
other="$(grep -rnE '^<[^!/<>][^<>]*>$|^- <[^<>]*>$' docs 2>/dev/null || true)"
if [ -n "$other" ]; then
  echo "note: docs/ still has open placeholders; fine if they are honest ones:"
  echo "$other" | sed 's/^/  /'
fi

bash scripts/process/check-kit.sh || die "check-kit.sh failed: a managed file differs from the release."

git add -A || die "git add failed."
if git diff --cached --quiet; then
  echo "exists   nothing new to commit"
else
  git commit -q -m "chore: adopt ai-dev-process $VERSION" \
    -m "Installs the kit at $VERSION and fills in the project's CLAUDE.md and .ai-dev-process.conf." \
    -m "Closes #$ISSUE" || die "git commit failed."
  echo "committed"
fi

git push -q -u origin "$BRANCH" || die "git push failed for $BRANCH."
echo "pushed   $BRANCH"

open="$(gh pr list --head "$BRANCH" --state open --json number --jq '.[].number')" \
  || die "gh pr list failed: could not check for an open pull request."
if [ -n "$open" ]; then
  echo "exists   pull request #$open"
else
  gh pr create --head "$BRANCH" --milestone "000 Setting up" \
    --title "chore: adopt ai-dev-process $VERSION" \
    --body "Installs ai-dev-process $VERSION and fills in the project files. No change in behaviour of the product.

Closes #$ISSUE" || die "gh pr create failed."
fi

echo
echo "Next: once CI has run, the repository settings in docs/adopting.md (ruleset, delete branch on merge)."
