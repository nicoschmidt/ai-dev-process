#!/usr/bin/env bash
# Every test, as CI runs them.
#
#   bash tests/run.sh
#
# New files must be `git add`ed first: the installer and its test read the
# kit from tracked files only.

set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
failed=0

echo "== syntax"
for script in $(git ls-files '*.sh' kit/common/.githooks); do
  bash -n "$script" || { echo "  bash -n failed: $script"; failed=1; }
done
[ "$failed" -eq 0 ] && echo "  ok    every script parses"

for test in tests/test-*.sh $(git ls-files 'kit/common/scripts/*.sh' | grep -E '(^|/)test-[^/]*\.sh$'); do
  echo
  echo "== $test"
  bash "$test" || { echo "::error file=$test::$test failed"; failed=1; }
done

echo
if [ "$failed" -eq 0 ]; then echo "every test passed"; else echo "some tests failed"; exit 1; fi
