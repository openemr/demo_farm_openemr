# tools/auto-derive

Reconciliation bot that derives `ip_map_branch.txt` + `docker/scripts/demoLibrary.source`
from upstream `openemr/openemr` state.

See the G6 design in [`openemr/openemr` release-mechanism-gaps doc](https://github.com/openemr/openemr) for full background. Short version:

- **What:** reads upstream `release-targets.yml`, per-branch `docker/release/Dockerfile`
  ARGs (Alpine + PHP), and the `ci/apache_*` directory listing on master
  (source of truth for the supported-PHP set); reconciles cluster
  assignments + flex images against current demo_farm state.
- **Sticky cluster identity:** each cluster maps to an externally-referenced
  subdomain (e.g. `eight` -> `eight.openemr.io`), so the bot reads the current
  file as state and applies a diff rather than rendering from scratch.
- **Section ownership** (per [G6 matrix](#)):
  - Production (`five` family): fixed clusters; branch_tag from the
    `latest`-tagged row's `openemr_version_ref`; flex image from that branch's
    Dockerfile.
  - Up-for-grabs (`four` family): rows preserved verbatim (community claims);
    flex image always from master's Dockerfile.
  - Master demos: one cluster per supported PHP. The supported set is the
    unique PHP prefixes (`apache_82_*` -> 8.2, `apache_85_*` -> 8.5, etc.)
    across master's `ci/apache_*` directory listing. Sticky assignment from
    prior state; new from parked; retired returns to parked.
  - Release demos: one cluster per non-latest, non-unreleased rel branch;
    sticky from prior state; new from parked.
  - Parked: bench cluster pool.
  - Miscellaneous: preserved verbatim.

## Running locally

```sh
# dry-run against your demo_farm checkout
./derive.sh --dry-run

# write mode (mutates files in place -- PR #2 will use this)
./derive.sh --write
```

`derive.sh --help` prints the full usage.

## Fail-loud edge cases

- Zero (or more than one) non-unreleased `latest` rows in
  `release-targets.yml`.
- Parked bench empty when a new cluster is needed (adding a parked cluster
  first is required to preserve cluster->subdomain stability -- the bot
  refuses to invent cluster names).
- `ARG ALPINE_VERSION` or `ARG PHP_VERSION` not parseable from a branch's
  `docker/release/Dockerfile`.
- No `ci/apache_<NN>_*` directories on upstream master (would yield an empty
  supported-PHP set).

## Tests

```sh
./fixtures-and-tests/test.sh
```

Each fixture under `fixtures-and-tests/fixtures/<name>/` carries:

- `current/` -- inputs (current demo_farm state, mirrors what's in the
  repo root + `docker/scripts/`)
- `upstream/<ref>/...` -- simulated upstream openemr/openemr files, fetched
  via `--upstream-base file://...`
- `expected/` -- what derive.sh should produce (or `expected/fail.txt` with
  a substring expected in the failure message)

Add a new fixture by copying an existing one, modifying inputs, then
re-capturing expected:

```sh
WS=$(mktemp -d) && cp -a fixtures/<your-name>/current/. $WS/ && \
  ./derive.sh --current-dir $WS \
    --upstream-base "file://$PWD/fixtures/<your-name>/upstream" \
    --write && \
  cp -a $WS/. fixtures/<your-name>/expected/ && rm -rf $WS
```

## PR scope

This is **PR #1** of the auto-derive workstream:

- PR #1 (this): scaffold + dry-run output (artifact + step summary). No
  live PR opening.
- PR #2: add live PR opening on diff (peter-evans force-push pattern).
- PR #3: atomic flip -- wire `repository_dispatch` consumers + retire
  `.github/workflows/bump-tag.yml` + the `tools/release/` PHP toolchain.
