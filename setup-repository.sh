#!/usr/bin/env bash
# Set up one repository of a project for ai-dev-process, up to the point
# where the project files are filled in. docs/adopting.md explains each step.
#
#   bash setup-repository.sh [--role single|home|member] [--create public|private] <owner>/<repo>
#
# Run it in the project folder, from a fresh clone of the release:
#
#   AIDP="$(mktemp -d)" && git -c advice.detachedHead=false clone -q --depth 1 \
#     --branch v0.4.0 https://github.com/nicoschmidt/ai-dev-process "$AIDP"
#   bash "$AIDP/setup-repository.sh" --create public my-name/my-project
#
# What it does, each step only where it is not done yet:
#
#   1. the repository, cloned into the project folder under its name;
#      created on GitHub first only with --create
#   2. the labels the issue forms need (existing ones are left alone)
#   3. the milestone "000 Setting up"
#   4. the adoption issue in that milestone
#   5. the branch chore/<issue>-ai-dev-process-<version>, with the number
#      read from GitHub
#   6. the install, with the role
#
# It stops before anything is committed. Fill in the project files, then run
# finish-setup.sh. A run that failed halfway is simply run again.

set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd -P)"
MILESTONE="000 Setting up"
MILESTONE_GOAL="The process runs end to end, and the first iteration can be planned."

die() { echo "setup: $*" >&2; exit 1; }
step() { echo; echo "== $*"; }

USAGE="usage: bash setup-repository.sh [--role single|home|member] [--create public|private] <owner>/<repo>"
ROLE="single"
CREATE=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --role)   [ "$#" -ge 2 ] || die "$USAGE"; ROLE="$2"; shift 2 ;;
    --create) [ "$#" -ge 2 ] || die "$USAGE"; CREATE="$2"; shift 2 ;;
    -*)       die "unknown option '$1'. $USAGE" ;;
    *)        break ;;
  esac
done
[ "$#" -eq 1 ] || die "$USAGE"
case "$ROLE" in single|home|member) ;; *) die "unknown role '$ROLE'. $USAGE" ;; esac
case "$CREATE" in ''|public|private) ;; *) die "--create takes public or private. $USAGE" ;; esac
FULL="$1"
case "$FULL" in */*/*|/*|*/|*' '*) die "'$FULL' is not <owner>/<repo>. $USAGE" ;; */*) ;; *) die "'$FULL' is not <owner>/<repo>. $USAGE" ;; esac
NAME="${FULL##*/}"

command -v gh >/dev/null || die "gh is not installed."
command -v jq >/dev/null || die "jq is not installed: brew install jq"
[ -f "$SRC/VERSION" ] || die "no VERSION beside this script; run it from a clone of ai-dev-process"
VERSION="$(tr -d '[:space:]' < "$SRC/VERSION")"
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  die "this directory is inside a git repository. Run this in the project folder, which holds the repositories."
fi

step "1. The repository $FULL, in $(basename "$PWD")/$NAME"
if [ -d "$NAME/.git" ]; then
  echo "exists   $NAME"
elif [ -e "$NAME" ]; then
  die "$NAME exists here and is not a git repository."
elif gh repo view "$FULL" --json name >/dev/null 2>&1; then
  gh repo clone "$FULL" "$NAME" || die "gh repo clone failed for $FULL."
  echo "cloned   $FULL"
elif [ -n "$CREATE" ]; then
  gh repo create "$FULL" "--$CREATE" --add-readme --clone || die "gh repo create failed for $FULL."
  [ -d "$NAME/.git" ] || die "gh repo create did not leave a clone in $NAME."
  echo "created  $FULL ($CREATE)"
else
  die "GitHub shows no repository $FULL (gh repo view failed). To create it, add --create public or --create private."
fi
git -C "$NAME" rev-parse -q --verify HEAD >/dev/null \
  || die "$NAME has no commit yet. Its default branch needs a first commit, for instance a README."

export GH_REPO="$FULL"

step "2. Labels"
bash "$SRC/kit/common/scripts/process/setup-labels.sh" || die "setup-labels.sh failed for $FULL."

step "3. Milestone '$MILESTONE'"
# shellcheck source=kit/common/scripts/process/gh-issues.sh
source "$SRC/kit/common/scripts/process/gh-issues.sh"
ensure_milestone "$MILESTONE" "$MILESTONE_GOAL" "$FULL" || exit 1

step "4. The adoption issue"
create_issue "type:chore" "$MILESTONE" "chore: adopt ai-dev-process v$VERSION" <<BODY || exit 1
Install the kit of ai-dev-process v$VERSION with the role \`$ROLE\`, fill in
\`CLAUDE.md\` and \`.ai-dev-process.conf\`, and set up the ruleset for \`main\`.

Acceptance criteria:

- \`.ai-dev-process.lock\` names $VERSION and the role \`$ROLE\`.
- No \`<…>\` placeholder is left in \`CLAUDE.md\` or \`.ai-dev-process.conf\`.
- \`bash scripts/process/check-kit.sh\` passes, and CI passes on the pull request.

Needs: none.
BODY
ISSUE="$LAST_ISSUE_NUMBER"
BRANCH="chore/$ISSUE-ai-dev-process-$VERSION"

step "5. The branch $BRANCH"
current="$(git -C "$NAME" symbolic-ref --short -q HEAD || true)"
if [ "$current" = "$BRANCH" ]; then
  echo "exists   on $BRANCH"
elif git -C "$NAME" rev-parse -q --verify "refs/heads/$BRANCH" >/dev/null; then
  git -C "$NAME" switch -q "$BRANCH" || die "git switch failed for $BRANCH."
  echo "exists   switched to $BRANCH"
else
  [ -z "$(git -C "$NAME" status --porcelain)" ] \
    || die "$NAME has uncommitted changes on '$current'. Commit or stash them, then run this again."
  git -C "$NAME" switch -q -c "$BRANCH" || die "git switch -c failed for $BRANCH."
  echo "created  $BRANCH"
fi

step "6. Install ai-dev-process $VERSION, role $ROLE"
LOCK="$NAME/.ai-dev-process.lock"
if [ -f "$LOCK" ] && [ "$(sed -n 's/^version //p' "$LOCK")" = "$VERSION" ]; then
  echo "exists   $VERSION is installed (role $(sed -n 's/^role //p' "$LOCK"))"
else
  bash "$SRC/install.sh" --role "$ROLE" "$NAME" >/dev/null || die "install.sh failed for $NAME."
  echo "installed"
fi

echo
echo "Stopped before any commit. Still to fill in, in $NAME:"
left="$(cd "$NAME" && grep -nE '<[^!/<>][^<>]*>' CLAUDE.md .ai-dev-process.conf 2>/dev/null | grep -v '<https\?://' || true)"
if [ -n "$left" ]; then
  echo "$left" | sed 's/^/  /'
else
  echo "  nothing: CLAUDE.md and .ai-dev-process.conf hold no placeholder"
fi
echo "and docs/ (vision, architecture), best in a session that asks instead of guessing."
echo
echo "Then, in the project folder:"
echo "  bash \"\$AIDP/finish-setup.sh\" $NAME"
