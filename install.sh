#!/usr/bin/env bash
# Install or upgrade ai-dev-process in a project repository.
#
#   bash install.sh <path to the project>
#
# Run it from a checkout of this repository at the version you want, normally
# a release tag:
#
#   git -C ~/coding/ai-dev-process switch --detach v0.1.0
#   bash ~/coding/ai-dev-process/install.sh ~/coding/my-project
#
# What it does, in the project:
#
#   kit/        copied over every time. These files are managed: the project
#               never edits them, and .ai-dev-process.lock records their
#               checksums so CI notices when it does.
#   templates/  copied only where the project has no such file yet. After
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

[ "$#" -eq 1 ] || die "usage: bash install.sh <path to the project>"
[ -d "$1" ] || die "no such directory: $1"
TARGET="$(cd "$1" && pwd -P)"

# --- the source -------------------------------------------------------------

[ -f "$SRC/VERSION" ] || die "no VERSION in $SRC — run this from a checkout of ai-dev-process"
VERSION="$(tr -d '[:space:]' < "$SRC/VERSION")"
git -C "$SRC" rev-parse --git-dir >/dev/null 2>&1 \
  || die "$SRC is not a git checkout; the kit is read from tracked files only"

# Tracked files only: a stray .DS_Store or an editor backup is never installed.
KIT_FILES="$(git -C "$SRC" ls-files kit | sed 's|^kit/||' | sort)"
TEMPLATE_FILES="$(git -C "$SRC" ls-files templates | sed 's|^templates/||' | sort)"
[ -n "$KIT_FILES" ] || die "no tracked files under kit/ in $SRC"

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
OLD_FILES=""
if [ -f "$LOCK" ]; then
  OLD_VERSION="$(sed -n 's/^version //p' "$LOCK")"
  edited=""
  while read -r expected path; do
    case "$expected" in ''|'#'*|version|source) continue ;; esac
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

# --- install ----------------------------------------------------------------

echo "ai-dev-process ${OLD_VERSION:+$OLD_VERSION → }$VERSION into $TARGET"
echo

lock_tmp="$(mktemp)"
{
  echo "# Managed by ai-dev-process. Written by install.sh; do not edit."
  echo "# Every file below is changed upstream, never in this repository."
  echo "version $VERSION"
  echo "source $REPO_URL"
} > "$lock_tmp"

while IFS= read -r f; do
  [ -n "$f" ] || continue
  mkdir -p "$TARGET/$(dirname "$f")"
  if [ -f "$TARGET/$f" ] && cmp -s "$SRC/kit/$f" "$TARGET/$f"; then
    state="same    "
  elif [ -f "$TARGET/$f" ]; then
    state="updated "
  else
    state="added   "
  fi
  cp -p "$SRC/kit/$f" "$TARGET/$f"
  echo "  $state $f"
  echo "$(sha "$TARGET/$f") $f" >> "$lock_tmp"
done <<< "$KIT_FILES"

# Files the previous version managed and this one no longer ships. They were
# checked unchanged above, so removing them loses nothing of the project's.
while IFS= read -r f; do
  [ -n "$f" ] || continue
  if ! grep -qxF "$f" <<< "$KIT_FILES" && [ -f "$TARGET/$f" ]; then
    rm "$TARGET/$f"
    echo "  removed  $f"
  fi
done <<< "$OLD_FILES"

while IFS= read -r f; do
  [ -n "$f" ] || continue
  if [ -e "$TARGET/$f" ]; then
    echo "  kept     $f  (project-owned)"
  else
    mkdir -p "$TARGET/$(dirname "$f")"
    cp -p "$SRC/templates/$f" "$TARGET/$f"
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
  echo "Then fill in the placeholders in CLAUDE.md and docs/ (look for '<')."
fi
