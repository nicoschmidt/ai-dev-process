#!/usr/bin/env bash
# Exercise install.sh, check-kit.sh and the pre-commit hook against throwaway
# project repositories. Writes nothing outside a temporary directory.
#
#   bash tests/test-install.sh
#
# The kit is read from tracked files, so new files under kit/ or templates/
# must be `git add`ed before this test sees them.

set -uo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
FAILURES=0
VERSION="$(tr -d '[:space:]' < "$SRC/VERSION")"

check() {              # check <description> <expected> <actual>
  if [ "$2" = "$3" ]; then
    echo "  ok    $1"
  else
    echo "  FAIL  $1"
    echo "        expected: $2"
    echo "        actual:   $3"
    FAILURES=$((FAILURES + 1))
  fi
}

project() {            # project <name> -> a repository with one commit on main
  local dir="$WORK/$1"
  git init -q -b main "$dir"
  git -C "$dir" config user.email test@example.com
  git -C "$dir" config user.name Test
  echo "# $1" > "$dir/README.md"
  git -C "$dir" add README.md
  git -C "$dir" commit -q -m "chore: initial"
  echo "$dir"
}

commit_all() {         # commit_all <dir> <message>
  git -C "$1" add -A
  git -C "$1" commit -q -m "$2"
}

sha() {
  if command -v sha256sum >/dev/null; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

kit_count="$(git -C "$SRC" ls-files kit | wc -l | tr -d ' ')"

echo "refuses on main"
p="$(project on-main)"
out="$(bash "$SRC/install.sh" "$p" 2>&1)"; code=$?
check "fails" "1" "$code"
check "says so" "1" "$(grep -c "is on 'main'" <<<"$out")"
check "writes nothing" "" "$(git -C "$p" status --porcelain)"

echo "refuses with uncommitted changes"
p="$(project dirty)"
git -C "$p" switch -q -c chore/1-adopt
echo change >> "$p/README.md"
out="$(bash "$SRC/install.sh" "$p" 2>&1)"; code=$?
check "fails" "1" "$code"
check "no lock written" "no" "$([ -f "$p/.ai-dev-process.lock" ] && echo yes || echo no)"

echo "a fresh install"
p="$(project fresh)"
git -C "$p" switch -q -c chore/1-adopt
out="$(bash "$SRC/install.sh" "$p" 2>&1)"; code=$?
check "succeeds" "0" "$code"
check "lock names the version" "version $VERSION" "$(grep '^version ' "$p/.ai-dev-process.lock")"
check "lock lists every kit file" "$kit_count" "$(grep -cE '^[0-9a-f]{64} ' "$p/.ai-dev-process.lock")"
check "rules are in place" "yes" "$([ -f "$p/.claude/rules/process/workflow.md" ] && echo yes || echo no)"
check "CLAUDE.md from the template" "yes" "$(grep -q 'Process parameters' "$p/CLAUDE.md" && echo yes || echo no)"
check "hooks path is set" ".githooks" "$(git -C "$p" config core.hooksPath)"
check "scripts stay executable" "yes" "$([ -x "$p/scripts/process/check-kit.sh" ] && echo yes || echo no)"
out="$(bash "$p/scripts/process/check-kit.sh" 2>&1)"; code=$?
check "check-kit passes" "0" "$code"
commit_all "$p" "chore: adopt ai-dev-process"

echo "the pre-commit hook"
# As after the adoption's pull request is merged: main has .githooks too.
git -C "$p" switch -q main
git -C "$p" merge -q --ff-only chore/1-adopt
echo x >> "$p/README.md"
git -C "$p" add README.md
out="$(git -C "$p" commit -m "fix: straight to main" 2>&1)"; code=$?
check "refuses a commit on main" "1" "$code"
check "names the way out" "1" "$(grep -c 'git switch -c' <<<"$out")"
git -C "$p" checkout -q -- . 2>/dev/null; git -C "$p" reset -q --hard
git -C "$p" switch -q chore/1-adopt
echo y >> "$p/README.md"
out="$(git -C "$p" commit -q -am "docs: on a branch" 2>&1)"; code=$?
check "allows a commit on a branch" "0" "$code"

echo "a managed file edited in the project"
echo "local tweak" >> "$p/.claude/rules/process/workflow.md"
out="$(bash "$p/scripts/process/check-kit.sh" 2>&1)"; code=$?
check "check-kit fails" "1" "$code"
check "check-kit names the file" "changed  .claude/rules/process/workflow.md" "$(grep '^changed' <<<"$out")"
commit_all "$p" "docs: tweak a managed file"
out="$(bash "$SRC/install.sh" "$p" 2>&1)"; code=$?
check "install refuses" "1" "$code"
check "install names the file" "1" "$(grep -c '  .claude/rules/process/workflow.md' <<<"$out")"
check "install leaves the tweak" "1" "$(grep -c 'local tweak' "$p/.claude/rules/process/workflow.md")"
git -C "$p" revert --no-edit HEAD >/dev/null

echo "an upgrade keeps project-owned files"
echo "project text" >> "$p/CLAUDE.md"
commit_all "$p" "docs: fill in CLAUDE.md"
out="$(bash "$SRC/install.sh" "$p" 2>&1)"; code=$?
check "succeeds" "0" "$code"
check "CLAUDE.md kept" "1" "$(grep -c 'project text' "$p/CLAUDE.md")"
check "reported as kept" "1" "$(grep -c 'kept     CLAUDE.md' <<<"$out")"
check "nothing else changed" "" "$(git -C "$p" status --porcelain)"

echo "an upgrade removes a file the kit no longer ships"
echo "old" > "$p/scripts/process/retired.sh"
echo "$(sha "$p/scripts/process/retired.sh") scripts/process/retired.sh" >> "$p/.ai-dev-process.lock"
commit_all "$p" "chore: pretend an older kit shipped retired.sh"
out="$(bash "$SRC/install.sh" "$p" 2>&1)"; code=$?
check "succeeds" "0" "$code"
check "file removed" "no" "$([ -f "$p/scripts/process/retired.sh" ] && echo yes || echo no)"
check "lock no longer lists it" "0" "$(grep -c retired "$p/.ai-dev-process.lock")"

rm -rf "$WORK"
echo
if [ "$FAILURES" -eq 0 ]; then
  echo "all checks passed"
else
  echo "$FAILURES check(s) failed"
  exit 1
fi
