<?php
/**
 * OpenEMR Demo farm Admin Page
 *
 * @link      http://www.open-emr.org
 * @author    Brady Miller <brady.g.miller@gmail.com>
 * @copyright Copyright (c) 2017 Brady Miller <brady.g.miller@gmail.com>
 * @license   GNU General Public License 3
 */

function collectProcedure($command, &$output)
{
    exec("ssh -i /home/ssh/openemr-demo-server.pem ec2-user@openemr.io '" . $command . "'", $output);
}

if (!empty($_POST['procedure'])) {
    if ($_POST['procedure'] == "status_farm") {
        $output = array();
        collectProcedure('docker ps -a', $output);
        collectProcedure('docker images', $output);
        collectProcedure('df -h', $output);
        print_r($output);
        exit();
    }
}
