# demo_farm_openemr

[![ShellCheck](https://github.com/openemr/demo_farm_openemr/actions/workflows/shellcheck.yml/badge.svg?branch=master)](https://github.com/openemr/demo_farm_openemr/actions/workflows/shellcheck.yml)
[![build-tests (dry-run)](https://github.com/openemr/demo_farm_openemr/actions/workflows/build-tests.yml/badge.svg?branch=master)](https://github.com/openemr/demo_farm_openemr/actions/workflows/build-tests.yml)
[![build-tests (live integration)](https://github.com/openemr/demo_farm_openemr/actions/workflows/build-tests-live.yml/badge.svg?branch=master)](https://github.com/openemr/demo_farm_openemr/actions/workflows/build-tests-live.yml)
[![Derive ip_map (reconcile)](https://github.com/openemr/demo_farm_openemr/actions/workflows/derive-ip-map.yml/badge.svg?branch=master)](https://github.com/openemr/demo_farm_openemr/actions/workflows/derive-ip-map.yml)

Mechanism for the OpenEMR demo farm at [demo.openemr.io](https://demo.openemr.io) and its sibling clusters (`one.openemr.io`, `two.openemr.io`, `three.openemr.io`, etc.).

The farm is docker-based, running on a single EC2 instance. Each cluster is one `openemr/openemr:flex-<alpine>-php-<n>` container that runs `demo_build.sh` at startup to clone one or more OpenEMR git refs into that container's web root. `docker/scripts/startFarm.sh` is the initial-provisioning entry point; `restartFarm.sh` is what the daily 08:00 UTC cron fires to reset all demos back to a clean state.

## How do I set one of the "UP FOR GRABS" OpenEMR demos?

1. Fork this repo.
2. Update the `openemr_repo` and `branch` columns in `ip_map_branch.txt` for one of the UP FOR GRABS entries (`four`, `four_a`, or `four_b`).
3. Open a pull request with the change.
4. Once merged, also update the pertinent entry on the [Development Demo wiki page](https://www.open-emr.org/wiki/index.php/Development_Demo#UP_FOR_GRABS_Development_Demos).
5. At the next daily reset (08:00 UTC), the demo will pick up your selected repo/branch.

## `ip_map_branch.txt` columns

Tab-delimited. Each row configures one cluster (`docker_number` without underscore) or one subdemo within a cluster (`docker_number` with `_<letter>` suffix). The header row itself annotates deprecated columns with `(not used)` so the schema is self-describing.

| # | Column | Notes |
| --- | --- | --- |
| 1 | `docker_number` | Cluster or subdemo id — `two`, `five`, `two_a`, `four_b`, etc. Also the mariadb database name. |
| 2 | `openemr_repo` | Full git URL to clone. Usually `https://github.com/openemr/openemr.git`; UP FOR GRABS entries can point at forks. |
| 3 | `branch` | Git ref to clone — branch name (`master`, `rel-810`) or tag name (`v8_0_0_3`). `demo_build.sh` uses `git clone --branch <ref> --depth 1` which accepts both. |
| 4 | `serve_development_translations` | Deprecated. Column preserved for backward column-order compatibility. |
| 5 | `use_development_translations` | `1` = use the daily-built translation set, `0` = use the checked-in one. |
| 6 | `serve_packages` | `1` = also build and serve OpenEMR CVS `.tar.gz` and `.zip` packages under `<cluster>.openemr.io/files/` (a second composer + npm + phing pass in a staging dir; adds several minutes). `0` = skip. |
| 7 | `legacy_patching` | Deprecated. Column preserved. |
| 8 | `demo_data` | `0` = no demo data. Non-zero = filename of a `.sql` file under `pieces/` to load *after* `InstallerAuto.php` runs (drops the empty schema InstallerAuto created, then reloads from the file). |
| 9 | `demo_ssh` | Deprecated. Column preserved. |
| 10 | `patient_portals_and_api` | `1` = enable onsite patient portal + REST / FHIR / OAuth APIs by setting the corresponding `globals`. `0` = leave defaults. |
| 11 | `external_link` | External web address for this demo. Used to set the `site_addr_oath` global (drives OAuth callback URLs). |
| 12 | `root_sql_pass` | mariadb root password to authenticate to `MYSQL_ROOT_PASSWORD` on the mariadb container (`hey` in the production farm). |
| 13 | `branch_tag` | Deprecated. Old-style branch-vs-tag switch; `git clone --branch` handles both, so `demo_build.sh` no longer reads this column. Set to `0`. |
| 14 | `demo_data_upgrade_from` | If `demo_data` or `capsule` is set: OpenEMR version the data was originally captured against, so `sql_upgrade.php` can upgrade it forward to the running version. |
| 15 | `fun_stuff` | Random-theme picker. `0` = off, `1` = 36-theme picker (older CSS themes), `2` = 6-theme picker (newer themes). **Any other non-zero value falls through to the 36-theme picker** (see `demo_build.sh`'s `if [ "$funStuff" == "2" ]; then ... else ... fi`). |
| 16 | `pass_reset` | Historically drove `set_pass.php` to reset user passwords every 5 min. Documented modes 1/2 in older commits are stale — `set_pass.php` actually supports **1, 2, 3, 4** (3/4 are the 6.0.0+ variants of 1/2). Production rows use `4`. **The mechanism is currently disabled** pending [openemr/openemr#5991](https://github.com/openemr/openemr/issues/5991); see the commented-out invocation near the bottom of `demo_build.sh`'s per-iteration loop. Column values are kept aligned with intended future re-enable. |
| 17 | `capsule` | `0` = no capsule. Non-zero = filename (without `.tgz`) of a capsule under `capsules/` to unpack over the OpenEMR install. See `demo_build.sh`'s `useCapsuleBoolean` branch. Values are validated against a path-traversal guard (`case "$useCapsuleFile" in '' \| */* \| . \| ..)`) added in #145. |
| 18 | `description` | Free-form human description of this row. Surfaces in the setup log. |

## How to restart the demo farm after a host reboot

1. Bring up the shared infrastructure containers:
   ```sh
   bash ~/demo_farm_openemr/docker/scripts/restartMysql.sh
   bash ~/demo_farm_openemr/docker/scripts/restartPhpmyadmin.sh
   bash ~/demo_farm_openemr/docker/scripts/restartPhp.sh
   ```
2. Bring up the reverse-proxy container:
   ```sh
   bash ~/demo_farm_openemr/docker/scripts/restartNginx.sh
   ```
3. Do a full demo-farm reset (this is what the daily 08:00 UTC cron runs):
   ```sh
   bash ~/demo_farm_openemr/docker/scripts/restartFarm.sh
   ```
4. Wait. Full reset takes roughly an hour end-to-end; the longest single step is the "cluster `five`" build (demo data + upgrade + random theme).

## Regression tests (issue #146)

`demo_build.sh` has two layers of automated regression coverage that fire in CI on every PR touching it (plus a nightly schedule for the live layer):

- **Dry-run suite** — `tools/build-tests/`. Runs `demo_build.sh --dry-run` against 7 canned fixtures and diffs the captured action log against a per-fixture golden. Catches parsing, branching, and quoting regressions at PR time. Wall time: seconds.
- **Live integration matrix** — `tools/build-tests/integration/`. Stands up a real `mariadb:10.6` + `openemr/openemr:flex` container per scenario and runs `demo_build.sh` end-to-end (composer + npm + webpack + `InstallerAuto.php` + apache start). 3 scenarios run in parallel via matrix; wall time ~10 min (slowest cell). Runs on every PR + daily 08:00 UTC schedule.

The auto-derive bot also has its own fixture suite — `tools/auto-derive/fixtures-and-tests/` — 8 fixtures covering the parser + reconciler.

## Auto-derive bot

`tools/auto-derive/derive.sh` reconciles `ip_map_branch.txt` and `docker/scripts/demoLibrary.source` against the current upstream `openemr/openemr` release-targets + Dockerfiles. Runs daily at 07:00 UTC (workflow `.github/workflows/derive-ip-map.yml`) and opens a PR against master when it finds drift. If the drift disappears (upstream reverts), the open PR is closed automatically the next day.

The bot also fires on `repository_dispatch types=release-targets-changed` — openemr/openemr triggers this whenever `.github/release-targets.yml` is pushed to master, so reconciliation is immediate rather than waiting for the next tick.

## ShellCheck

The repo is ShellCheck-clean. `.shellcheckrc` intentionally carries no `disable=` lines. `.github/workflows/shellcheck.yml` fires on any `.sh` / `.source` change and blocks merge on new violations. Historical ratchet cleanup: PRs #149 → #157.

## License

[GNU GPL v3](LICENSE).
