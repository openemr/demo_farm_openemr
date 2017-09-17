<?php
/**
 * OpenEMR Demo farm Admin Page
 *
 * @link      http://www.open-emr.org
 * @author    Brady Miller <brady.g.miller@gmail.com>
 * @copyright Copyright (c) 2017 Brady Miller <brady.g.miller@gmail.com>
 * @license   GNU General Public License 3
 */

if (!empty($_POST['procedure'])) {
    if ($_POST['procedure'] == "status_farm") {
        $output = array();
        exec('df -h', $output);
        exec('docker images', $output);
        exec('docker ps -a', $output);
        print_r($output);
        exit();
    }
}

