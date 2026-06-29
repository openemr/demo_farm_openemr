#!/usr/bin/env bash
#
# run-scenario.sh -- run ONE Phase 2 integration test scenario end-to-end.
#
# Stands up mariadb + the openemr/openemr:flex base image, runs
# demo_build.sh against the fixture's ip_map_branch.txt, and asserts:
#   1. demo_build.sh reaches the "Demo install script is complete" marker
#      (i.e., walked the full code path including composer/npm install,
#      mariadb populate, apache start) within the timeout.
#   2. The fixture's database(s) exist in mariadb with the expected
#      OpenEMR tables populated (sanity check on the install + demo data).
#   3. The action log was written and contains the expected sequence of
#      sentinel ACTION lines (a per-fixture live-mode golden under
#      tools/build-tests/fixtures/<scenario>/expected/live-action-log.txt).
#
# Designed to run from the repo root inside CI or on a host with docker.
# Cleans up its containers + network on EXIT (success or failure) and
# leaves no orphaned state behind.
#
# Usage:
#   run-scenario.sh <scenario-name> [--image <flex-tag>] [--timeout <sec>]
#
# Env vars:
#   UPDATE_GOLDENS=1   Overwrite expected/live-action-log.txt with the
#                      captured (normalized) live log. Review the diff
#                      before committing.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
FIXTURES_DIR="$REPO_ROOT/tools/build-tests/fixtures"
DEMO_BUILD="$REPO_ROOT/demo_build.sh"

SCENARIO=""
# Default to the production flex image tag used by the `two` cluster
# (Alpine 3.22 / PHP 8.2). Per-fixture inputs.env may override via
# INTEGRATION_IMAGE.
IMAGE="openemr/openemr:flex-3.22-php-8.2"
IMAGE_FROM_CLI=0  # set when --image is passed; takes precedence over inputs.env
TIMEOUT_SECONDS=900   # 15 min ceiling for composer + npm + mariadb populate
UPDATE_GOLDENS="${UPDATE_GOLDENS:-0}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --image)   IMAGE="$2"; IMAGE_FROM_CLI=1; shift 2 ;;
        --timeout) TIMEOUT_SECONDS="$2"; shift 2 ;;
        --*)       echo "Unknown flag: $1" >&2; exit 2 ;;
        *)
            if [[ -z "$SCENARIO" ]]; then
                SCENARIO="$1"
                shift
            else
                echo "Unexpected positional arg: $1" >&2
                exit 2
            fi
            ;;
    esac
done

if [[ -z "$SCENARIO" ]]; then
    echo "Usage: $0 <scenario-name> [--image <tag>] [--timeout <sec>]" >&2
    exit 2
fi

FIXTURE_DIR="$FIXTURES_DIR/$SCENARIO"
if [[ ! -d "$FIXTURE_DIR" ]]; then
    echo "Fixture not found: $FIXTURE_DIR" >&2
    exit 2
fi

# Unique resource names per invocation. PID + random keep concurrent runs
# from colliding on the docker network/container names.
SUFFIX="$$-$RANDOM"
NETWORK="bt-net-$SUFFIX"
MARIADB="bt-mariadb-$SUFFIX"
OPENEMR="bt-openemr-$SUFFIX"
WORK="$(mktemp -d -t bt-run-XXXXXX)"

cleanup () {
    set +e
    docker stop "$OPENEMR"  >/dev/null 2>&1
    docker rm   "$OPENEMR"  >/dev/null 2>&1
    docker stop "$MARIADB"  >/dev/null 2>&1
    docker rm   "$MARIADB"  >/dev/null 2>&1
    docker network rm "$NETWORK" >/dev/null 2>&1
    rm -rf "$WORK"
}
trap cleanup EXIT

# Normalize the live action log so per-run-varying values are replaced
# with stable placeholders. Two sources of variance:
#   1. $MARIADB container name = "bt-mariadb-$PID-$RANDOM", embedded in
#      `mariadb -h <host>` arg by demo_build.sh via $DOCKERMYSQLHOST.
#   2. RANDOM_THEME picks a CSS file at random from one of the
#      getRandomThemeOne/Two arrays (style_<name>.css).
# Phase 1's `_emit_action_log` helper already redacts `-p<pass>` and
# `rootpass=<pass>`, so $mrp doesn't need handling here.
normalize_live_log () {
    local raw="$1"
    local out="$2"
    sed -E \
        -e "s/${MARIADB}/<MARIADB_HOST>/g" \
        -e 's/style_[a-z_]+\.css/<LIVE_RANDOM_THEME>/g' \
        "$raw" > "$out"
}

echo "=== Phase 2 integration: scenario=$SCENARIO image=$IMAGE ==="
echo "    work dir: $WORK"

# Source fixture inputs. Required: DOCKERDEMO. Optional: DOCKERNUMBERDEMOS,
# EXTRA_ARGS, INTEGRATION_IMAGE (per-fixture image override).
#
# PHP_VERSION_ABBR is intentionally NOT consumed here: the flex base
# image bakes it in (e.g., "82" for flex-3.22-php-8.2), and we never
# override it via --env on the container. The fixture inputs.env still
# carries the var because Phase 1 dry-run runs outside any flex image
# and needs the value for the script's `echo … > /etc/php${ABBR}/...`
# path. Sourcing-and-not-using here would imply a contract Phase 2
# doesn't actually have.
DOCKERDEMO=""
DOCKERNUMBERDEMOS=""
EXTRA_ARGS=""
INTEGRATION_IMAGE=""
# shellcheck disable=SC1091
source "$FIXTURE_DIR/inputs.env"

if [[ -z "$DOCKERDEMO" ]]; then
    echo "FAIL: $FIXTURE_DIR/inputs.env must set DOCKERDEMO" >&2
    exit 1
fi
if [[ -n "$INTEGRATION_IMAGE" && "$IMAGE_FROM_CLI" -eq 0 ]]; then
    # Fixture override only applies when --image wasn't explicitly passed;
    # CLI wins so callers can A/B-test against a different image without
    # editing the fixture.
    IMAGE="$INTEGRATION_IMAGE"
fi

# Skip fail-expected fixtures: they're a Phase 1 concern (assert script
# rejects bad input before any side effect) and have no live behavior to
# integration-test.
if [[ -f "$FIXTURE_DIR/expected/fail.txt" ]]; then
    echo "    skip: fail-expected fixture (Phase 1 covers; nothing to live-test)"
    exit 0
fi

# Build a fixture-specific GITDEMOFARM tree the openemr container will
# bind-mount read-only at /home/openemr/git/demo_farm_openemr. Production
# clones the whole demo_farm_openemr repo into the container; we mount
# the local checkout instead so we test the local demo_build.sh + the
# fixture's ip_map_branch.txt (not master's).
FAKE_GITDEMOFARM="$WORK/git/demo_farm_openemr"
mkdir -p "$FAKE_GITDEMOFARM/pieces"
cp "$FIXTURE_DIR/ip_map_branch.txt" "$FAKE_GITDEMOFARM/"
cp "$DEMO_BUILD"                    "$FAKE_GITDEMOFARM/demo_build.sh"
cp "$REPO_ROOT/openemr-alpine.conf" "$FAKE_GITDEMOFARM/"
cp "$REPO_ROOT/set_pass.php"        "$FAKE_GITDEMOFARM/"
if [[ -d "$FIXTURE_DIR/extra/git/demo_farm_openemr/pieces" ]]; then
    cp -a "$FIXTURE_DIR/extra/git/demo_farm_openemr/pieces/." "$FAKE_GITDEMOFARM/pieces/"
fi

# Overlay the real demo data SQL files from $REPO_ROOT/pieces/ on top.
# Phase 1 dry-run fixtures carry empty marker files for the SQL (the
# mariadb load is wrapped + skipped, so only the `[ -f ... ]` gate
# matters). For Phase 2 live execution the actual file content is
# needed -- without it the mariadb-dump|DROP|mariadb-load cycle wipes
# the OpenEMR schema installed by InstallerAuto and replaces it with
# nothing, leaving an empty database.
if [[ -d "$REPO_ROOT/pieces" ]]; then
    cp -a "$REPO_ROOT/pieces/." "$FAKE_GITDEMOFARM/pieces/"
fi

echo "--- start mariadb ---"
docker network create "$NETWORK" >/dev/null
docker run --detach --name "$MARIADB" \
    --network "$NETWORK" \
    --env "MYSQL_ROOT_PASSWORD=hey" \
    --ulimit nofile=65536:65536 \
    mariadb:10.6 \
    --max-connections=450 \
    --character-set-server=utf8mb4 \
    >/dev/null

# Wait for mariadb to accept connections. Tight inner sleep, generous
# outer bound -- cold start is usually 5-10 sec, slow CI runners up to 30.
mariadb_ready=0
for _ in $(seq 1 60); do
    if docker exec "$MARIADB" mariadb -uroot -phey -e "SELECT 1" >/dev/null 2>&1; then
        mariadb_ready=1
        break
    fi
    sleep 1
done
if [[ $mariadb_ready -ne 1 ]]; then
    echo "FAIL: mariadb never came up; container logs:" >&2
    docker logs "$MARIADB" 2>&1 | tail -50 >&2
    exit 1
fi

echo "--- start openemr container + run demo_build.sh ---"
# Run detached so we can poll the marker. The script's tail -F at the
# end keeps the container alive forever in production; we stop the
# container ourselves once the completion marker fires.
docker run --detach --name "$OPENEMR" \
    --network "$NETWORK" \
    --env "DOCKERDEMO=$DOCKERDEMO" \
    --env "DOCKERMYSQLHOST=$MARIADB" \
    --env "DOCKERNUMBERDEMOS=${DOCKERNUMBERDEMOS:-1}" \
    --env "OPENEMR_DOCKER_ENV_TAG=demo-farm" \
    --env "THROTTLE_DOWN_WAIT_MILLISECONDS=700" \
    --env "THROTTLE_DOWN_DIE_MILLISECONDS=10000" \
    --env "ACTION_LOG=/var/log/action-log.txt" \
    -v "$FAKE_GITDEMOFARM:/home/openemr/git/demo_farm_openemr:ro" \
    "$IMAGE" \
    bash -c "bash /home/openemr/git/demo_farm_openemr/demo_build.sh ${EXTRA_ARGS}" \
    >/dev/null

# Poll the script's own log for the completion marker. demo_build.sh
# writes "Demo install script is complete" to $LOG (= $WEB/log/logSetup.txt
# = /var/www/localhost/htdocs/log/logSetup.txt) AFTER the loop and the
# apache start, just before the hold-open tail -F.
echo "--- wait for completion marker (timeout: ${TIMEOUT_SECONDS}s) ---"
SETUP_LOG="/var/www/localhost/htdocs/log/logSetup.txt"
completed=0
deadline=$(( $(date +%s) + TIMEOUT_SECONDS ))
while [[ $(date +%s) -lt $deadline ]]; do
    if docker exec "$OPENEMR" grep -q "Demo install script is complete" "$SETUP_LOG" 2>/dev/null; then
        completed=1
        break
    fi
    # If the container died before the marker, no point polling further.
    if ! docker inspect -f '{{.State.Running}}' "$OPENEMR" 2>/dev/null | grep -q true; then
        echo "FAIL: openemr container exited before completion marker" >&2
        echo "  container logs (last 80):" >&2
        docker logs "$OPENEMR" 2>&1 | tail -80 | sed 's/^/    | /' >&2
        echo "  setup log (last 80):" >&2
        docker exec "$OPENEMR" tail -n 80 "$SETUP_LOG" 2>/dev/null | sed 's/^/    | /' >&2 || true
        exit 1
    fi
    sleep 5
done

if [[ $completed -ne 1 ]]; then
    echo "FAIL: completion marker not seen within ${TIMEOUT_SECONDS}s" >&2
    echo "  setup log (last 80):" >&2
    docker exec "$OPENEMR" tail -n 80 "$SETUP_LOG" 2>/dev/null | sed 's/^/    | /' >&2 || true
    exit 1
fi

echo "    ok: completion marker seen"

echo "--- mariadb state check ---"
# Assert the fixture's primary database exists. For multi-demo we also
# check the subdemo schemas. demo_build.sh creates one schema per loop
# iteration named $DOCKERDEMO (or ${DOCKERDEMOORIGINAL}_${demo} for subs).
expected_dbs=("$DOCKERDEMO")
if [[ "${DOCKERNUMBERDEMOS}" =~ ^[2-9]$|^10$ ]]; then
    for sub in a b c d e f g h i; do
        # demosGo for DOCKERNUMBERDEMOS=N covers ("empty" "a"..letter[N-2])
        # — quick heuristic: include subs up to N-1.
        idx=$(printf '%s' "abcdefghi" | head -c $((DOCKERNUMBERDEMOS - 1)) | tr -d '\n')
        if [[ "$idx" == *"$sub"* ]]; then
            expected_dbs+=("${DOCKERDEMO}_${sub}")
        fi
    done
fi
db_list="$(docker exec "$MARIADB" mariadb -uroot -phey -B -N -e 'SHOW DATABASES')"
for db in "${expected_dbs[@]}"; do
    if ! grep -qFx "$db" <<<"$db_list"; then
        echo "FAIL: expected database '$db' not found in mariadb" >&2
        echo "  databases present:" >&2
        # shellcheck disable=SC2001  # consistent sed idiom across this file's failure paths
        echo "$db_list" | sed 's/^/    | /' >&2
        exit 1
    fi
    # Sanity check: OpenEMR's install always creates the `globals` table.
    if ! docker exec "$MARIADB" mariadb -uroot -phey -B -N -e "USE \`$db\`; SHOW TABLES LIKE 'globals';" 2>/dev/null | grep -qx globals; then
        echo "FAIL: database '$db' has no 'globals' table -- install likely failed" >&2
        echo "  setup log (last 80):" >&2
        docker exec "$OPENEMR" tail -n 80 "$SETUP_LOG" 2>/dev/null | sed 's/^/    | /' >&2 || true
        exit 1
    fi
done
echo "    ok: ${#expected_dbs[@]} database(s) present with globals table"

echo "--- capture + normalize live action log ---"
docker cp "$OPENEMR:/var/log/action-log.txt" "$WORK/live-action-log.raw.txt"
normalize_live_log "$WORK/live-action-log.raw.txt" "$WORK/live-action-log.txt"

echo "--- diff vs golden ---"
expected="$FIXTURE_DIR/expected/live-action-log.txt"
if [[ "$UPDATE_GOLDENS" = "1" ]]; then
    mkdir -p "$(dirname "$expected")"
    cp "$WORK/live-action-log.txt" "$expected"
    echo "    UPDATED: $expected"
    exit 0
fi
if [[ ! -f "$expected" ]]; then
    echo "FAIL: missing golden $expected" >&2
    echo "  hint: run with UPDATE_GOLDENS=1 to seed it" >&2
    exit 1
fi
if ! diff -u "$expected" "$WORK/live-action-log.txt" >"$WORK/diff.out" 2>&1; then
    echo "FAIL: live action log differs from golden" >&2
    sed 's/^/    | /' "$WORK/diff.out" >&2
    exit 1
fi
echo "    ok: live action log matches golden"

echo "=== PASS: $SCENARIO ==="
