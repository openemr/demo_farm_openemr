#!/usr/bin/env bash
#
# derive.sh -- reconcile demo_farm_openemr's ip_map_branch.txt +
# docker/scripts/demoLibrary.source against upstream openemr/openemr state.
#
# usage: derive.sh [--current-dir <path>] [--upstream-base <url>] [--dry-run|--write]
#
#   --current-dir   directory containing current ip_map_branch.txt +
#                   docker/scripts/demoLibrary.source
#                   (default: cwd / git repo root)
#   --upstream-base URL prefix for fetching openemr/openemr files. The script
#                   appends per-input paths like /master/.github/release-targets.yml,
#                   /<branch>/docker/release/Dockerfile, etc.
#                   (default: https://raw.githubusercontent.com/openemr/openemr)
#                   Fixture tests override this to point at a local fixture dir
#                   (e.g. file:///path/to/fixtures/basic/upstream).
#   --dry-run       (default) print diffs to stdout + step summary; exit 0 on
#                   no-diff, exit 0 with diff content on diff, exit non-zero on
#                   validation failure.
#   --write         write the new ip_map_branch.txt + demoLibrary.source in
#                   place. Used by PR #2 scope (not exercised in PR #1).
#
# Section ownership (per G6 design):
#
#   Production (five + aliases)        -- fixed cluster IDs; branch_tag from
#                                         latest holder's openemr_version_ref;
#                                         flex from latest holder's Dockerfile
#   Up-for-grabs (four + aliases)      -- fixed cluster IDs; row PRESERVED
#                                         (community claims as overrides);
#                                         flex from master's Dockerfile always
#   Master demos                       -- sticky cluster IDs (new from parked);
#                                         branch master; flex master Alpine +
#                                         cluster's assigned PHP
#   Release demos                      -- sticky cluster IDs (new from parked);
#                                         branch = rel branch name; flex from
#                                         that rel branch's Dockerfile
#   Parked                             -- overflow bench; rows PRESERVED
#   Miscellaneous                      -- hand-curated; rows PRESERVED
#
set -euo pipefail

#------------------------------------------------------------------------------
# arg parsing + defaults
#------------------------------------------------------------------------------

UPSTREAM_BASE="https://raw.githubusercontent.com/openemr/openemr"
CURRENT_DIR=""
MODE="dry-run"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --current-dir)
            CURRENT_DIR="$2"
            shift 2
            ;;
        --upstream-base)
            UPSTREAM_BASE="$2"
            shift 2
            ;;
        --dry-run)
            MODE="dry-run"
            shift
            ;;
        --write)
            MODE="write"
            shift
            ;;
        -h|--help)
            sed -n '1,40p' "$0"
            exit 0
            ;;
        *)
            echo "ERROR: unknown arg: $1" >&2
            exit 2
            ;;
    esac
done

if [[ -z "$CURRENT_DIR" ]]; then
    if git rev-parse --show-toplevel >/dev/null 2>&1; then
        CURRENT_DIR="$(git rev-parse --show-toplevel)"
    else
        CURRENT_DIR="$PWD"
    fi
fi

CURRENT_IP_MAP="$CURRENT_DIR/ip_map_branch.txt"
CURRENT_DEMOLIB="$CURRENT_DIR/docker/scripts/demoLibrary.source"

for f in "$CURRENT_IP_MAP" "$CURRENT_DEMOLIB"; do
    [[ -f "$f" ]] || { echo "ERROR: required file missing: $f" >&2; exit 2; }
done

command -v yq >/dev/null   || { echo "ERROR: yq not on PATH" >&2; exit 2; }
command -v curl >/dev/null || { echo "ERROR: curl not on PATH" >&2; exit 2; }
command -v awk >/dev/null  || { echo "ERROR: awk not on PATH" >&2; exit 2; }

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

#------------------------------------------------------------------------------
# fail-loud helper
#------------------------------------------------------------------------------

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

#------------------------------------------------------------------------------
# upstream fetch (URL or local fixture)
#------------------------------------------------------------------------------

# fetch_upstream <ref> <path-under-repo> <dest-file>
# UPSTREAM_BASE may be:
#   - http(s)://...   -> appended with /<ref>/<path>, downloaded via curl
#   - file://<dir>    -> resolved as <dir>/<ref>/<path> from local fixture tree
fetch_upstream() {
    local ref="$1" path="$2" dest="$3"
    if [[ "$UPSTREAM_BASE" == file://* ]]; then
        local root="${UPSTREAM_BASE#file://}"
        local src="$root/$ref/$path"
        [[ -f "$src" ]] || fail "fixture file missing: $src"
        cp "$src" "$dest"
    else
        local url="$UPSTREAM_BASE/$ref/$path"
        if ! curl -fsSL "$url" -o "$dest"; then
            fail "failed to fetch $url"
        fi
    fi
}

#------------------------------------------------------------------------------
# upstream input parsers
#------------------------------------------------------------------------------

# Side-effect: writes to globals RELEASE_TARGETS_FILE,
# RT_LATEST_BRANCH, RT_LATEST_VERSION_REF, RT_REL_BRANCHES (array of distinct
# rel-* branches with at least one releasable row, sorted by version desc),
# RT_BRANCH_VERSION_REF (associative: rel-branch -> version_ref to use, picking
# the "primary" non-unreleased row for that branch).
fetch_release_targets() {
    RELEASE_TARGETS_FILE="$WORKDIR/release-targets.yml"
    fetch_upstream master ".github/release-targets.yml" "$RELEASE_TARGETS_FILE"

    # 1) find rows where 'latest' appears in docker_tags AND unreleased is not true
    #    (docker_tags is a comma-separated string, e.g. "8.0.0,8.0.0.3,latest")
    local latest_rows
    latest_rows="$(yq -r '[.[] | select(.unreleased != true) | select(.docker_tags | split(",") | .[] == "latest")] | length' "$RELEASE_TARGETS_FILE")"
    [[ "$latest_rows" == "1" ]] || \
        fail "release-targets.yml must have exactly one non-unreleased row tagged 'latest' (found $latest_rows)"

    RT_LATEST_BRANCH="$(yq -r '.[] | select(.unreleased != true) | select(.docker_tags | split(",") | .[] == "latest") | .branch' "$RELEASE_TARGETS_FILE")"
    RT_LATEST_VERSION_REF="$(yq -r '.[] | select(.unreleased != true) | select(.docker_tags | split(",") | .[] == "latest") | .openemr_version_ref' "$RELEASE_TARGETS_FILE")"

    [[ -n "$RT_LATEST_BRANCH" && -n "$RT_LATEST_VERSION_REF" ]] || \
        fail "could not extract latest holder's branch/version_ref from release-targets.yml"

    # 2) collect rel-* branches (excluding master, excluding unreleased-only rows).
    #    For each rel branch, pick the version_ref of its "primary" row -- defined
    #    as the row whose openemr_version_ref equals the branch name (the dev
    #    pointer), falling back to its first non-unreleased row.
    declare -gA RT_BRANCH_VERSION_REF=()
    RT_REL_BRANCHES=()

    local branches
    branches="$(yq -r '
        [.[] | select(.unreleased != true) | .branch] | unique | .[]
    ' "$RELEASE_TARGETS_FILE")"

    local b
    while IFS= read -r b; do
        [[ -z "$b" || "$b" == "master" ]] && continue
        local vref
        # prefer the row whose version_ref == branch name (the "dev pointer")
        vref="$(BRANCH="$b" yq -r '[.[] | select(.unreleased != true) | select(.branch == strenv(BRANCH)) | select(.openemr_version_ref == strenv(BRANCH))] | .[0].openemr_version_ref // ""' "$RELEASE_TARGETS_FILE")"
        if [[ -z "$vref" || "$vref" == "null" ]]; then
            # fall back to the first non-unreleased row's version_ref
            vref="$(BRANCH="$b" yq -r '[.[] | select(.unreleased != true) | select(.branch == strenv(BRANCH))] | .[0].openemr_version_ref // ""' "$RELEASE_TARGETS_FILE")"
        fi
        [[ -n "$vref" && "$vref" != "null" ]] || fail "no version_ref resolvable for rel branch $b"
        RT_BRANCH_VERSION_REF["$b"]="$vref"
        RT_REL_BRANCHES+=("$b")
    done <<< "$branches"

    # sort rel branches ascending by version (rel-704 < rel-800 < rel-810).
    # Use the numeric component (rel-704 -> 704).
    local sorted
    sorted="$(printf '%s\n' "${RT_REL_BRANCHES[@]}" | awk -F- '{print $2"\t"$0}' | sort -n | cut -f2-)"
    RT_REL_BRANCHES=()
    while IFS= read -r b; do
        [[ -n "$b" ]] && RT_REL_BRANCHES+=("$b")
    done <<< "$sorted"
}

# fetch_dockerfile_args <branch>
# Sets globals DF_ALPINE + DF_PHP for that branch. Fail loud on parse failure.
fetch_dockerfile_args() {
    local branch="$1"
    local dest="$WORKDIR/Dockerfile.$branch"
    fetch_upstream "$branch" "docker/release/Dockerfile" "$dest"

    DF_ALPINE="$(awk '
        /^ARG[[:space:]]+ALPINE_VERSION=/ {
            sub(/^ARG[[:space:]]+ALPINE_VERSION=/, "")
            print
            exit
        }' "$dest")"
    DF_PHP="$(awk '
        /^ARG[[:space:]]+PHP_VERSION=/ {
            sub(/^ARG[[:space:]]+PHP_VERSION=/, "")
            print
            exit
        }' "$dest")"

    [[ -n "$DF_ALPINE" ]] || fail "could not parse ALPINE_VERSION ARG from $branch's docker/release/Dockerfile"
    [[ -n "$DF_PHP"    ]] || fail "could not parse PHP_VERSION ARG from $branch's docker/release/Dockerfile"
}

# list_upstream_dir <ref> <path-under-repo>
# Print the names of entries (one per line) in <ref>:<path>.
# Local fixture mode (file://): lists the directory directly.
# URL mode: calls the GitHub contents API derived from UPSTREAM_BASE.
list_upstream_dir() {
    local ref="$1" path="$2"
    if [[ "$UPSTREAM_BASE" == file://* ]]; then
        local root="${UPSTREAM_BASE#file://}"
        local dir="$root/$ref/$path"
        [[ -d "$dir" ]] || fail "fixture directory missing: $dir"
        # ls -1 keeps it simple; exclude . and ..
        (cd "$dir" && find . -mindepth 1 -maxdepth 1 -printf '%f\n')
    else
        # Derive API URL from raw URL base.
        # UPSTREAM_BASE = https://raw.githubusercontent.com/<owner>/<repo>
        # -> https://api.github.com/repos/<owner>/<repo>/contents/<path>?ref=<ref>
        local owner_repo
        owner_repo="${UPSTREAM_BASE#https://raw.githubusercontent.com/}"
        owner_repo="${owner_repo#http://raw.githubusercontent.com/}"
        if [[ "$owner_repo" == "$UPSTREAM_BASE" ]]; then
            fail "list_upstream_dir: cannot derive GitHub API URL from non-raw.githubusercontent.com UPSTREAM_BASE: $UPSTREAM_BASE"
        fi
        local api_url="https://api.github.com/repos/${owner_repo}/contents/${path}?ref=${ref}"
        local auth_args=()
        if [[ -n "${GITHUB_TOKEN:-}" ]]; then
            auth_args=(-H "Authorization: Bearer $GITHUB_TOKEN")
        fi
        local body
        if ! body="$(curl -fsSL "${auth_args[@]}" \
                        -H "Accept: application/vnd.github+json" \
                        "$api_url")"; then
            fail "failed to fetch directory listing from $api_url"
        fi
        # GitHub returns a JSON array of {name, type, ...} entries.
        # Use yq's JSON mode to extract names.
        printf '%s\n' "$body" | yq -r -p=json '.[] | .name'
    fi
}

# fetch_supported_php_versions
# Sets global PHP_MATRIX (space-separated, ascending).
#
# Source of truth: the set of `ci/apache_*` directories on openemr/openemr
# master. Each directory follows the naming convention
# `apache_<PHP-no-dot>_<MARIADB-no-dot>[_variant]` (e.g. `apache_82_118`
# = PHP 8.2 + MariaDB 11.8). The unique PHP prefixes across all
# `ci/apache_*` directories are the canonical supported PHP versions.
fetch_supported_php_versions() {
    local entries
    entries="$(list_upstream_dir master "ci")"
    [[ -n "$entries" ]] || \
        fail "no entries found under ci/ on upstream master (cannot derive supported PHP versions)"

    # Filter to apache_<PHP>_... entries; extract the 2-digit PHP prefix;
    # uniq + sort ascending; convert NN -> N.N.
    local php_dotted
    php_dotted="$(printf '%s\n' "$entries" \
        | awk -F_ '
            /^apache_[0-9][0-9]_/ {
                if (length($2) == 2) {
                    print substr($2, 1, 1) "." substr($2, 2, 1)
                }
            }' \
        | sort -u -V)"

    [[ -n "$php_dotted" ]] || \
        fail "no ci/apache_<PHP>_* directories found on upstream master (cannot derive supported PHP versions)"

    PHP_MATRIX="$(printf '%s\n' "$php_dotted" | tr '\n' ' ' | sed 's/ $//')"
}

#------------------------------------------------------------------------------
# current-state parser: ip_map_branch.txt
#------------------------------------------------------------------------------
#
# Builds globals (associative arrays keyed by cluster name -- the bare token
# from the docker_number column, e.g. "five", "five_a", "two"):
#
#   CUR_SECTION       -- "production" | "up-for-grabs" | "master" | "release"
#                        | "parked" | "misc"
#   CUR_BRANCH        -- branch column
#   CUR_REPO          -- openemr_repo column
#   CUR_ROW           -- the full TSV row (preserved verbatim for sections the
#                        bot doesn't rewrite)
#   CUR_PHP           -- master-demo clusters only: the PHP version assigned to
#                        that cluster (parsed from description "PHP X.Y")
#   CUR_ALIASES       -- comma-separated list of alias clusters (the _a, _b
#                        siblings of this base cluster), or empty
#
# Also builds CUR_ORDER (array of clusters in file order, base + aliases
# together) and CUR_CLUSTERS_BY_SECTION[<section>] = space-separated list of
# base clusters in that section (in file order).

declare -gA CUR_SECTION=() CUR_BRANCH=() CUR_REPO=() CUR_ROW=() CUR_PHP=() CUR_ALIASES=()
declare -ga CUR_ORDER=()
declare -gA CUR_CLUSTERS_BY_SECTION=()
HEADER_LINE=""

read_current_ip_map() {
    local section="" line cluster

    while IFS= read -r line || [[ -n "$line" ]]; do
        # blank
        [[ -z "${line//[[:space:]]/}" ]] && continue
        # section header comment
        if [[ "$line" =~ ^#[[:space:]]*===[[:space:]]*(.+)[[:space:]]*===[[:space:]]*$ ]]; then
            local raw="${BASH_REMATCH[1]}"
            raw="${raw#"${raw%%[![:space:]]*}"}"; raw="${raw%"${raw##*[![:space:]]}"}"
            case "$raw" in
                Production|production|PRODUCTION)          section="production" ;;
                "UP FOR GRABS"|"Up for grabs"|"up-for-grabs") section="up-for-grabs" ;;
                "Master demos"*|"MASTER DEMOS"*)            section="master" ;;
                "Release demos"*|"RELEASE DEMOS"*)          section="release" ;;
                Parked|parked|PARKED)                       section="parked" ;;
                Miscellaneous|miscellaneous|MISC|misc|"Misc")
                                                            section="misc" ;;
                *)
                    # unknown section header -- treat as misc for safety
                    section="misc"
                    echo "WARNING: unknown section header in ip_map_branch.txt: $raw" >&2
                    ;;
            esac
            continue
        fi
        # other comment
        [[ "$line" =~ ^#  ]] && continue
        # header line (first non-comment, non-blank)
        if [[ -z "$HEADER_LINE" && "$line" == docker_number* ]]; then
            HEADER_LINE="$line"
            continue
        fi

        # data row -- TSV: first column is docker_number (cluster)
        cluster="${line%%	*}"
        [[ -z "$cluster" ]] && continue

        CUR_SECTION["$cluster"]="$section"
        CUR_ROW["$cluster"]="$line"
        # split columns
        IFS=$'\t' read -ra cols <<< "$line"
        CUR_REPO["$cluster"]="${cols[1]:-}"
        CUR_BRANCH["$cluster"]="${cols[2]:-}"

        CUR_ORDER+=("$cluster")
        CUR_CLUSTERS_BY_SECTION["$section"]="${CUR_CLUSTERS_BY_SECTION["$section"]:-} $cluster"

        # PHP version parse (master demos only) -- from description column (last)
        if [[ "$section" == "master" ]]; then
            local desc="${cols[17]:-}"
            if [[ "$desc" =~ PHP[[:space:]]+([0-9]+\.[0-9]+) ]]; then
                CUR_PHP["$cluster"]="${BASH_REMATCH[1]}"
            fi
        fi
    done < "$CURRENT_IP_MAP"

    [[ -n "$HEADER_LINE" ]] || fail "could not find TSV header in $CURRENT_IP_MAP"

    # Build alias map: for each base cluster X, list its _a / _b siblings.
    local c base
    declare -gA seen_base=()
    for c in "${CUR_ORDER[@]}"; do
        case "$c" in
            *_a|*_b) ;;  # aliases handled via their base
            *)
                base="$c"
                seen_base["$base"]=1
                local aliases=""
                local cand
                for cand in "${CUR_ORDER[@]}"; do
                    if [[ "$cand" == "${base}_a" || "$cand" == "${base}_b" ]]; then
                        aliases+="${aliases:+,}$cand"
                    fi
                done
                CUR_ALIASES["$base"]="$aliases"
                ;;
        esac
    done
}

#------------------------------------------------------------------------------
# current-state parser: demoLibrary.source startDemoWrapper case-blocks
#------------------------------------------------------------------------------
#
# Builds globals:
#   CUR_DEMOLIB_IMAGE[<cluster>] = flex image string
#   CUR_DEMOLIB_COUNT[<cluster>] = count integer
#   CUR_DEMOLIB_ORDER             = clusters in case-block order
#   CUR_DEMOLIB_DEFAULT_IMAGE     = the *) default image
#   CUR_DEMOLIB_DEFAULT_COUNT     = the *) default count

declare -gA CUR_DEMOLIB_IMAGE=() CUR_DEMOLIB_COUNT=()
declare -ga CUR_DEMOLIB_ORDER=()
CUR_DEMOLIB_DEFAULT_IMAGE=""
CUR_DEMOLIB_DEFAULT_COUNT=""

read_current_demolib() {
    local in_wrapper=0 in_case=0 current_cluster=""
    local image="" count=""
    local line

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ $in_wrapper -eq 0 ]]; then
            [[ "$line" =~ ^startDemoWrapper\(\) ]] && in_wrapper=1
            continue
        fi
        # end of function
        if [[ $in_wrapper -eq 1 && "$line" =~ ^startDemo[[:space:]] ]]; then
            break
        fi
        if [[ $in_case -eq 0 && "$line" =~ ^[[:space:]]+case[[:space:]]+\"\$1\" ]]; then
            in_case=1
            continue
        fi
        if [[ $in_case -eq 1 ]]; then
            # case label: e.g. "        one)" or "        *)"
            if [[ "$line" =~ ^[[:space:]]+([A-Za-z_][A-Za-z0-9_]*|\*)\)[[:space:]]*$ ]]; then
                current_cluster="${BASH_REMATCH[1]}"
                image=""
                count=""
                continue
            fi
            if [[ -n "$current_cluster" && "$line" =~ image=\"([^\"]+)\" ]]; then
                image="${BASH_REMATCH[1]}"
            fi
            if [[ -n "$current_cluster" && "$line" =~ count=([0-9]+) ]]; then
                count="${BASH_REMATCH[1]}"
            fi
            if [[ -n "$current_cluster" && "$line" =~ ^[[:space:]]+\;\;[[:space:]]*$ ]]; then
                if [[ "$current_cluster" == "*" ]]; then
                    CUR_DEMOLIB_DEFAULT_IMAGE="$image"
                    CUR_DEMOLIB_DEFAULT_COUNT="$count"
                else
                    CUR_DEMOLIB_IMAGE["$current_cluster"]="$image"
                    CUR_DEMOLIB_COUNT["$current_cluster"]="$count"
                    CUR_DEMOLIB_ORDER+=("$current_cluster")
                fi
                current_cluster=""
            fi
            if [[ "$line" =~ ^[[:space:]]+esac[[:space:]]*$ ]]; then
                in_case=0
            fi
        fi
    done < "$CURRENT_DEMOLIB"

    [[ -n "$CUR_DEMOLIB_DEFAULT_IMAGE" ]] || \
        fail "could not parse demoLibrary.source startDemoWrapper (*) default image"
}

#------------------------------------------------------------------------------
# desired-state computation
#------------------------------------------------------------------------------
#
# DES_ROWS[<cluster>]     -- full TSV row for that cluster (in section order)
# DES_IMAGE[<cluster>]    -- flex image
# DES_COUNT[<cluster>]    -- count
# DES_SECTION[<cluster>]  -- section bucket
# DES_ORDER_<section>     -- per-section ordered cluster list (base + aliases)

declare -gA DES_ROWS=() DES_IMAGE=() DES_COUNT=() DES_SECTION=()
DES_ORDER_PRODUCTION=()
DES_ORDER_UPFORGRABS=()
DES_ORDER_MASTER=()
DES_ORDER_RELEASE=()
DES_ORDER_PARKED=()
DES_ORDER_MISC=()

# Replace columns in a preserved row. Modifies the TSV row's:
#   col 3 (branch) and col 13 (branch_tag), leaving everything else intact.
#
# rewrite_row <orig-row> <new-branch> <new-branch-tag-mode>
#   new-branch-tag-mode: literal "tag", "branch", or specific tag value
#                       (passed through as-is)
rewrite_row_branch_and_tag() {
    local orig="$1" new_branch="$2" new_tag_field="$3"
    awk -v OFS=$'\t' -v nb="$new_branch" -v nt="$new_tag_field" '
        BEGIN { FS="\t" }
        {
            $3 = nb
            $13 = nt
            print
        }
    ' <<< "$orig"
}

# Replace just the description (col 18) on a row.
rewrite_row_description() {
    local orig="$1" new_desc="$2"
    awk -v OFS=$'\t' -v nd="$new_desc" '
        BEGIN { FS="\t" }
        {
            $18 = nd
            print
        }
    ' <<< "$orig"
}

# Compose a fresh master-demo row for a given cluster + PHP + Alpine.
# Cluster's row template comes from the current state if known, else from a
# standard template.
synth_master_row() {
    local cluster="$1" php="$2" alpine="$3"
    local with_data=0
    [[ "$cluster" == *_a ]] && with_data=1

    local base_cluster="${cluster%_a}"
    local subdomain="$base_cluster.openemr.io"
    [[ "$cluster" == *_a ]] && subdomain="$base_cluster.openemr.io/a"

    # Description casing convention from current file: non-alias rows use
    # "on Alpine"; alias (_a) rows use "On Alpine". Preserved verbatim.
    local desc
    if [[ $with_data -eq 1 ]]; then
        desc="Public OpenEMR Development Demo With Demo Data On Alpine ${alpine} (with PHP ${php})"
    else
        desc="Public OpenEMR Development Demo on Alpine ${alpine} (with PHP ${php})"
    fi

    # Reuse the original row if present (preserves non-derived columns), else
    # build a fresh template matching the schema.
    if [[ -n "${CUR_ROW[$cluster]:-}" ]]; then
        local row="${CUR_ROW[$cluster]}"
        # Rewrite branch (master), branch_tag (branch), description.
        row="$(rewrite_row_branch_and_tag "$row" "master" "branch")"
        row="$(rewrite_row_description "$row" "$desc")"
        printf '%s\n' "$row"
    else
        # New cluster (pulled from parked) -- preserve parked row's
        # non-derived fields (capsule, sql data, etc.) but rewrite the
        # cluster-name-derived columns.
        local row="${CUR_ROW[$cluster]:-}"
        if [[ -z "$row" ]]; then
            fail "synth_master_row: no template row for cluster $cluster"
        fi
        printf '%s\n' "$row"
    fi
}

# Compose a fresh release-demo row for a cluster + rel branch + alpine + php.
synth_release_row() {
    local cluster="$1" rel_branch="$2" alpine="$3" php="$4"
    local base_cluster="${cluster%_a}"
    local with_data=0
    [[ "$cluster" == *_a ]] && with_data=1

    # Derive a human version from the rel branch (rel-810 -> 8.1.0).
    local relnum="${rel_branch#rel-}"
    local human_ver
    if [[ ${#relnum} -eq 3 ]]; then
        human_ver="${relnum:0:1}.${relnum:1:1}.${relnum:2:1}"
    else
        human_ver="$rel_branch"
    fi

    local desc
    if [[ $with_data -eq 1 ]]; then
        desc="Public OpenEMR ${human_ver} Development Demo With Demo Data On Alpine ${alpine} (with PHP ${php})"
    else
        desc="Public OpenEMR ${human_ver} Development Demo on Alpine ${alpine} (with PHP ${php})"
    fi

    if [[ -n "${CUR_ROW[$cluster]:-}" ]]; then
        local row="${CUR_ROW[$cluster]}"
        row="$(rewrite_row_branch_and_tag "$row" "$rel_branch" "branch")"
        row="$(rewrite_row_description "$row" "$desc")"
        printf '%s\n' "$row"
    else
        fail "synth_release_row: no template row for cluster $cluster"
    fi
}

# Pull next available parked base-cluster (and its aliases). Returns the base
# cluster name; updates DES_SECTION for both base + aliases to mark them as
# claimed (so they don't re-appear in parked). Fails loud if bench is empty.
take_from_parked() {
    local needed_for="$1"
    local c
    for c in ${CUR_CLUSTERS_BY_SECTION["parked"]:-}; do
        case "$c" in
            *_a|*_b) continue ;;  # only base clusters
        esac
        # not yet claimed?
        if [[ -z "${DES_SECTION[$c]:-}" || "${DES_SECTION[$c]}" == "parked" ]]; then
            DES_SECTION["$c"]="claimed"  # mark
            local alias
            IFS=',' read -ra aliases <<< "${CUR_ALIASES[$c]:-}"
            for alias in "${aliases[@]}"; do
                [[ -n "$alias" ]] && DES_SECTION["$alias"]="claimed"
            done
            echo "$c"
            return 0
        fi
    done
    fail "parked bench empty when a new cluster is needed for: $needed_for. Add a parked cluster first (preserves cluster->subdomain stability)."
}

compute_desired_state() {
    # --- Production: fixed cluster IDs from current file's production section
    local prod_clusters="${CUR_CLUSTERS_BY_SECTION["production"]:-}"
    [[ -n "$prod_clusters" ]] || fail "current ip_map_branch.txt has no Production section clusters"

    # Latest holder dictates production branch_tag + flex image
    fetch_dockerfile_args "$RT_LATEST_BRANCH"
    local prod_alpine="$DF_ALPINE"
    local prod_php="$DF_PHP"
    local prod_tag="$RT_LATEST_VERSION_REF"

    local c
    for c in $prod_clusters; do
        DES_SECTION["$c"]="production"
        DES_ORDER_PRODUCTION+=("$c")
        DES_IMAGE["$c"]="openemr/openemr:flex-${prod_alpine}-php-${prod_php}"
        # production rows: rewrite branch_tag to literal version ref;
        # branch column = the version ref (current file follows that convention,
        # e.g. "v8_0_0_3" in column 3); branch_tag column = "tag".
        local row="${CUR_ROW[$c]}"
        row="$(rewrite_row_branch_and_tag "$row" "$prod_tag" "tag")"
        DES_ROWS["$c"]="$row"
    done
    # count = number of production base+alias clusters (3 today)
    local prod_count="${#DES_ORDER_PRODUCTION[@]}"
    for c in "${DES_ORDER_PRODUCTION[@]}"; do DES_COUNT["$c"]="$prod_count"; done

    # --- Up-for-grabs: rows preserved (community claims); flex from master
    fetch_dockerfile_args master
    local master_alpine="$DF_ALPINE"
    local master_php_dockerfile="$DF_PHP"
    local upgrab_image="openemr/openemr:flex-${master_alpine}-php-${master_php_dockerfile}"

    local upgrab_clusters="${CUR_CLUSTERS_BY_SECTION["up-for-grabs"]:-}"
    [[ -n "$upgrab_clusters" ]] || fail "current ip_map_branch.txt has no Up-for-grabs section clusters"

    for c in $upgrab_clusters; do
        DES_SECTION["$c"]="up-for-grabs"
        DES_ORDER_UPFORGRABS+=("$c")
        DES_ROWS["$c"]="${CUR_ROW[$c]}"   # PRESERVED verbatim
        DES_IMAGE["$c"]="$upgrab_image"
    done
    local upgrab_count="${#DES_ORDER_UPFORGRABS[@]}"
    for c in "${DES_ORDER_UPFORGRABS[@]}"; do DES_COUNT["$c"]="$upgrab_count"; done

    # --- Master demos: one base cluster per supported PHP
    # Sticky mapping: previously-assigned cluster keeps its PHP; new PHP pulls
    # from parked; retired PHP releases its cluster back to parked.
    declare -A php_to_cluster=()
    # discover current master-demo PHP assignments
    local mc
    for mc in ${CUR_CLUSTERS_BY_SECTION["master"]:-}; do
        case "$mc" in
            *_a|*_b) continue ;;
        esac
        if [[ -n "${CUR_PHP[$mc]:-}" ]]; then
            php_to_cluster["${CUR_PHP[$mc]}"]="$mc"
        fi
    done

    # iterate supported PHP versions in ascending order
    local php
    declare -A used_master_clusters=()
    for php in $PHP_MATRIX; do
        local cluster
        if [[ -n "${php_to_cluster[$php]:-}" ]]; then
            cluster="${php_to_cluster[$php]}"
        else
            cluster="$(take_from_parked "master-demo PHP $php")"
        fi
        used_master_clusters["$cluster"]=1
        DES_SECTION["$cluster"]="master"
        DES_ORDER_MASTER+=("$cluster")
        DES_ROWS["$cluster"]="$(synth_master_row "$cluster" "$php" "$master_alpine")"
        DES_IMAGE["$cluster"]="openemr/openemr:flex-${master_alpine}-php-${php}"
        # aliases
        local alias
        IFS=',' read -ra aliases <<< "${CUR_ALIASES[$cluster]:-}"
        for alias in "${aliases[@]}"; do
            [[ -z "$alias" ]] && continue
            DES_SECTION["$alias"]="master"
            DES_ORDER_MASTER+=("$alias")
            DES_ROWS["$alias"]="$(synth_master_row "$alias" "$php" "$master_alpine")"
        done
    done
    # count for master-demo clusters = base+aliases per cluster.
    # Per spec: counts derive from current per-cluster state; default 2 for new.
    for mc in "${DES_ORDER_MASTER[@]}"; do
        case "$mc" in
            *_a|*_b) continue ;;
        esac
        local n=1
        local alias
        IFS=',' read -ra aliases <<< "${CUR_ALIASES[$mc]:-}"
        for alias in "${aliases[@]}"; do [[ -n "$alias" ]] && n=$((n+1)); done
        # If the cluster was previously master + count was set, prefer that.
        local prev="${CUR_DEMOLIB_COUNT[$mc]:-}"
        if [[ -n "$prev" && "${CUR_SECTION[$mc]:-}" == "master" ]]; then
            DES_COUNT["$mc"]="$prev"
        else
            DES_COUNT["$mc"]="$n"
            [[ "$n" -lt 2 ]] && DES_COUNT["$mc"]=2
        fi
    done

    # Release demos: one cluster per non-latest, non-unreleased rel branch
    declare -A relbranch_to_cluster=()
    local rc
    for rc in ${CUR_CLUSTERS_BY_SECTION["release"]:-}; do
        case "$rc" in
            *_a|*_b) continue ;;
        esac
        local br="${CUR_BRANCH[$rc]:-}"
        [[ -n "$br" ]] && relbranch_to_cluster["$br"]="$rc"
    done

    declare -A used_release_clusters=()
    local rb
    for rb in "${RT_REL_BRANCHES[@]}"; do
        # skip the latest holder -- production already covers it
        [[ "$rb" == "$RT_LATEST_BRANCH" ]] && continue

        local cluster
        if [[ -n "${relbranch_to_cluster[$rb]:-}" ]]; then
            cluster="${relbranch_to_cluster[$rb]}"
        else
            cluster="$(take_from_parked "release-demo $rb")"
        fi
        used_release_clusters["$cluster"]=1
        DES_SECTION["$cluster"]="release"
        DES_ORDER_RELEASE+=("$cluster")
        fetch_dockerfile_args "$rb"
        local rb_alpine="$DF_ALPINE" rb_php="$DF_PHP"
        DES_ROWS["$cluster"]="$(synth_release_row "$cluster" "$rb" "$rb_alpine" "$rb_php")"
        DES_IMAGE["$cluster"]="openemr/openemr:flex-${rb_alpine}-php-${rb_php}"
        # aliases
        local alias
        IFS=',' read -ra aliases <<< "${CUR_ALIASES[$cluster]:-}"
        for alias in "${aliases[@]}"; do
            [[ -z "$alias" ]] && continue
            DES_SECTION["$alias"]="release"
            DES_ORDER_RELEASE+=("$alias")
            DES_ROWS["$alias"]="$(synth_release_row "$alias" "$rb" "$rb_alpine" "$rb_php")"
        done
        # count
        local n=1
        IFS=',' read -ra aliases <<< "${CUR_ALIASES[$cluster]:-}"
        for alias in "${aliases[@]}"; do [[ -n "$alias" ]] && n=$((n+1)); done
        local prev="${CUR_DEMOLIB_COUNT[$cluster]:-}"
        if [[ -n "$prev" && "${CUR_SECTION[$cluster]:-}" == "release" ]]; then
            DES_COUNT["$cluster"]="$prev"
        else
            DES_COUNT["$cluster"]="$n"
            [[ "$n" -lt 2 ]] && DES_COUNT["$cluster"]=2
        fi
    done

    # --- Parked: everything previously in parked, plus retired master/release
    # clusters that didn't get reclaimed above.
    local cand
    for cand in ${CUR_CLUSTERS_BY_SECTION["parked"]:-}; do
        # only add if not claimed elsewhere
        if [[ "${DES_SECTION[$cand]:-claimed}" != "claimed" ]]; then
            continue
        fi
        if [[ "${DES_SECTION[$cand]:-claimed}" == "claimed" && -z "${used_master_clusters[$cand]:-}${used_release_clusters[$cand]:-}" ]]; then
            # was never reclaimed; back into parked
            :
        fi
    done
    # Build parked: include any current-master/release cluster that wasn't
    # re-claimed in this run, plus any current-parked cluster that wasn't
    # claimed for promotion.
    for cand in "${CUR_ORDER[@]}"; do
        # Only base clusters drive parking; aliases follow.
        case "$cand" in
            *_a|*_b) continue ;;
        esac
        local cur_sec="${CUR_SECTION[$cand]}"
        local des_sec="${DES_SECTION[$cand]:-unset}"

        if [[ "$cur_sec" == "parked" && "$des_sec" != "claimed" && "$des_sec" != "master" && "$des_sec" != "release" ]]; then
            # still parked
            DES_SECTION["$cand"]="parked"
            DES_ORDER_PARKED+=("$cand")
            DES_ROWS["$cand"]="${CUR_ROW[$cand]}"
            DES_IMAGE["$cand"]="${CUR_DEMOLIB_IMAGE[$cand]:-$CUR_DEMOLIB_DEFAULT_IMAGE}"
            DES_COUNT["$cand"]="${CUR_DEMOLIB_COUNT[$cand]:-2}"
            local alias
            IFS=',' read -ra aliases <<< "${CUR_ALIASES[$cand]:-}"
            for alias in "${aliases[@]}"; do
                [[ -z "$alias" ]] && continue
                DES_SECTION["$alias"]="parked"
                DES_ORDER_PARKED+=("$alias")
                DES_ROWS["$alias"]="${CUR_ROW[$alias]}"
            done
            continue
        fi

        # Cluster currently in master/release but not picked up this run -> park
        if [[ "$cur_sec" == "master" || "$cur_sec" == "release" ]]; then
            if [[ "$des_sec" != "master" && "$des_sec" != "release" ]]; then
                DES_SECTION["$cand"]="parked"
                DES_ORDER_PARKED+=("$cand")
                # Preserve the row (rewrite description to [parked] to match
                # the parked convention -- per current file's parked rows)
                local row="${CUR_ROW[$cand]}"
                row="$(rewrite_row_description "$row" "[parked]")"
                row="$(rewrite_row_branch_and_tag "$row" "master" "branch")"
                DES_ROWS["$cand"]="$row"
                DES_IMAGE["$cand"]="${CUR_DEMOLIB_IMAGE[$cand]:-$CUR_DEMOLIB_DEFAULT_IMAGE}"
                DES_COUNT["$cand"]="${CUR_DEMOLIB_COUNT[$cand]:-2}"
                local alias
                IFS=',' read -ra aliases <<< "${CUR_ALIASES[$cand]:-}"
                for alias in "${aliases[@]}"; do
                    [[ -z "$alias" ]] && continue
                    DES_SECTION["$alias"]="parked"
                    DES_ORDER_PARKED+=("$alias")
                    local arow="${CUR_ROW[$alias]}"
                    arow="$(rewrite_row_description "$arow" "[parked]")"
                    arow="$(rewrite_row_branch_and_tag "$arow" "master" "branch")"
                    DES_ROWS["$alias"]="$arow"
                done
            fi
        fi
    done

    # --- Misc: preserved verbatim
    local mi
    for mi in ${CUR_CLUSTERS_BY_SECTION["misc"]:-}; do
        DES_SECTION["$mi"]="misc"
        DES_ORDER_MISC+=("$mi")
        DES_ROWS["$mi"]="${CUR_ROW[$mi]}"
        DES_IMAGE["$mi"]="${CUR_DEMOLIB_IMAGE[$mi]:-$CUR_DEMOLIB_DEFAULT_IMAGE}"
        DES_COUNT["$mi"]="${CUR_DEMOLIB_COUNT[$mi]:-2}"
    done
}

#------------------------------------------------------------------------------
# rendering
#------------------------------------------------------------------------------

render_ip_map() {
    local out="$1"
    {
        printf '%s\n' "$HEADER_LINE"
        printf '\n'
        printf '# === Production ===\n'
        local c
        for c in "${DES_ORDER_PRODUCTION[@]}"; do printf '%s\n' "${DES_ROWS[$c]}"; done
        printf '\n'
        printf '# === UP FOR GRABS ===\n'
        for c in "${DES_ORDER_UPFORGRABS[@]}"; do printf '%s\n' "${DES_ROWS[$c]}"; done
        printf '\n'
        printf '# === Master demos (low → high PHP) ===\n'
        for c in "${DES_ORDER_MASTER[@]}"; do printf '%s\n' "${DES_ROWS[$c]}"; done
        printf '\n'
        printf '# === Release demos (low → high version) ===\n'
        for c in "${DES_ORDER_RELEASE[@]}"; do printf '%s\n' "${DES_ROWS[$c]}"; done
        printf '\n'
        printf '# === Parked ===\n'
        for c in "${DES_ORDER_PARKED[@]}"; do printf '%s\n' "${DES_ROWS[$c]}"; done
        if [[ ${#DES_ORDER_MISC[@]} -gt 0 ]]; then
            printf '\n'
            printf '# === Miscellaneous ===\n'
            for c in "${DES_ORDER_MISC[@]}"; do printf '%s\n' "${DES_ROWS[$c]}"; done
        fi
    } > "$out"
}

render_demolib() {
    local out="$1"
    # Compose the new startDemoWrapper body. Cluster order in the case statement
    # matches the existing convention: "Ordered by cluster number for legibility."
    # We render base clusters only (aliases share the base's case via demoLibrary
    # using $1 = base cluster name; alias-level routing happens upstream in the
    # serving layer, not in demoLibrary).
    #
    # Build a single ordered list of base clusters covering every section.
    # Order by the cluster-number ordering used in the current demoLibrary
    # ("Ordered by cluster number for legibility"): start with the existing
    # case-block order, append any newly-introduced clusters at the end.
    local -a all_bases=()
    local seen
    declare -A added=()
    # First, preserve existing case-block order from current demoLibrary
    for seen in "${CUR_DEMOLIB_ORDER[@]}"; do
        # Skip clusters that have been completely removed (not in any desired section)
        if [[ -n "${DES_SECTION[$seen]:-}" ]]; then
            all_bases+=("$seen")
            added["$seen"]=1
        fi
    done
    # Then append any new base clusters that weren't in the original order
    local c
    for c in "${DES_ORDER_PRODUCTION[@]}" "${DES_ORDER_UPFORGRABS[@]}" \
             "${DES_ORDER_MASTER[@]}" "${DES_ORDER_RELEASE[@]}" \
             "${DES_ORDER_PARKED[@]}" "${DES_ORDER_MISC[@]}"; do
        case "$c" in
            *_a|*_b) continue ;;
        esac
        if [[ -z "${added[$c]:-}" ]]; then
            all_bases+=("$c")
            added["$c"]=1
        fi
    done

    # Read original file; emit it as-is up to startDemoWrapper() {, then emit
    # the new case body, then resume at the `startDemo "$1"...` line.
    local in_wrapper=0 emitted_case=0 skipping=0
    local line
    {
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ $in_wrapper -eq 0 ]]; then
                printf '%s\n' "$line"
                [[ "$line" =~ ^startDemoWrapper\(\) ]] && in_wrapper=1
                continue
            fi
            if [[ $emitted_case -eq 0 ]]; then
                # emit the new case body once we hit the local declarations
                if [[ "$line" =~ ^[[:space:]]+local[[:space:]]+image ]]; then
                    printf '%s\n' "$line"
                    continue
                fi
                if [[ "$line" =~ ^[[:space:]]+local[[:space:]]+count ]]; then
                    printf '%s\n' "$line"
                    continue
                fi
                if [[ "$line" =~ ^[[:space:]]+\#.*per-cluster ]] || \
                   [[ "$line" =~ ^[[:space:]]+\#.*case[[:space:]]+block ]] || \
                   [[ "$line" =~ ^[[:space:]]+\#.*Each[[:space:]]+cluster ]] || \
                   [[ "$line" =~ ^[[:space:]]+\#.*Ordered[[:space:]]+by ]]; then
                    printf '%s\n' "$line"
                    continue
                fi
                if [[ "$line" =~ ^[[:space:]]+case[[:space:]]+\"\$1\" ]]; then
                    # emit new case body
                    printf '    case "$1" in\n'
                    local cluster
                    for cluster in "${all_bases[@]}"; do
                        printf '        %s)\n' "$cluster"
                        printf '            image="%s"\n' "${DES_IMAGE[$cluster]}"
                        printf '            count=%s\n' "${DES_COUNT[$cluster]}"
                        printf '            ;;\n'
                    done
                    printf '        *)\n'
                    printf '            image="%s"\n' "$CUR_DEMOLIB_DEFAULT_IMAGE"
                    printf '            count=%s\n' "${CUR_DEMOLIB_DEFAULT_COUNT:-1}"
                    printf '            ;;\n'
                    printf '    esac\n'
                    emitted_case=1
                    skipping=1
                    continue
                fi
                printf '%s\n' "$line"
                continue
            fi
            if [[ $skipping -eq 1 ]]; then
                # skip until we see the line right after `esac`, which is the
                # `startDemo "$1" ...` invocation
                if [[ "$line" =~ ^[[:space:]]+startDemo[[:space:]]+\"\$1\" ]]; then
                    printf '%s\n' "$line"
                    skipping=0
                fi
                continue
            fi
            printf '%s\n' "$line"
        done < "$CURRENT_DEMOLIB"
    } > "$out"
}

#------------------------------------------------------------------------------
# diff + report
#------------------------------------------------------------------------------

diff_and_report() {
    local new_ip="$1" new_demolib="$2"
    local has_diff=0

    local ip_diff demolib_diff
    ip_diff="$(diff -u "$CURRENT_IP_MAP" "$new_ip" || true)"
    demolib_diff="$(diff -u "$CURRENT_DEMOLIB" "$new_demolib" || true)"

    [[ -n "$ip_diff"      ]] && has_diff=1
    [[ -n "$demolib_diff" ]] && has_diff=1

    # stdout: plain-text report (captured by the workflow artifact)
    echo "## demo_farm auto-derive: dry-run report"
    echo
    echo "Upstream base: $UPSTREAM_BASE"
    echo "Latest holder: $RT_LATEST_BRANCH -> $RT_LATEST_VERSION_REF"
    echo "Rel branches: ${RT_REL_BRANCHES[*]}"
    echo "Supported PHP matrix: $PHP_MATRIX"
    echo
    if [[ $has_diff -eq 0 ]]; then
        echo "No diff: current state matches desired state."
    else
        if [[ -n "$ip_diff" ]]; then
            echo "=== ip_map_branch.txt ==="
            echo "$ip_diff"
            echo
        fi
        if [[ -n "$demolib_diff" ]]; then
            echo "=== docker/scripts/demoLibrary.source ==="
            echo "$demolib_diff"
            echo
        fi
    fi

    # GITHUB_STEP_SUMMARY: markdown-formatted with collapsible diffs
    if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
        {
            echo "## demo_farm auto-derive: dry-run report"
            echo
            echo "**Upstream base:** \`$UPSTREAM_BASE\`"
            echo "**Latest holder:** \`$RT_LATEST_BRANCH\` -> \`$RT_LATEST_VERSION_REF\`"
            echo "**Rel branches:** \`${RT_REL_BRANCHES[*]}\`"
            echo "**Supported PHP matrix:** \`$PHP_MATRIX\`"
            echo
            if [[ $has_diff -eq 0 ]]; then
                echo "No diff: current state matches desired state."
            else
                if [[ -n "$ip_diff" ]]; then
                    echo '<details><summary><code>ip_map_branch.txt</code></summary>'
                    echo
                    echo '```diff'
                    echo "$ip_diff"
                    echo '```'
                    echo
                    echo '</details>'
                fi
                if [[ -n "$demolib_diff" ]]; then
                    echo
                    echo '<details><summary><code>docker/scripts/demoLibrary.source</code></summary>'
                    echo
                    echo '```diff'
                    echo "$demolib_diff"
                    echo '```'
                    echo
                    echo '</details>'
                fi
            fi
        } >> "$GITHUB_STEP_SUMMARY"
    fi

    return 0
}

#------------------------------------------------------------------------------
# main
#------------------------------------------------------------------------------

main() {
    fetch_release_targets
    fetch_supported_php_versions
    read_current_ip_map
    read_current_demolib
    compute_desired_state

    local new_ip="$WORKDIR/ip_map_branch.txt.new"
    local new_demolib="$WORKDIR/demoLibrary.source.new"
    render_ip_map "$new_ip"
    render_demolib "$new_demolib"

    if [[ "$MODE" == "write" ]]; then
        cp "$new_ip" "$CURRENT_IP_MAP"
        cp "$new_demolib" "$CURRENT_DEMOLIB"
        echo "WROTE: $CURRENT_IP_MAP"
        echo "WROTE: $CURRENT_DEMOLIB"
    fi
    diff_and_report "$new_ip" "$new_demolib"
}

main "$@"
