<?php
// Test-harness stub. Real content is inside the flex image at run time;
// upgradeOpenEMRDatabase in demo_build.sh probes this file for two
// executable-code signatures (the --from= parser AND the $cliFromVersion
// gate that lets CLI mode bypass the form_submit check) to decide
// between the CLI-mode invocation (rel-820+, master -- added in
// openemr#11906) and the legacy 3-sed form-submit patching (rel-704,
// rel-800). This stub carries the real parser + gate signatures so the
// dry-run test picks the CLI path; the default touched-empty stub in
// tools/build-tests/test.sh has neither, exercising the legacy path.
//
// The probe is still a plain grep, so a comment containing these exact
// strings would technically also match -- but requiring both specific
// code-string signatures makes comment-only false positives unlikely
// enough in a real sql_upgrade.php. See CodeRabbit feedback on
// openemr/demo_farm_openemr#176 for the rationale.

$cliFromVersion = null;
if (php_sapi_name() === 'cli') {
    foreach ($argv as $arg) {
        if (str_starts_with($arg, '--from=')) {
            $cliFromVersion = substr($arg, 7);
        }
    }
}

if (!empty($_POST['form_submit']) || $cliFromVersion !== null) {
    // upgrade would happen here in the real script
}
