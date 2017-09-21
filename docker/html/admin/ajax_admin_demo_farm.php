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
            collectProcedure('free -m', $output);
            collectProcedure('top -bca -n 1', $output);
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
        case 'status_mysql':
            collectProcedure('docker logs mysql-openemr', $output);
            break;
        case 'status_nginx':
            collectProcedure('docker logs reverse-proxy', $output);
            break;
        case 'status_phpmyadmin':
            collectProcedure('docker logs phpmyadmin-openemr', $output);
            break;
        case 'status_php':
            collectProcedure('docker logs php-serve', $output);
            break;
        case 'restart_one_openemr':
            collectProcedure('bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh one', $output);
            break;
        case 'restart_two_openemr':
            collectProcedure('bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh two', $output);
            break;
        case 'restart_three_openemr':
            collectProcedure('bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh three', $output);
            break;
        case 'restart_four_openemr':
            collectProcedure('bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh four', $output);
            break;
        case 'restart_five_openemr':
            collectProcedure('bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh five', $output);
            break;
        case 'restart_six_openemr':
            collectProcedure('bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh six', $output);
            break;
        case 'restart_seven_openemr':
            collectProcedure('bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh seven', $output);
            break;
        case 'restart_eight_openemr':
            collectProcedure('bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh eight', $output);
            break;
        case 'restart_nine_openemr':
            collectProcedure('bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh nine', $output);
            break;
        case 'restart_ten_openemr':
            collectProcedure('bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh ten', $output);
            break;
        case 'restart_all_openemr':
            collectProcedure('bash ~/demo_farm_openemr/docker/scripts/restartFarm.sh', $output);
            break;
        case 'restart_database_openemr':
            collectProcedure('bash ~/demo_farm_openemr/docker/scripts/restartMysql.sh', $output);
            break;
        case 'restart_phpmyadmin_openemr':
            collectProcedure('bash ~/demo_farm_openemr/docker/scripts/restartPhpmyadmin.sh', $output);
            break;
        case 'restart_nginx_openemr':
            collectProcedure('bash ~/demo_farm_openemr/docker/scripts/restartNginx.sh', $output);
            break;
        case 'restart_php_openemr':
            collectProcedure('bash ~/demo_farm_openemr/docker/scripts/restartPhp.sh', $output);
            break;
        case 'restart_certs_openemr':
            collectProcedure('bash ~/demo_farm_openemr/docker/scripts/renewLetsencrypt.sh', $output);
            break;
        default:
            $output[] = "ERROR: Did not recognize procedure.";
            break;
    }
    echo json_encode($output);
    exit();
}
