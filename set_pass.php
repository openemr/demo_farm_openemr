<?php
// resets password

set_time_limit(0);

// Ensure running from command line only
if (php_sapi_name() !== 'cli') {
    exit;
}

$path = $argv[1];
$seconds = $argv[2];

$_GET['site'] = 'default';
$ignoreAuth=1;
require_once($path . "/openemr/interface/globals.php");
require_once($GLOBALS['srcdir'] . "/authentication/password_change.php");

while (true) {
    sqlStatement("UPDATE `users` SET `username` = 'admin', `active` = 1 WHERE `id` = 1");
    sqlStatement("UPDATE `users_secure` SET `username` = 'admin', `password` = '$2a$05$.hH4Godes3dORmHjOjtXXekQPf2n5tQsw2H/ahwsBECLA/QCgWRS.', `salt` = '$2a$05$.hH4Godes3dORmHjOjtXXl$' WHERE `id` = 1");
    sleep($seconds);
}
