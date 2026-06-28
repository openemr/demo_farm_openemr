# tools/auto-derive

Reconciliation bot that derives `ip_map_branch.txt` + `docker/scripts/demoLibrary.source`
from upstream `openemr/openemr` state.

See the G6 design in the [release-mechanism migration plan](https://github.com/openemr/openemr/pull/12598) (PR #12598 on `openemr/openemr`, `docs/release-mechanism-migration-from-devops.md`) for full background. Short version:

- **What:** reads upstream `release-targets.yml`, per-branch `docker/release/Dockerfile`
  ARGs (Alpine + PHP), master's `docker/flex/Dockerfile` ARGs (the **anchor**
  for master-demo Alpine selection AND for the up-for-grabs flex image -- both
  Alpine and PHP), the `ci/apache_*` directory listing on master
  (source of truth for the supported-PHP set), and master's flex-build
  workflow files `.github/workflows/docker-build-*.yml` (source of truth
  for which Alpine+PHP combinations actually build); reconciles cluster
  assignments + flex images against current demo_farm state.
- **Sticky cluster identity:** each cluster maps to an externally-referenced
  subdomain (e.g. `eight` -> `eight.openemr.io`), so the bot reads the current
  file as state and applies a diff rather than rendering from scratch.
- **Section ownership** (per [G6 matrix](#)):
  - Production (`five` family): fixed clusters; `branch` column set to
    the `latest`-tagged row's `openemr_version_ref` (e.g. `v8_0_0_3`);
    description regenerated from a template using the latest row's
    `docker_tags` primary version (shortest pure-numeric tag -- e.g.
    `8.0.0` out of `"8.0.0,8.0.0.3,latest"`): base row reads
    `Public OpenEMR <ver> Production Demo`, `_a` reads
    `Alternate Public OpenEMR <ver> Production Demo`, `_b` reads
    `Another Alternate Public OpenEMR <ver> Production Demo`;
    flex image from that branch's Dockerfile.
  - Up-for-grabs (`four` family): rows preserved verbatim (community claims);
    flex image taken **directly from master's `docker/flex/Dockerfile`** --
    both `ARG ALPINE_VERSION` and `ARG PHP_VERSION` used verbatim (e.g.
    `flex-3.23-php-8.5`).
  - Master demos: one cluster per supported PHP. The supported set is the
    unique PHP prefixes (`apache_82_*` -> 8.2, `apache_85_*` -> 8.5, etc.)
    across master's `ci/apache_*` directory listing. Sticky assignment from
    prior state; new from parked; retired returns to parked. The flex image
    for each cluster is `flex-<Alpine>-php-<PHP>`, where `<Alpine>` is chosen
    by **starting at master's `docker/flex/Dockerfile` `ARG ALPINE_VERSION`**
    and, if that Alpine doesn't support the cluster's PHP per the flex
    matrix, dropping down to the next-lower Alpine that does (e.g. Alpine
    3.23 dropped PHP 8.2, so the PHP 8.2 cluster falls back to 3.22). The
    selection is **never higher** than master flex's Alpine -- the flex
    Dockerfile is the upper bound. The matrix is read from
    `.github/workflows/docker-build-<NN>.yml` + `docker-build-edge.yml`
    on master; `docker-build-flex-core.yml` (reusable) and
    `docker-build-release.yml` (production) are skipped. Edge is excluded
    from canonical demo selection.
  - Release demos: **one cluster per non-master row in
    `release-targets.yml`** (multiple rows under the same `rel-*` branch
    produce multiple clusters -- one per row). The `latest` row also drives
    the production demos in addition to its own release-demo cluster.
    Per row, sticky assignment uses a 3-tier priority:
    1. existing release-demo cluster whose CURRENT `branch` column (col 3)
       exactly matches the row's `openemr_version_ref` (typical no-op case),
    2. else existing release-demo cluster whose CURRENT `branch` column
       matches the row's `branch` field (single-row lifecycle: cluster
       previously pinned to `rel-810` rolls forward to `v8_1_0` when the
       row's `openemr_version_ref` advances),
    3. else claim from parked (new row case).
    Already-claimed clusters in the current run are skipped at each tier.
    After all rows assigned, any release-demo cluster NOT claimed in this
    run is released to parked (retired branch case). Col 3 = the row's
    `openemr_version_ref`. Description regenerated from a template using
    the row's `docker_tags` primary version (shortest pure-numeric tag);
    the label is **shape-derived from col 3**: `Release Demo` if col 3
    matches `v<digits>_<digits>_<digits>(_<digits>)?` (tag), else
    `Development Demo` (branch ref like `rel-810`). Alpine + PHP come from
    that rel branch's `docker/release/Dockerfile` ARGs.
  - Parked: bench cluster pool.
  - Miscellaneous: preserved verbatim.

## Running locally

```sh
# dry-run against your demo_farm checkout
./derive.sh --dry-run

# write mode (mutates files in place -- this is what the daily reconcile uses)
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
- `ARG ALPINE_VERSION` or `ARG PHP_VERSION` not parseable from master's
  `docker/flex/Dockerfile` (the anchor for master demos + up-for-grabs).
- No `ci/apache_<NN>_*` directories on upstream master (would yield an empty
  supported-PHP set).
- No `docker-build-<NN>.yml` or `docker-build-edge.yml` flex-matrix workflow
  files on upstream master.
- A PHP version from `ci/apache_*` not supported by master flex Dockerfile's
  Alpine or any lower non-edge Alpine in the flex matrix (canonical master
  demos can't fall back to edge, and the master flex Alpine is the upper
  bound -- the bot won't pick higher).
- `alpine_version` or `php_versions` not parseable from a
  `docker-build-*.yml` workflow.

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
WS=$(mktemp -d) && cp -a fixtures-and-tests/fixtures/<your-name>/current/. $WS/ && \
  ./derive.sh --current-dir $WS \
    --upstream-base "file://$PWD/fixtures-and-tests/fixtures/<your-name>/upstream" \
    --write && \
  cp -a $WS/. fixtures-and-tests/fixtures/<your-name>/expected/ && rm -rf $WS
```

## Daily reconcile + auto-PR

The `derive-ip-map` workflow runs daily at 07:00 UTC in **reconcile** mode:

- Runs `derive.sh --write` and checks `ip_map_branch.txt` +
  `docker/scripts/demoLibrary.source` for any diff vs `master`. Diff
  detection is scoped to those two files so unrelated edits to
  `tools/auto-derive/` can't trip a bot PR.
- On diff: force-pushes the stable branch `auto-derive/reconciliation` and
  opens (or updates, if already open) a PR titled
  `[auto-derive] reconcile demo_farm against upstream openemr master`.
- On no diff: if a reconciliation PR is open from a prior run, closes it
  and deletes the remote branch (upstream drift reverted).

The branch is **stable + force-pushed**, so the bot updates the same PR
across days rather than spamming new ones. Merge to land the reconciled
state; the bot quiets until the next genuine drift.

`workflow_dispatch` defaults to `reconcile` too; pick `dry-run` from the
input dropdown to preview the algorithm's output without any branch/PR
side effects (uploaded as the `derive-output` artifact).

**Caveat:** the bot PR is created via `GITHUB_TOKEN`, so downstream
workflows (rabbit, CI) don't run on it automatically. The fixture suite
job in this same workflow is the authoritative algorithm validator. To
manually re-trigger CI on the PR, push an empty commit:

```sh
git commit --allow-empty -m 'trigger ci' && git push
```

## PR scope

The auto-derive workstream:

- PR #1: scaffold + dry-run output (artifact + step summary). No live PR
  opening.
- PR #2 (this): write + auto-PR mode (force-push stable branch, open or
  update PR on diff, close on no-diff).
- PR #3: atomic flip -- wire `repository_dispatch` consumers + retire
  `.github/workflows/bump-tag.yml` + the `tools/release/` PHP toolchain.
