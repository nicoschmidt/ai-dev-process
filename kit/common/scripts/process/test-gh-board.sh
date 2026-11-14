#!/usr/bin/env bash
# Managed by ai-dev-process.
#
# Exercise gh-board.sh against a stand-in for gh. Needs no credentials and
# writes nothing to GitHub: every gh call is answered from the fixture below,
# and the write calls are recorded instead of sent.
#
#   bash scripts/process/test-gh-board.sh
#
# Run this after changing gh-board.sh. Twice a broken helper reached the
# maintainer because nothing could call the real gh — a stand-in can.

set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
LOG="$(mktemp)"
ADDLOG="$(mktemp)"
ISSUES="$(mktemp)"     # the repository's issues, one "number|title" per line
FAILURES=0

gh() {
  if [ -n "${GH_FAIL:-}" ] && [ "$1 $2" = "$GH_FAIL" ]; then
    echo "stand-in refused: $*" >&2
    return 1
  fi
  case "$1 $2" in
    "project list") echo "$FIXTURE_PROJECTS" ;;
    "project view") echo '{"id":"PVT_test"}' ;;
    "project field-list") echo "$FIXTURE_FIELDS" ;;
    "project item-list") echo "$FIXTURE_ITEMS" ;;
    "project item-add") echo "$*" >> "$ADDLOG"; echo '{"id":"ITEM_NEW"}' ;;
    "project item-edit") echo "$*" >> "$LOG" ;;
    "issue list")
      jq -R -s --arg r "$GH_REPO" 'split("\n") | map(select(length > 0) | split("|")
        | {number: (.[0] | tonumber), title: .[1], url: "https://github.com/\($r)/issues/\(.[0])"})' "$ISSUES" ;;
    "issue create")
      if [ -n "${FIXTURE_ISSUE_URL+set}" ]; then echo "$FIXTURE_ISSUE_URL"; return 0; fi
      local title="" n
      while [ $# -gt 0 ]; do [ "$1" = "--title" ] && title="$2"; shift; done
      n=$(( 17 + $(wc -l < "$ISSUES") ))
      echo "$n|$title" >> "$ISSUES"
      echo "https://github.com/$GH_REPO/issues/$n" ;;
    *) echo "unexpected gh call: $*" >&2; return 1 ;;
  esac
}

FIXTURE_FIELDS='{"fields":[
 {"id":"F_status","name":"Status","type":"single_select","options":[{"id":"o_ready","name":"Ready"}]},
 {"id":"F_size","name":"Size","type":"single_select","options":[{"id":"o_s","name":"S"},{"id":"o_m","name":"M"},{"id":"o_l","name":"L"}]},
 {"id":"F_iter","name":"Iteration","type":"single_select","options":[{"id":"o_backlog","name":"Backlog"},{"id":"o_001","name":"001 First"}]},
 {"id":"F_title","name":"Title","type":"text"}]}'
FIXTURE_ITEMS='{"items":[{"id":"ITEM_13","content":{"type":"Issue","number":13}}]}'
FIXTURE_PROJECTS='{"projects":[{"number":1,"title":"Board"}]}'

export GH_REPO="example-owner/example-repo"

# shellcheck source=gh-board.sh
source "$HERE/gh-board.sh"
board_connect >/dev/null

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

echo "owner/name from the git remote"
tmp="$(mktemp -d)"
git -C "$tmp" init -q
git -C "$tmp" remote add origin "git@github.com:an-owner/a-repo.git"
check "ssh remote" "an-owner/a-repo" "$(cd "$tmp" && board_repo)"
git -C "$tmp" remote set-url origin "https://github.com/an-owner/a-repo.git"
check "https remote" "an-owner/a-repo" "$(cd "$tmp" && board_repo)"
git -C "$tmp" remote set-url origin "https://github.com/an-owner/a-repo"
check "https remote without .git" "an-owner/a-repo" "$(cd "$tmp" && board_repo)"
git -C "$tmp" remote remove origin
( cd "$tmp" && board_repo ) >/dev/null 2>&1
check "no remote fails" "1" "$?"
rm -rf "$tmp"

echo "the board from .ai-dev-process.conf"
tmp="$(mktemp -d)"
git -C "$tmp" init -q
reconnect() {          # reconnect: forget the board, connect again from $tmp
  OWNER="${PROJECT_OWNER:-}"; NUMBER="${PROJECT_NUMBER:-}"
  ( cd "$tmp" && board_connect 2>&1 )
}
FIXTURE_PROJECTS='{"projects":[{"number":1,"title":"One"},{"number":7,"title":"Seven"}]}'
out="$(reconnect)"; code=$?
check "two boards and no conf fails" "1" "$code"
check "names the conf file" "1" "$(grep -c 'no board_number in .ai-dev-process.conf' <<<"$out")"
check "lists both boards" "2" "$(grep -c '  PROJECT_NUMBER=' <<<"$out")"
printf '# facts\nboard_owner=conf-owner\nboard_number=7   \nhome_repo=o/r\n' > "$tmp/.ai-dev-process.conf"
out="$(reconnect)"; code=$?
check "two boards and a conf succeeds" "0" "$code"
check "owner and number come from the conf" "1" "$(grep -c '^Board: conf-owner #7 (.ai-dev-process.conf)' <<<"$out")"
out="$(PROJECT_NUMBER=1 reconnect)"; code=$?
check "the environment overrides the conf" "1" "$(grep -c '^Board: conf-owner #1 (environment)' <<<"$out")"
printf 'board_owner=<owner>\nboard_number=<number>\n' > "$tmp/.ai-dev-process.conf"
out="$(reconnect)"; code=$?
check "placeholders count as unset" "1" "$code"
check "and fall back to the repository's owner" "1" "$(grep -c "owner 'example-owner'" <<<"$out")"
printf 'board_number=seven\n' > "$tmp/.ai-dev-process.conf"
out="$(reconnect)"; code=$?
check "a number that is not one fails" "1" "$code"
FIXTURE_PROJECTS='{"projects":[{"number":1,"title":"Board"}]}'
rm -f "$tmp/.ai-dev-process.conf"
out="$(reconnect)"; code=$?
check "one board and no conf still works" "1" "$(grep -c "^Board: example-owner #1 (the owner's only board)" <<<"$out")"
rm -rf "$tmp"
board_connect >/dev/null

echo "the issue url is built from that repository"
: > "$ADDLOG"
FIXTURE_ITEMS='{"items":[]}'
board_item_for_issue 42 >/dev/null
check "url is built from GH_REPO" \
  "https://github.com/example-owner/example-repo/issues/42" \
  "$(sed -n '1s/.*--url \([^ ]*\).*/\1/p' "$ADDLOG")"
FIXTURE_ITEMS='{"items":[{"id":"ITEM_13","content":{"type":"Issue","number":13}}]}'

echo "an issue already on the board"
: > "$LOG"
out="$(set_issue_fields 13 S Backlog 2>&1)"; code=$?
check "succeeds" "0" "$code"
check "writes size" \
  "project item-edit --id ITEM_13 --project-id PVT_test --field-id F_size --single-select-option-id o_s" \
  "$(sed -n 1p "$LOG")"
check "writes iteration" \
  "project item-edit --id ITEM_13 --project-id PVT_test --field-id F_iter --single-select-option-id o_backlog" \
  "$(sed -n 2p "$LOG")"

echo "an issue not yet on the board"
: > "$LOG"
FIXTURE_ITEMS='{"items":[]}'
out="$(set_issue_fields 99 M "001 First" 2>&1)"; code=$?
check "succeeds" "0" "$code"
check "adds the item first" "ITEM_NEW" "$(sed -n '1s/.*--id \([^ ]*\).*/\1/p' "$LOG")"
FIXTURE_ITEMS='{"items":[{"id":"ITEM_13","content":{"type":"Issue","number":13}}]}'

echo "an option the board does not have"
: > "$LOG"
out="$(set_issue_fields 13 XL Backlog 2>&1)"; code=$?
check "fails" "1" "$code"
check "writes nothing" "" "$(cat "$LOG")"
check "names the options it found" "S M L" "$(grep -E '^ +[SML]$' <<<"$out" | tr -d ' ' | tr '\n' ' ' | sed 's/ $//')"
check "reports no success" "" "$(grep -c '^set ' <<<"$out" | grep -v '^0$')"

echo "a field the board does not have"
: > "$LOG"
saved_size="$FIELD_SIZE"
FIELD_SIZE="Nope"
out="$(set_issue_fields 13 S Backlog 2>&1)"; code=$?
FIELD_SIZE="$saved_size"
check "fails" "1" "$code"
check "writes nothing" "" "$(cat "$LOG")"
check "lists the board's fields" "Status Size Iteration Title" \
  "$(grep -oE '^(Status|Size|Iteration|Title)' <<<"$out" | tr '\n' ' ' | sed 's/ $//')"

echo "a board that calls the field Größe"
: > "$LOG"
saved="$FIELDS"
FIELDS='{"fields":[{"id":"F_g","name":"Größe","type":"single_select","options":[{"id":"o_s","name":"S"}]},
 {"id":"F_i","name":"Iteration","type":"single_select","options":[{"id":"o_b","name":"Backlog"}]}]}'
out="$(set_issue_fields 13 S Backlog 2>&1)"; code=$?
check "the second candidate wins" "0" "$code"
check "writes to that field" "F_g" "$(sed -n '1s/.*--field-id \([^ ]*\).*/\1/p' "$LOG")"
FIELDS="$saved"

echo "create_issue end to end"
: > "$LOG"
FIXTURE_ITEMS='{"items":[]}'
out="$(create_issue "type:spike" "S" "Backlog" "A title" <<< "A body" 2>&1)"; code=$?
check "succeeds" "0" "$code"
check "sets both fields" "2" "$(wc -l < "$LOG" | tr -d ' ')"

# Handovers call the helpers as `create_issue … || exit 1`. Under `||` bash
# suspends `set -e` inside the function, so each gh call must be checked by
# the helper itself. Each case runs the documented form and asserts that the
# caller stops, and that the message names the step that failed.
echo "gh failing, called as a handover calls the helpers"
FIXTURE_ITEMS='{"items":[]}'
for step in "issue list" "issue create" "project item-list" "project item-add" "project item-edit"; do
  : > "$LOG"
  : > "$ISSUES"
  out="$(GH_FAIL="$step"
         { create_issue "type:bug" "S" "Backlog" "A title" <<< "A body" || exit 1
           echo "CARRIED ON"; } 2>&1)"; code=$?
  check "$step fails: the caller exits non-zero" "1" "$code"
  check "$step fails: the caller does not carry on" "0" "$(grep -c 'CARRIED ON' <<<"$out")"
  check "$step fails: the message names it" "1" "$(grep -c "^gh $step failed" <<<"$out")"
  check "$step fails: no field is reported as set" "0" "$(grep -cE '^ +(Size|Iteration) = ' <<<"$out")"
done

echo "gh answers issue create without an issue url"
: > "$ISSUES"
out="$(FIXTURE_ISSUE_URL=""
       { create_issue "type:bug" "S" "Backlog" "A title" <<< "A body" || exit 1
         echo "CARRIED ON"; } 2>&1)"; code=$?
check "the caller exits non-zero" "1" "$code"
check "the caller does not carry on" "0" "$(grep -c 'CARRIED ON' <<<"$out")"
check "nothing is reported as created" "0" "$(grep -c '^created' <<<"$out")"

echo "set_issue_fields without an issue number"
: > "$LOG"
out="$({ set_issue_fields "" S Backlog || exit 1; echo "CARRIED ON"; } 2>&1)"; code=$?
check "the caller exits non-zero" "1" "$code"
check "writes nothing" "" "$(cat "$LOG")"

echo "gh failing while connecting to the board"
for step in "project view" "project field-list"; do
  out="$(GH_FAIL="$step"; { board_connect || exit 1; echo "CARRIED ON"; } 2>&1)"; code=$?
  check "$step fails: the caller exits non-zero" "1" "$code"
  check "$step fails: the message names it" "1" "$(grep -c "^gh $step failed" <<<"$out")"
done
tmp="$(mktemp -d)"
git -C "$tmp" init -q
out="$(cd "$tmp"; GH_FAIL="project list"; NUMBER=""
       { board_connect || exit 1; echo "CARRIED ON"; } 2>&1)"; code=$?
check "project list fails: the caller exits non-zero" "1" "$code"
check "project list fails: the message names it" "1" "$(grep -c '^gh project list failed' <<<"$out")"
rm -rf "$tmp"

echo "an issue with the same title exists"
: > "$LOG"
: > "$ADDLOG"
printf '5|Another title\n9|A title\n12|A title, longer\n' > "$ISSUES"
FIXTURE_ITEMS='{"items":[]}'
out="$(create_issue "type:bug" "S" "Backlog" "A title" <<< "A body"; echo "number=$LAST_ISSUE_NUMBER")"; code=$?
check "succeeds" "0" "$code"
check "reuses its number" "number=9" "$(grep '^number=' <<<"$out")"
check "says so" "1" "$(grep -c '^exists .*/issues/9 .*reused' <<<"$out")"
check "creates nothing" "3" "$(wc -l < "$ISSUES" | tr -d ' ')"
check "still sets both fields" "2" "$(wc -l < "$LOG" | tr -d ' ')"

echo "the same title twice, as a handover script run twice"
: > "$ISSUES"
for run in 1 2; do
  out="$(create_issue "type:bug" "S" "Backlog" "Run me twice" <<< "A body" || exit 1)"; code=$?
  check "run $run succeeds" "0" "$code"
done
check "one issue exists" "1" "$(wc -l < "$ISSUES" | tr -d ' ')"

echo "several issues with that title"
printf '30|Twin\n21|Twin\n' > "$ISSUES"
out="$(create_issue "type:bug" "S" "Backlog" "Twin" <<< "A body"; echo "number=$LAST_ISSUE_NUMBER")"
check "reuses the oldest" "number=21" "$(grep '^number=' <<<"$out")"

rm -f "$LOG" "$ADDLOG" "$ISSUES"
echo
if [ "$FAILURES" -eq 0 ]; then
  echo "all checks passed"
else
  echo "$FAILURES check(s) failed"
  exit 1
fi
