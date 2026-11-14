#!/usr/bin/env bash
# Exercise setup-repository.sh and finish-setup.sh with real repositories in a
# temporary project folder and a stand-in for gh. Writes nothing to GitHub and
# nothing outside a temporary directory.
#
#   bash tests/test-setup.sh

set -uo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
FAILURES=0
VERSION="$(tr -d '[:space:]' < "$SRC/VERSION")"
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
export GH_STATE="$WORK/gh"

# The stand-in: "GitHub" is bare repositories and a few files under $GH_STATE.
mkdir -p "$WORK/bin"
cat > "$WORK/bin/gh" <<'STANDIN'
#!/usr/bin/env bash
S="$GH_STATE"; mkdir -p "$S/repos"; touch "$S/labels" "$S/ms" "$S/issues" "$S/prs" "$S/calls"
argval() { local k="$1"; shift; while [ $# -gt 0 ]; do [ "$1" = "$k" ] && { echo "$2"; return; }; shift; done; }
key="$1 $2"
if [ "$1" = "api" ]; then
  if [[ " $* " == *" -f "* ]]; then key="api create milestone"; else key="api milestones"; fi
fi
echo "$key|$*" >> "$S/calls"
if [ -n "${GH_FAIL:-}" ] && [ "$key" = "$GH_FAIL" ]; then echo "stand-in refused: $*" >&2; exit 1; fi
bare() { echo "$S/repos/$(tr '/' '_' <<<"$1").git"; }
case "$key" in
  "repo view") [ -d "$(bare "$3")" ] ;;
  "repo clone") git clone -q "$(bare "$3")" "$4" ;;
  "repo create")
    git init -q --bare -b main "$(bare "$3")"
    tmp="$(mktemp -d)"; git init -q -b main "$tmp"; echo "# new" > "$tmp/README.md"
    git -C "$tmp" add -A; git -C "$tmp" commit -q -m "Initial commit"
    git -C "$tmp" push -q "$(bare "$3")" main; rm -rf "$tmp"
    git clone -q "$(bare "$3")" "${3##*/}" ;;
  "label list") grep "^$GH_REPO|" "$S/labels" | cut -d'|' -f2 ;;
  "label create") echo "$GH_REPO|$3" >> "$S/labels" ;;
  "api milestones")
    repo="${2#repos/}"; repo="${repo%%/milestones*}"
    { grep -F -- "$repo|" "$S/ms" || true; } | jq -R -s 'split("\n") | map(select(length > 0) | split("|") | {title: .[1], state: .[2]})' ;;
  "api create milestone")
    repo="${2#repos/}"; repo="${repo%%/milestones*}"
    for a in "$@"; do case "$a" in title=*) title="${a#title=}" ;; esac; done
    echo "$repo|$title|open" >> "$S/ms"; echo '{}' ;;
  "issue list")
    { grep "^$GH_REPO|" "$S/issues" || true; } | jq -R -s 'split("\n") | map(select(length > 0) | split("|")
      | {number: (.[1] | tonumber), title: .[2], url: "https://github.com/\(.[0])/issues/\(.[1])"})' ;;
  "issue create")
    n=$(( 17 + $(wc -l < "$S/issues") ))
    echo "$GH_REPO|$n|$(argval --title "$@")|$(argval --milestone "$@")" >> "$S/issues"
    echo "https://github.com/$GH_REPO/issues/$n" ;;
  "issue edit") ;;
  "pr list") { grep -F -- "|$(argval --head "$@")|" "$S/prs" || true; } | cut -d'|' -f1 ;;
  "pr create") echo "40|$(argval --head "$@")|$(argval --body "$@" | tr '\n' ' ')" >> "$S/prs"; echo "https://github.com/x/y/pull/40" ;;
  *) echo "unexpected gh call: $*" >&2; exit 2 ;;
esac
STANDIN
chmod +x "$WORK/bin/gh"
export PATH="$WORK/bin:$PATH"

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
calls() { grep -c "^$1|" "$GH_STATE/calls"; }
on_github() {          # on_github <owner/repo>: a repository with one commit, as GitHub would hold it
  local bare="$GH_STATE/repos/$(tr '/' '_' <<<"$1").git" tmp
  mkdir -p "$GH_STATE/repos"
  git init -q --bare -b main "$bare"
  tmp="$(mktemp -d)"; git init -q -b main "$tmp"; echo "# app" > "$tmp/README.md"
  git -C "$tmp" add -A; git -C "$tmp" commit -q -m "Initial commit"
  git -C "$tmp" push -q "$bare" main; rm -rf "$tmp"
}
fill() {               # fill <dir>: replace every placeholder in the two files, as a session would
  local f i
  for f in "$1/CLAUDE.md" "$1/.ai-dev-process.conf"; do
    for i in 1 2 3; do sed -E -i.bak 's/<[^!\/<>][^<>]*>/filled/g' "$f"; done
    rm -f "$f.bak"
  done
}

PROJECT="$WORK/My Project"
mkdir -p "$PROJECT"
cd "$PROJECT"
BRANCH="chore/17-ai-dev-process-$VERSION"

echo "an existing repository, first run"
on_github o/app
out="$(bash "$SRC/setup-repository.sh" o/app 2>&1)"; code=$?
check "succeeds" "0" "$code"
check "clones it into the project folder" "yes" "$([ -d app/.git ] && echo yes || echo no)"
check "creates the six labels" "6" "$(calls 'label create')"
check "creates the milestone" "o/app|000 Setting up|open" "$(cat "$GH_STATE/ms")"
check "creates the issue in the milestone" "o/app|17|chore: adopt ai-dev-process v$VERSION|000 Setting up" "$(cat "$GH_STATE/issues")"
check "is on the branch with the issue's number" "$BRANCH" "$(git -C app branch --show-current)"
check "installs with the role single" "single" "$(sed -n 's/^role //p' app/.ai-dev-process.lock)"
check "commits nothing" "1" "$(git -C app rev-list --count HEAD)"
check "lists what is left to fill in" "1" "$(grep -c 'home_repo=<owner>/<repository>' <<<"$out")"
check "names the next step" "1" "$(grep -c 'finish-setup.sh" app' <<<"$out")"

echo "the same again"
out="$(bash "$SRC/setup-repository.sh" o/app 2>&1)"; code=$?
check "succeeds" "0" "$code"
check "creates no second issue" "1" "$(calls 'issue create')"
check "creates no second milestone" "1" "$(calls 'api create milestone')"
check "creates no label again" "6" "$(calls 'label create')"
check "does not clone again" "1" "$(calls 'repo clone')"
check "does not install again" "1" "$(grep -c '^exists   .* is installed' <<<"$out")"

echo "finish with placeholders left"
out="$(bash "$SRC/finish-setup.sh" app 2>&1)"; code=$?
check "fails" "1" "$code"
check "names a line with a placeholder" "1" "$(grep -c '.ai-dev-process.conf:.*home_repo=<owner>/<repository>' <<<"$out")"
check "commits nothing" "1" "$(git -C app rev-list --count HEAD)"
check "opens no pull request" "0" "$(calls 'pr create')"

echo "finish with the files filled in"
fill app
out="$(bash "$SRC/finish-setup.sh" app 2>&1)"; code=$?
check "succeeds" "0" "$code"
check "commits" "chore: adopt ai-dev-process $VERSION" "$(git -C app log -1 --format=%s)"
check "the commit closes the issue" "1" "$(git -C app log -1 --format=%b | grep -c '^Closes #17$')"
check "pushes the branch" "1" "$(git -C "$GH_STATE/repos/o_app.git" branch --list "$BRANCH" | wc -l | tr -d ' ')"
check "opens the pull request for it" "1" "$(grep -c "^40|$BRANCH|.*Closes #17" "$GH_STATE/prs")"
out="$(bash "$SRC/finish-setup.sh" app 2>&1)"; code=$?
check "again: succeeds" "0" "$code"
check "again: opens no second pull request" "1" "$(calls 'pr create')"
check "again: commits nothing new" "2" "$(git -C app rev-list --count HEAD)"

echo "a repository GitHub does not have"
out="$(bash "$SRC/setup-repository.sh" o/new 2>&1)"; code=$?
check "without --create: fails" "1" "$code"
check "without --create: says how" "1" "$(grep -c -- '--create public or --create private' <<<"$out")"
check "without --create: creates nothing" "0" "$(calls 'repo create')"
out="$(bash "$SRC/setup-repository.sh" --role home --create private o/new 2>&1)"; code=$?
check "with --create: succeeds" "0" "$code"
check "with --create: passes the visibility" "1" "$(grep '^repo create|' "$GH_STATE/calls" | grep -c -- '--private')"
check "with --create: installs with the role home" "home" "$(sed -n 's/^role //p' new/.ai-dev-process.lock)"

echo "a member repository"
on_github o/code
out="$(bash "$SRC/setup-repository.sh" --role member o/code 2>&1)"; code=$?
check "succeeds" "0" "$code"
check "installs with the role member" "member" "$(sed -n 's/^role //p' code/.ai-dev-process.lock)"
check "gets no ADRs or iterations" "no" "$([ -e code/docs/adr ] || [ -e code/docs/iterations ] && echo yes || echo no)"
check "gets the milestone of the same title" "1" "$(grep -c '^o/code|000 Setting up|open$' "$GH_STATE/ms")"

echo "a step fails"
on_github o/broken
out="$(GH_FAIL="issue create" bash "$SRC/setup-repository.sh" o/broken 2>&1)"; code=$?
check "fails" "1" "$code"
check "names the step" "1" "$(grep -c '^gh issue create failed' <<<"$out")"
check "creates no branch" "main" "$(git -C broken branch --show-current)"
check "installs nothing" "no" "$([ -f broken/.ai-dev-process.lock ] && echo yes || echo no)"
out="$(bash "$SRC/setup-repository.sh" o/broken 2>&1)"; code=$?
check "run again without the failure: succeeds" "0" "$code"
check "run again: installs" "yes" "$([ -f broken/.ai-dev-process.lock ] && echo yes || echo no)"

echo "wrong arguments, wrong place"
out="$(bash "$SRC/setup-repository.sh" app 2>&1)"; check "a name without an owner fails" "1" "$?"
out="$(bash "$SRC/setup-repository.sh" --role boss o/app 2>&1)"; check "an unknown role fails" "1" "$?"
out="$(cd app && bash "$SRC/setup-repository.sh" o/app 2>&1)"; code=$?
check "inside a repository: fails" "1" "$code"
check "inside a repository: says to use the project folder" "1" "$(grep -c 'project folder' <<<"$out")"

cd /
rm -rf "$WORK"
echo
if [ "$FAILURES" -eq 0 ]; then
  echo "all checks passed"
else
  echo "$FAILURES check(s) failed"
  exit 1
fi
