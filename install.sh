#!/usr/bin/env bash
# Install or upgrade ai-dev-process in a project repository.
#
#   bash install.sh [--role single|home|member] <path to the repository>
#
# Run it from a checkout of this repository at the version you want, normally
# a release tag:
#
#   git -C ~/coding/ai-dev-process switch --detach v0.2.0
#   bash ~/coding/ai-dev-process/install.sh ~/coding/my-project
#
# The role says what the repository is within its project
# (.claude/rules/process/repositories.md):
#
#   single   the whole project is this one repository (the default)
#   home     the project's home: vision, ADRs, iterations, epics
#   member   another repository of the same project: code or data
#
# On an upgrade the role is read from .ai-dev-process.lock; --role changes it.
#
# What it does, in the repository:
#
#   kit/common/, and kit/home/ for single and home
#               copied over every time. These files are managed: the project
#               never edits them, and .ai-dev-process.lock records their
#               checksums so CI notices when it does.
#   templates/all/, and templates/home/ or templates/member/
#               copied only where the repository has no such file yet. After
#               that they belong to the project.
#
# It refuses, and changes nothing, when the project is on main, has
# uncommitted changes, or has edited a managed file since the last install.
# It never commits: the result is reviewed as a pull request like any change.

set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd -P)"
LOCK_NAME=".ai-dev-process.lock"
REPO_URL="https://github.com/nicoschmidt/ai-dev-process"

die() { echo "install: $*" >&2; exit 1; }

sha() {
  if command -v sha256sum >/dev/null; then
    sha256sum "$1" | cut -d' ' -f1
  else
    shasum -a 256 "$1" | cut -d' ' -f1
  fi
}

USAGE="usage: bash install.sh [--role single|home|member] <path to the repository>"
ROLE_ARG=""
if [ "${1:-}" = "--role" ]; then
  [ "$#" -ge 2 ] || die "$USAGE"
  ROLE_ARG="$2"
  shift 2
fi
[ "$#" -eq 1 ] || die "$USAGE"
case "$ROLE_ARG" in ''|single|home|member) ;; *) die "unknown role '$ROLE_ARG'. $USAGE" ;; esac
[ -d "$1" ] || die "no such directory: $1"
TARGET="$(cd "$1" && pwd -P)"

# --- the source -------------------------------------------------------------

[ -f "$SRC/VERSION" ] || die "no VERSION in $SRC — run this from a checkout of ai-dev-process"
VERSION="$(tr -d '[:space:]' < "$SRC/VERSION")"
git -C "$SRC" rev-parse --git-dir >/dev/null 2>&1 \
  || die "$SRC is not a git checkout; the kit is read from tracked files only"

[ -n "$(git -C "$SRC" ls-files kit/common)" ] || die "no tracked files under kit/common/ in $SRC"

if [ -n "$(git -C "$SRC" status --porcelain -- kit templates VERSION)" ]; then
  echo "warning: ai-dev-process has uncommitted changes under kit/ or templates/;"
  echo "         installing them anyway, from the working tree"
fi
if ! git -C "$SRC" tag --points-at HEAD 2>/dev/null | grep -qx "v$VERSION"; then
  echo "warning: this checkout is not at the tag v$VERSION;"
  echo "         the lock will name $VERSION, but the files may differ from that release"
fi

# --- the target -------------------------------------------------------------

git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1 || die "$TARGET is not a git repository"
[ "$(git -C "$TARGET" rev-parse --show-toplevel)" = "$TARGET" ] \
  || die "$TARGET is not the top of its repository"

branch="$(git -C "$TARGET" symbolic-ref --short -q HEAD || true)"
case "$branch" in
  main|master|"")
    die "the project is on '${branch:-a detached HEAD}'. Install on a branch:
  git -C \"$TARGET\" switch -c chore/<issue>-ai-dev-process-$VERSION" ;;
esac

[ -z "$(git -C "$TARGET" status --porcelain)" ] \
  || die "the project has uncommitted changes. Commit or stash them first, so this install is its own diff."

LOCK="$TARGET/$LOCK_NAME"
OLD_VERSION=""
OLD_ROLE=""
OLD_FILES=""
if [ -f "$LOCK" ]; then
  OLD_VERSION="$(sed -n 's/^version //p' "$LOCK")"
  OLD_ROLE="$(sed -n 's/^role //p' "$LOCK")"
  edited=""
  while read -r expected path; do
    case "$expected" in ''|'#'*|version|source|role) continue ;; esac
    OLD_FILES="$OLD_FILES$path
"
    if [ -f "$TARGET/$path" ] && [ "$(sha "$TARGET/$path")" != "$expected" ]; then
      edited="$edited  $path
"
    fi
  done < "$LOCK"
  if [ -n "$edited" ]; then
    die "these managed files were edited in the project since $OLD_VERSION was installed:
$edited
Move each change upstream or into CLAUDE.md as a deviation, restore the file, then re-run."
  fi
fi

# --- what this role receives -------------------------------------------------

# A lock from before 0.2.0 names no role; those projects were single.
ROLE="${ROLE_ARG:-${OLD_ROLE:-single}}"
case "$ROLE" in
  member) KIT_DIRS="common";      TEMPLATE_DIRS="all member" ;;
  *)      KIT_DIRS="common home"; TEMPLATE_DIRS="all home" ;;
esac

# Lines of "<source path>|<path in the repository>". Tracked files only: a
# stray .DS_Store or an editor backup is never installed.
files_of() {           # files_of <kit|templates> <subdirectories>
  local base="$1" d
  for d in $2; do
    git -C "$SRC" ls-files "$base/$d" | while IFS= read -r p; do
      printf '%s|%s\n' "$p" "${p#"$base/$d/"}"
    done
  done | sort -t'|' -k2
}
KIT_FILES="$(files_of kit "$KIT_DIRS")"
TEMPLATE_FILES="$(files_of templates "$TEMPLATE_DIRS")"
KIT_PATHS="$(cut -d'|' -f2 <<< "$KIT_FILES")"

dupes="$(printf '%s\n%s\n' "$KIT_PATHS" "$(cut -d'|' -f2 <<< "$TEMPLATE_FILES")" | sort | uniq -d)"
[ -z "$dupes" ] || die "ai-dev-process ships these paths twice for role $ROLE — a defect upstream:
$dupes"

# --- install ----------------------------------------------------------------

echo "ai-dev-process ${OLD_VERSION:+$OLD_VERSION → }$VERSION into $TARGET"
if [ -n "$OLD_ROLE" ] && [ "$OLD_ROLE" != "$ROLE" ]; then
  echo "role: $OLD_ROLE → $ROLE"
else
  echo "role: $ROLE"
fi
echo

lock_tmp="$(mktemp)"
{
  echo "# Managed by ai-dev-process. Written by install.sh; do not edit."
  echo "# Every file below is changed upstream, never in this repository."
  echo "version $VERSION"
  echo "source $REPO_URL"
  echo "role $ROLE"
} > "$lock_tmp"

while IFS='|' read -r src f; do
  [ -n "$f" ] || continue
  mkdir -p "$TARGET/$(dirname "$f")"
  if [ -f "$TARGET/$f" ] && cmp -s "$SRC/$src" "$TARGET/$f"; then
    state="same    "
  elif [ -f "$TARGET/$f" ]; then
    state="updated "
  else
    state="added   "
  fi
  cp -p "$SRC/$src" "$TARGET/$f"
  echo "  $state $f"
  echo "$(sha "$TARGET/$f") $f" >> "$lock_tmp"
done <<< "$KIT_FILES"

# Files the previous version managed and this one no longer ships. They were
# checked unchanged above, so removing them loses nothing of the project's.
while IFS= read -r f; do
  [ -n "$f" ] || continue
  if ! grep -qxF "$f" <<< "$KIT_PATHS" && [ -f "$TARGET/$f" ]; then
    rm "$TARGET/$f"
    echo "  removed  $f"
  fi
done <<< "$OLD_FILES"

while IFS='|' read -r src f; do
  [ -n "$f" ] || continue
  if [ -e "$TARGET/$f" ]; then
    echo "  kept     $f  (project-owned)"
  else
    mkdir -p "$TARGET/$(dirname "$f")"
    cp -p "$SRC/$src" "$TARGET/$f"
    echo "  created  $f  (from template; project-owned from now on)"
  fi
done <<< "$TEMPLATE_FILES"

mv "$lock_tmp" "$LOCK"
echo "  wrote    $LOCK_NAME"

# Local configuration, not a file: git does not read hook settings from the
# repository. Every clone needs this once; it is repeated in CLAUDE.md.
git -C "$TARGET" config core.hooksPath .githooks
echo "  set      git config core.hooksPath .githooks"

echo
echo "Next, in the project:"
echo "  bash scripts/process/check-kit.sh"
echo "  git add -A && git status"
if [ -n "$OLD_VERSION" ]; then
  echo "  git commit -m \"chore: ai-dev-process $OLD_VERSION → $VERSION\""
  echo "Read CHANGELOG.md in ai-dev-process for what changed between the two."
else
  echo "  git commit -m \"chore: adopt ai-dev-process $VERSION\""
  echo "Then fill in the placeholders in CLAUDE.md, .ai-dev-process.conf and docs/ (look for '<')."
fi
if [ "$ROLE" = "member" ]; then
  echo "This is a member repository: its CLAUDE.md imports the home repository's"
  echo "CLAUDE.md from the checkout beside it. Name that directory there."
fi
