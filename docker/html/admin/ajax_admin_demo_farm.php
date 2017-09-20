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
    $output[] = " ";
    $output[] = "COMMAND: " . $command;
    exec("ssh -o StrictHostKeyChecking=no -i /home/ssh/openemr-demo-server.pem ec2-user@openemr.io '" . $command . "'", $output);
}

if (!empty($_POST['procedure'])) {
    $output = array();
    switch ($_POST['procedure']) {
        case 'status_farm':
            collectProcedure('docker ps -a', $output);
            collectProcedure('docker images', $output);
            collectProcedure('df -h', $output);
            break;
        case 'status_one_openemr':
            collectProcedure('docker logs one-openemr', $output);
            break;
        case 'status_two_openemr':
            collectProcedure('docker logs two-openemr', $output);
            break;
        case 'status_three_openemr':
            collectProcedure('docker logs three-openemr', $output);
            break;
        case 'status_four_openemr':
            collectProcedure('docker logs four-openemr', $output);
            break;
        case 'status_five_openemr':
            collectProcedure('docker logs five-openemr', $output);
            break;
        case 'status_six_openemr':
            collectProcedure('docker logs six-openemr', $output);
            break;
        case 'status_seven_openemr':
            collectProcedure('docker logs seven-openemr', $output);
            break;
        case 'status_eight_openemr':
            collectProcedure('docker logs eight-openemr', $output);
            break;
        case 'status_nine_openemr':
            collectProcedure('docker logs nine-openemr', $output);
            break;
        case 'status_ten_openemr':
            collectProcedure('docker logs ten-openemr', $output);
            break;
        default:
            $output[] = "ERROR: Did not recognize procedure.";
            break;
    }
    echo json_encode($output);
    exit();
}
