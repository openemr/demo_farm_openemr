#!/usr/bin/env bash
#
# test.sh -- run demo_build.sh --dry-run against each fixture, diff vs
# the golden action log. Exit 0 iff every fixture matches its golden.
#
# Each fixture directory contains:
#   inputs.env                   -- env vars sourced before the run.
#                                   Required: DOCKERDEMO.
#                                   Optional: DOCKERMYSQLHOST,
#                                   DOCKERNUMBERDEMOS, PHP_VERSION_ABBR,
#                                   EXTRA_ARGS (appended after --dry-run).
#   ip_map_branch.txt            -- the ip_map subset the script will read.
#                                   Should contain ONLY the row(s) needed
#                                   for this scenario to avoid the
#                                   grep "$IPADDRESS" substring-match
#                                   ambiguity (e.g., "two" matches both
#                                   "two" and "two_a" rows).
#   extra/                       -- (optional) tree of files copied OVER
#                                   the kitchen-sink work tree post-setup,
#                                   mirroring its layout (the work tree
#                                   places openemr at $WEB/openemr, so
#                                   fixture overrides need the web/ prefix).
#                                   Use for per-scenario marker contents:
#                                     extra/web/openemr/version.php       (sets $v_major)
#                                     extra/git/demo_farm_openemr/pieces/demo_5_0_0_5.sql
#                                     extra/capsules/<name>.tgz
#   expected/action-log.txt      -- the golden, with $WORK paths replaced
#                                   by the literal token <WORK>.
#                                   OR
#   expected/fail.txt             -- substring expected in stderr/stdout
#                                   when the script is supposed to abort
#                                   (e.g., the useCapsuleFile guard). The
#                                   harness asserts exit != 0 AND the
#                                   substring is present; action-log.txt
#                                   is not required for fail-expected
#                                   fixtures.
#
# To regenerate a fixture's golden after intentional changes to
# demo_build.sh, run:
#   UPDATE_GOLDENS=1 ./tools/build-tests/test.sh
# and review the diff before committing. (UPDATE_GOLDENS is a no-op for
# fail-expected fixtures -- fail.txt is hand-authored.)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEMO_BUILD="$REPO_ROOT/demo_build.sh"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"
UPDATE_GOLDENS="${UPDATE_GOLDENS:-0}"

if [[ ! -x "$DEMO_BUILD" ]]; then
    chmod +x "$DEMO_BUILD" 2>/dev/null || true
fi

# Per-fixture work dirs are tracked here and cleaned up at script exit.
# NOTE: an earlier draft used `trap ... RETURN` inside run_one_fixture(),
# but bash fires RETURN on `source` too -- so sourcing the fixture's
# inputs.env triggered the trap mid-setup and nuked the work dir.
WORK_DIRS=()
# shellcheck disable=SC2317  # invoked via the EXIT trap below
cleanup_work_dirs () {
    local w
    for w in "${WORK_DIRS[@]}"; do
        rm -rf "$w"
    done
}
trap cleanup_work_dirs EXIT

# Stand up a kitchen-sink work tree for a single fixture run. Layout
# mirrors what demo_build.sh expects at production paths. Marker files
# are empty unless the fixture's extra/ tree provides content (e.g.,
# version.php's $v_major drives a real branch in the script).
#
# Marker files are seeded both under the main $WEB/openemr/ (== $OPENEMR
# when demo="empty") AND under $WEB/<letter>/openemr/ for letters a..i so
# multi-demo fixtures (DOCKERNUMBERDEMOS=N up to 10) get the same gated
# blocks (npm, swagger, ofc) on every iteration, not just the empty one.
setup_work_tree () {
    local work="$1"
    mkdir -p \
        "$work/web/log" \
        "$work/git/demo_farm_openemr/pieces" \
        "$work/capsules" \
        "$work/tmp"
    touch "$work/git/demo_farm_openemr/openemr-alpine.conf"

    # demosGo iterates over ("empty" "a" "b" ... "i"); "empty" maps to
    # $WEB/openemr while letters map to $WEB/$letter/openemr. Seed both.
    local sub
    for sub in "" a b c d e f g h i; do
        local oe
        if [[ -z "$sub" ]]; then
            oe="$work/web/openemr"
        else
            oe="$work/web/$sub/openemr"
        fi
        mkdir -p \
            "$oe/sites/default/documents" \
            "$oe/contrib/util/installScripts" \
            "$oe/swagger" \
            "$oe/library/openflashchart/php-ofc-library" \
            "$oe/ccdaservice" \
            "$oe/interface/modules/zend_modules/config"

        # Marker files (gated `[ -f ... ]` checks in demo_build.sh).
        touch \
            "$oe/sites/default/sqlconf.php" \
            "$oe/package.json" \
            "$oe/ccdaservice/package.json" \
            "$oe/contrib/util/installScripts/InstallerAuto.php" \
            "$oe/swagger/openemr-api.yaml" \
            "$oe/library/openflashchart/php-ofc-library/ofc_upload_image.php" \
            "$oe/sql_upgrade.php"

        # version.php content matters: collect_var pulls $v_major out of it
        # and the script branches on $v_major >= 6 (utf8mb4 collation block).
        # Default to a modern major so the branch is exercised. Per-fixture
        # extra/web/<sub>/openemr/version.php may override.
        printf '<?php\n$v_major = "7";\n' > "$oe/version.php"
    done
}

# Normalize the captured action log: replace the throwaway $WORK path
# with the literal token <WORK> so goldens are portable across runs.
normalize_action_log () {
    local work="$1"
    local action_log="$2"
    # Escape regex metachars in $work before sed (path is /tmp/something).
    local work_esc
    work_esc="$(printf '%s' "$work" | sed 's|[\\/.[^$*]|\\&|g')"
    sed -i "s|${work_esc}|<WORK>|g" "$action_log"
}

run_one_fixture () {
    local fixture_dir="$1"
    local name
    name="$(basename "$fixture_dir")"

    local inputs="$fixture_dir/inputs.env"
    local ip_map="$fixture_dir/ip_map_branch.txt"
    local extra_dir="$fixture_dir/extra"
    local expected="$fixture_dir/expected/action-log.txt"
    local fail_marker="$fixture_dir/expected/fail.txt"

    if [[ ! -f "$inputs" ]]; then
        echo "  FAIL: missing $inputs"
        return 1
    fi
    if [[ ! -f "$ip_map" ]]; then
        echo "  FAIL: missing $ip_map"
        return 1
    fi

    local work
    work="$(mktemp -d)"
    WORK_DIRS+=("$work")

    setup_work_tree "$work"
    cp "$ip_map" "$work/git/demo_farm_openemr/ip_map_branch.txt"
    if [[ -d "$extra_dir" ]]; then
        # `cp -a extra/. $work/` overlays the fixture's extras on top of
        # the kitchen-sink tree (per-scenario marker contents).
        cp -a "$extra_dir/." "$work/"
    fi

    local action_log="$work/action.log"

    # Source the fixture's env. Defaults applied for keys it doesn't set.
    DOCKERDEMO=""
    DOCKERMYSQLHOST="mysql"
    DOCKERNUMBERDEMOS=""
    PHP_VERSION_ABBR="85"
    EXTRA_ARGS=""
    # shellcheck disable=SC1090
    source "$inputs"

    if [[ -z "$DOCKERDEMO" ]]; then
        echo "  FAIL: inputs.env must set DOCKERDEMO"
        return 1
    fi

    # Run the script. Pipe stdout/stderr to /dev/null -- only the action
    # log matters here; the script's verbose status output would drown
    # the test summary otherwise.
    set +e
    DOCKERDEMO="$DOCKERDEMO" \
    DOCKERMYSQLHOST="$DOCKERMYSQLHOST" \
    DOCKERNUMBERDEMOS="$DOCKERNUMBERDEMOS" \
    PHP_VERSION_ABBR="$PHP_VERSION_ABBR" \
    WEB="$work/web" \
    webUser="root" \
    GITMAIN="$work/git" \
    GITDEMOFARM="$work/git/demo_farm_openemr" \
    CAPSULES="$work/capsules" \
    OPENEMRTMPDIR="$work/tmp" \
    ACTION_LOG="$action_log" \
        bash "$DEMO_BUILD" --dry-run $EXTRA_ARGS >"$work/script.stdout" 2>"$work/script.stderr"
    local exit_code=$?
    set -e

    if [[ -f "$fail_marker" ]]; then
        # Fail-expected fixture: assert exit != 0 AND substring present in
        # combined stderr/stdout. Skips action-log diffing entirely.
        local expected_msg
        expected_msg="$(cat "$fail_marker")"
        if [[ $exit_code -eq 0 ]]; then
            echo "  FAIL: expected non-zero exit (fail marker present) but got 0"
            return 1
        fi
        # grep the files directly rather than `cat … | grep -qF`: under
        # `set -o pipefail` (enabled at the top of this script), grep
        # closing stdin early on a match makes cat exit with SIGPIPE,
        # which would turn a passing case into a false failure.
        if ! grep -qF -- "$expected_msg" "$work/script.stdout" "$work/script.stderr"; then
            echo "  FAIL: expected error substring '$expected_msg' not found in output"
            echo "  stdout (tail):"
            tail -n 20 "$work/script.stdout" | sed 's/^/    | /'
            echo "  stderr (tail):"
            tail -n 20 "$work/script.stderr" | sed 's/^/    | /'
            return 1
        fi
        echo "  PASS (expected fail: '$expected_msg', exit=$exit_code)"
        return 0
    fi

    if [[ $exit_code -ne 0 ]]; then
        echo "  FAIL: demo_build.sh --dry-run exited $exit_code"
        echo "  stdout (tail):"
        tail -n 20 "$work/script.stdout" | sed 's/^/    | /'
        echo "  stderr (tail):"
        tail -n 20 "$work/script.stderr" | sed 's/^/    | /'
        return 1
    fi

    # Defensive: if a regression makes demo_build.sh exit 0 without
    # producing an action log, fail this fixture cleanly rather than
    # letting `sed -i` on a missing file trip `set -e` and abort the
    # whole harness mid-run.
    if [[ ! -f "$action_log" ]]; then
        echo "  FAIL: missing action log $action_log (script exited 0 but produced no log)"
        echo "  stdout (tail):"
        tail -n 20 "$work/script.stdout" | sed 's/^/    | /'
        echo "  stderr (tail):"
        tail -n 20 "$work/script.stderr" | sed 's/^/    | /'
        return 1
    fi

    normalize_action_log "$work" "$action_log"

    if [[ "$UPDATE_GOLDENS" = "1" ]]; then
        mkdir -p "$(dirname "$expected")"
        cp "$action_log" "$expected"
        echo "  UPDATED: $expected"
        return 0
    fi

    if [[ ! -f "$expected" ]]; then
        echo "  FAIL: missing golden $expected"
        echo "  hint: run with UPDATE_GOLDENS=1 to seed it"
        return 1
    fi

    if ! diff -u "$expected" "$action_log" > "$work/diff.out" 2>&1; then
        echo "  FAIL: action log differs from golden"
        sed 's/^/    | /' "$work/diff.out"
        return 1
    fi

    echo "  PASS"
    return 0
}

PASS=0
FAIL=0
FAILED_NAMES=()

if [[ ! -d "$FIXTURES_DIR" ]] || [[ -z "$(find "$FIXTURES_DIR" -mindepth 1 -maxdepth 1 -type d -print -quit 2>/dev/null)" ]]; then
    echo "No fixtures found under $FIXTURES_DIR" >&2
    exit 2
fi

for fixture_dir in "$FIXTURES_DIR"/*/; do
    name="$(basename "$fixture_dir")"
    echo "=== fixture: $name ==="
    if run_one_fixture "$fixture_dir"; then
        PASS=$((PASS+1))
    else
        FAIL=$((FAIL+1))
        FAILED_NAMES+=("$name")
    fi
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
