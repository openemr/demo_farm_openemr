#!/usr/bin/env bash
#
# run-all.sh -- run the Phase 2 integration suite (3 representative
# scenarios that exercise distinct, expensive live behavior).
#
# The 4 remaining Phase 1 fixtures stay dry-run-only:
#   light-reset, multi-demo: cost vs signal is wrong (3x composer/npm
#       for the loop test; lightReset just gates the post-loop block).
#   capsule-path-traversal: fail-expected, no live behavior.
#   up-for-grabs-fork: depends on a third-party fork's branch state
#       (flaky-by-design; not our regression to catch).
#
# Per-scenario timeouts are inherited from run-scenario.sh (default
# 900s = 15 min). On a CI runner without composer/npm caches the
# total wall time is ~30-45 min; with caches ~15-20 min.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER="$SCRIPT_DIR/run-scenario.sh"

# MUST stay in sync with the matrix in
# .github/workflows/build-tests-live.yml. CI parallelizes these via the
# matrix; this script runs them sequentially for local use.
LIVE_SCENARIOS=(
    branch-pinned-master
    tag-pinned-with-data
    release-packageserve
)

PASS=0
FAIL=0
FAILED_NAMES=()

for sc in "${LIVE_SCENARIOS[@]}"; do
    echo
    echo "############################################################"
    echo "# Phase 2 scenario: $sc"
    echo "############################################################"
    if "$RUNNER" "$sc"; then
        PASS=$((PASS+1))
    else
        FAIL=$((FAIL+1))
        FAILED_NAMES+=("$sc")
    fi
done

echo
echo "=========================="
echo "Phase 2 integration summary"
echo "  passed: $PASS"
echo "  failed: $FAIL"
if [[ $FAIL -gt 0 ]]; then
    echo "failed scenarios:"
    for n in "${FAILED_NAMES[@]}"; do
        echo "  - $n"
    done
    exit 1
fi
exit 0
