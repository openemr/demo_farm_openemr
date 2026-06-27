#!/usr/bin/env bash
#
# test.sh -- run derive.sh against each fixture, diff vs expected.
#
# Each fixture directory contains:
#   current/                                      -- inputs (current demo_farm state)
#     ip_map_branch.txt
#     docker/scripts/demoLibrary.source
#   upstream/                                     -- inputs (simulated upstream)
#     master/.github/release-targets.yml
#     master/ci/apache_<NN>_*/                    (empty dirs; names parsed
#                                                  for supported PHP set)
#     master/docker/release/Dockerfile
#     rel-*/docker/release/Dockerfile
#   expected/                                     -- expected derive.sh output
#     ip_map_branch.txt
#     docker/scripts/demoLibrary.source
#   OR
#   expected/                                     -- expected failure
#     fail.txt                                    (substring expected in stderr)
#
# Exit code: 0 if all fixtures pass; 1 otherwise.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DERIVE="$SCRIPT_DIR/../derive.sh"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

if ! command -v yq >/dev/null; then
    echo "ERROR: yq not on PATH; cannot run tests." >&2
    exit 2
fi

PASS=0
FAIL=0
FAILED_NAMES=()

for fixture_dir in "$FIXTURES_DIR"/*/; do
    name="$(basename "$fixture_dir")"
    echo "=== fixture: $name ==="

    fail_marker="$fixture_dir/expected/fail.txt"
    expected_dir="$fixture_dir/expected"

    # workspace = throwaway copy of current/ (so --write doesn't mutate fixture)
    workspace="$(mktemp -d)"
    trap 'rm -rf "$workspace"' RETURN
    cp -a "$fixture_dir/current/." "$workspace/"

    upstream_url="file://$fixture_dir/upstream"

    set +e
    output="$("$DERIVE" \
        --current-dir "$workspace" \
        --upstream-base "$upstream_url" \
        --write 2>&1)"
    exit_code=$?
    set -e

    if [[ -f "$fail_marker" ]]; then
        # Expect a failure containing the substring in fail.txt
        expected_msg="$(cat "$fail_marker")"
        if [[ $exit_code -ne 0 ]] && grep -qF "$expected_msg" <<< "$output"; then
            echo "  PASS (expected fail: '$expected_msg')"
            PASS=$((PASS+1))
        else
            echo "  FAIL: expected failure with substring '$expected_msg'; got exit=$exit_code, output:"
            echo "$output" | sed 's/^/    | /'
            FAIL=$((FAIL+1))
            FAILED_NAMES+=("$name")
        fi
        rm -rf "$workspace"
        continue
    fi

    if [[ $exit_code -ne 0 ]]; then
        echo "  FAIL: derive.sh exited $exit_code"
        echo "$output" | sed 's/^/    | /'
        FAIL=$((FAIL+1))
        FAILED_NAMES+=("$name")
        rm -rf "$workspace"
        continue
    fi

    fixture_ok=1
    for f in ip_map_branch.txt docker/scripts/demoLibrary.source; do
        if ! diff -u "$expected_dir/$f" "$workspace/$f" >/tmp/diff.out 2>&1; then
            echo "  FAIL: $f differs from expected"
            sed 's/^/    | /' /tmp/diff.out
            fixture_ok=0
        fi
    done
    if [[ $fixture_ok -eq 1 ]]; then
        echo "  PASS"
        PASS=$((PASS+1))
    else
        FAIL=$((FAIL+1))
        FAILED_NAMES+=("$name")
    fi
    rm -rf "$workspace"
done

echo
echo "=========================="
echo "fixtures passed: $PASS"
echo "fixtures failed: $FAIL"
if [[ $FAIL -gt 0 ]]; then
    echo "failed:"
    for n in "${FAILED_NAMES[@]}"; do echo "  - $n"; done
    exit 1
fi
exit 0
