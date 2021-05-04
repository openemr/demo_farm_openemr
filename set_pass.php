<?php
// resets password

set_time_limit(0);

// Ensure running from command line only
if (php_sapi_name() !== 'cli') {
    exit;
}

// $path requires no explanation
// $seconds is how frequently the passwords are reset
// $mode:
//       1  - just the admin user in a basic demo (version < 6.0.0)
//       2  - all the official users in the demos with demo data (version < 6.0.0)
//       3  - just the admin user in a basic demo (version 6.0.0+)
//       4  - all the official users in the demos with demo data (version 6.0.0+)

$path = $argv[1];
$seconds = $argv[2];
$mode = $argv[3];

$_GET['site'] = 'default';
$ignoreAuth=1;
require_once($path . "/openemr/interface/globals.php");

use OpenEMR\Common\Auth\AuthUtils;

if ($mode == 4) {
    while (true) {
        // support for versions 6.0.0+ with demo data
        $user = 'admin';
        $password = 'pass';
        if (!(new AuthUtils('login'))->confirmPassword($user, $password)) {
            // admin password has been modified, so fix it
            sqlStatementNoLog('UPDATE `users` SET `username` = "admin", `active` = 1 WHERE `id` = 1');
            sqlStatementNoLog('UPDATE `users_secure` SET `username` = "admin", `password` = "$2a$05$.hH4Godes3dORmHjOjtXXekQPf2n5tQsw2H/ahwsBECLA/QCgWRS." WHERE `id` = 1');
            error_log("DEMO: FIXED the admin password for " . $path);
        }

        $user = 'accountant';
        $password = 'accountant';
        if (!(new AuthUtils('login'))->confirmPassword($user, $password)) {
            // accountant password has been modified, so fix it
            sqlStatementNoLog('UPDATE `users` SET `username` = "accountant", `active` = 1 WHERE `id` = 4');
            sqlStatementNoLog('UPDATE `users_secure` SET `username` = "accountant", `password` = "$2a$05$rMH0ZfoGXKuavGpsmM.UPuAonkS2811YVIE2ZL52.Q/GGCL0AAV4q" WHERE `id` = 4');
            error_log("DEMO: FIXED the accountant password for " . $path);
        }

        $user = 'clinician';
        $password = 'clinician';
        if (!(new AuthUtils('login'))->confirmPassword($user, $password)) {
            // clinician password has been modified, so fix it
            sqlStatementNoLog('UPDATE `users` SET `username` = "clinician", `active` = 1 WHERE `id` = 5');
            sqlStatementNoLog('UPDATE `users_secure` SET `username` = "clinician", `password` = "$2a$05$LDt00UZrNVbXR8j9Rj0.NuBN6bMoT4hbXoiKnkQkDQetYy9rMXIri" WHERE `id` = 5');
            error_log("DEMO: FIXED the clinician password for " . $path);
        }

        $user = 'physician';
        $password = 'physician';
        if (!(new AuthUtils('login'))->confirmPassword($user, $password)) {
            // physician password has been modified, so fix it
            sqlStatementNoLog('UPDATE `users` SET `username` = "physician", `active` = 1 WHERE `id` = 6');
            sqlStatementNoLog('UPDATE `users_secure` SET `username` = "physician", `password` = "$2a$05$y6Myd8hMVXzFqcHBrCo8K.K/OcVBOCB1KrOFN//Hsw89f6x17wvGC" WHERE `id` = 6');
            error_log("DEMO: FIXED the physician password for " . $path);
        }

        $user = 'receptionist';
        $password = 'receptionist';
        if (!(new AuthUtils('login'))->confirmPassword($user, $password)) {
            // receptionist password has been modified, so fix it
            sqlStatementNoLog('UPDATE `users` SET `username` = "receptionist", `active` = 1 WHERE `id` = 7');
            sqlStatementNoLog('UPDATE `users_secure` SET `username` = "receptionist", `password` = "$2a$05$bHD9eIJ0dc6fISnNdqJtbe2/LVUPWhWGSuJOxRGab/NaUZYV3vqBO" WHERE `id` = 7');
            error_log("DEMO: FIXED the receptionist password for " . $path);
        }

        sleep($seconds);
    }
} elseif ($mode == 3) {
    while (true) {
        // support for versions 6.0.0+ with no demo data
        $user = 'admin';
        $password = 'pass';
        if (!(new AuthUtils('login'))->confirmPassword($user, $password)) {
            // admin password has been modified, so fix it
            sqlStatementNoLog('UPDATE `users` SET `username` = "admin", `active` = 1 WHERE `id` = 1');
            sqlStatementNoLog('UPDATE `users_secure` SET `username` = "admin", `password` = "$2a$05$.hH4Godes3dORmHjOjtXXekQPf2n5tQsw2H/ahwsBECLA/QCgWRS." WHERE `id` = 1');
            error_log("DEMO: FIXED the admin password for " . $path);
        }
        sleep($seconds);
    }
} elseif ($mode == 2) {
    while (true) {
        // support for versions < 6.0.0 with demo data
        sqlStatementNoLog('UPDATE `users` SET `username` = "admin", `active` = 1 WHERE `id` = 1');
        sqlStatementNoLog('UPDATE `users_secure` SET `username` = "admin", `password` = "$2a$05$.hH4Godes3dORmHjOjtXXekQPf2n5tQsw2H/ahwsBECLA/QCgWRS.", `salt` = "$2a$05$.hH4Godes3dORmHjOjtXXl$" WHERE `id` = 1');

        sqlStatementNoLog('UPDATE `users` SET `username` = "accountant", `active` = 1 WHERE `id` = 4');
        sqlStatementNoLog('UPDATE `users_secure` SET `username` = "accountant", `password` = "$2a$05$rMH0ZfoGXKuavGpsmM.UPuAonkS2811YVIE2ZL52.Q/GGCL0AAV4q", `salt` = "$2a$05$rMH0ZfoGXKuavGpsmM.UPy$" WHERE `id` = 4');

        sqlStatementNoLog('UPDATE `users` SET `username` = "clinician", `active` = 1 WHERE `id` = 5');
        sqlStatementNoLog('UPDATE `users_secure` SET `username` = "clinician", `password` = "$2a$05$LDt00UZrNVbXR8j9Rj0.NuBN6bMoT4hbXoiKnkQkDQetYy9rMXIri", `salt` = "$2a$05$LDt00UZrNVbXR8j9Rj0.N3$" WHERE `id` = 5');

        sqlStatementNoLog('UPDATE `users` SET `username` = "physician", `active` = 1 WHERE `id` = 6');
        sqlStatementNoLog('UPDATE `users_secure` SET `username` = "physician", `password` = "$2a$05$y6Myd8hMVXzFqcHBrCo8K.K/OcVBOCB1KrOFN//Hsw89f6x17wvGC", `salt` = "$2a$05$y6Myd8hMVXzFqcHBrCo8K.$" WHERE `id` = 6');

        sqlStatementNoLog('UPDATE `users` SET `username` = "receptionist", `active` = 1 WHERE `id` = 7');
        sqlStatementNoLog('UPDATE `users_secure` SET `username` = "receptionist", `password` = "$2a$05$bHD9eIJ0dc6fISnNdqJtbe2/LVUPWhWGSuJOxRGab/NaUZYV3vqBO", `salt` = "$2a$05$bHD9eIJ0dc6fISnNdqJtbn$" WHERE `id` = 7');

        sqlStatementNoLog('UPDATE `users` SET `username` = "zhportal", `active` = 1 WHERE `id` = 8');
        sqlStatementNoLog('UPDATE `users_secure` SET `username` = "zhportal", `password` = "$2a$05$U6.L67RPZCz5GT4HEqTwieF6e2QBtIMQrFClRUYlC8vC9tIMiOpVC", `salt` = "$2a$05$U6.L67RPZCz5GT4HEqTwit$" WHERE `id` = 8');
        sleep($seconds);
    }
} else { // ($mode == 1)
    while (true) {
        // support for versions < 6.0.0 with no demo data
        sqlStatementNoLog('UPDATE `users` SET `username` = "admin", `active` = 1 WHERE `id` = 1');
        sqlStatementNoLog('UPDATE `users_secure` SET `username` = "admin", `password` = "$2a$05$.hH4Godes3dORmHjOjtXXekQPf2n5tQsw2H/ahwsBECLA/QCgWRS.", `salt` = "$2a$05$.hH4Godes3dORmHjOjtXXl$" WHERE `id` = 1');
        sleep($seconds);
    }
}
