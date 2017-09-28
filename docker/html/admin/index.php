<?php
/**
 * OpenEMR Demo farm Admin Page
 *
 * @link      http://www.open-emr.org
 * @author    Brady Miller <brady.g.miller@gmail.com>
 * @copyright Copyright (c) 2017 Brady Miller <brady.g.miller@gmail.com>
 * @license   GNU General Public License 3
 */
?>

<html>
    <head>

        <title>OpenEMR Demo Farm Admin Page</title>

        <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
        <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" crossorigin="anonymous">

        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>

    </head>
    <body>
        <div class="container">
            <div class="row">
                <div class="page-header">
                    <h1>OpenEMR Demo Farm Admin Page</h1>
                </div>
            </div>
            <div class="row">
                <ul class="nav nav-tabs">
                    <li class="active"><a data-toggle="tab" href="#status">Status</a></li>
                    <li><a data-toggle="tab" href="#upforgrabs">Up For Grabs</a></li>
                    <li><a data-toggle="tab" href="#advanced">Advanced</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div id="status" class="tab-pane fade in active">
                    <div class="row text-center">
                        <h3>Status</h3>
                    </div>
                    <div class="row">
                        <div class="col-sm-2">
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="status_farm" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Status">Farm Status</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="status_one_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Status">One Status</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="status_two_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Status">Two Status</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="status_three_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Status">Three Status</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="status_four_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Status">Four Status</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="status_five_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Status">Five Status</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="status_six_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Status">Six Status</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="status_seven_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Status">Seven Status</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="status_eight_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Status">Eight Status</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="status_nine_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Status">Nine Status</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="status_ten_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Status">Ten Status</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="status_mysql" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Status">Mysql Status</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="status_nginx" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Status">Nginx Status</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="status_phpmyadmin" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Status">PhpMyAdmin Status</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="status_php" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Status">Php Status</button>
                            </div>
                        </div>
                        <div class="col-sm-10">
                            <pre>
                                <textarea class="form-control" id="status_output" rows="31" wrap="off" readonly></textarea>
                            </pre>
                        </div>
                    </div>
                </div>
                <div id="upforgrabs" class="tab-pane fade">
                    <div class="row text-center">
                        <h3>Up For Grabs</h3>
                    </div>
                </div>
                <div id="advanced" class="tab-pane fade">
                    <div class="row text-center">
                        <h3>Advanced</h3>
                    </div>
                    <div class="row">
                        <div class="col-sm-2">
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="restart_one_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Restart">One Restart</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="restart_two_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Restart">Two Restart</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="restart_three_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Restart">Three Restart</button>
                            </div>
                            <div class="panel-group">
                                <div class="panel panel-default">
                                    <button class="btn btn-link" type="button" data-toggle="collapse" data-target="#collapseFour" aria-expanded="false" aria-controls="collapseFour">
                                        Four Toggle
                                    </button>
                                    <div class="collapse" id="collapseFour">
                                        <div class="panel-body">
                                            <div class="card card-body">
                                                <div class="btn-group-vertical form-group">
                                                    <button type="button" class="btn btn-primary procedure-demo" id="restart_four_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Restart">Four Restart</button>
                                                </div>
                                                <div class="btn-group-vertical form-group">
                                                    <button type="button" class="btn btn-primary procedure-demo" id="refresh_four_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Refresh">Four Refresh</button>
                                                    <button type="button" class="btn btn-primary procedure-demo" id="refresh_four_a_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Refresh">Four A Refresh</button>
                                                    <button type="button" class="btn btn-primary procedure-demo" id="refresh_four_b_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Refresh">Four B Refresh</button>
                                                    <button type="button" class="btn btn-primary procedure-demo" id="refresh_four_c_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Refresh">Four C Refresh</button>
                                                    <button type="button" class="btn btn-primary procedure-demo" id="refresh_four_d_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Refresh">Four D Refresh</button>
                                                    <button type="button" class="btn btn-primary procedure-demo" id="refresh_four_e_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Refresh">Four E Refresh</button>
                                                    <button type="button" class="btn btn-primary procedure-demo" id="refresh_four_f_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Refresh">Four F Refresh</button>
                                                    <button type="button" class="btn btn-primary procedure-demo" id="refresh_four_g_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Refresh">Four G Refresh</button>
                                                    <button type="button" class="btn btn-primary procedure-demo" id="refresh_four_h_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Refresh">Four H Refresh</button>
                                                    <button type="button" class="btn btn-primary procedure-demo" id="refresh_four_i_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Refresh">Four I Refresh</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="panel panel-default">
                                    <button class="btn btn-link" type="button" data-toggle="collapse" data-target="#collapseFive" aria-expanded="false" aria-controls="collapseFive">
                                        Five Toggle
                                    </button>
                                    <div class="collapse" id="collapseFive">
                                        <div class="panel-body">
                                            <div class="card card-body">
                                                <div class="btn-group-vertical form-group">
                                                    <button type="button" class="btn btn-primary procedure-demo" id="restart_five_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Restart">Five Restart</button>
                                                </div>
                                                <div class="btn-group-vertical form-group">
                                                    <button type="button" class="btn btn-primary procedure-demo" id="refresh_five_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Refresh">Five Refresh</button>
                                                    <button type="button" class="btn btn-primary procedure-demo" id="refresh_five_a_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Refresh">Five A Refresh</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="restart_six_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Restart">Six Restart</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="restart_seven_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Restart">Seven Restart</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="restart_eight_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Restart">Eight Restart</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="restart_nine_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Restart">Nine Restart</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="restart_ten_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Restart">Ten Restart</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-warning procedure-demo" id="restart_all_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Restart">Restart All Demos</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-danger procedure-demo" id="restart_database_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Restart">Restart Demo Databases</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="restart_phpmyadmin_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Restart">PhpMyAdmin Restart</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="restart_nginx_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Restart" disabled>Nginx Restart</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="restart_php_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Restart" disabled>Php Restart</button>
                            </div>
                            <div class="row form-group">
                                <button type="button" class="btn btn-primary procedure-demo" id="restart_certs_openemr" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Renew" disabled>Renew SSL Certs</button>
                            </div>
                        </div>
                        <div class="col-sm-10">
                            <pre>
                                <textarea class="form-control" id="advanced_output" rows="34" wrap="off" readonly></textarea>
                            </pre>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
    <script>

        $(".procedure-demo").click(function(){

            var this_button = $(this).button();
            this_button.button('loading');

            var procedure = $(this).attr('id');

            if (procedure.includes('status')) {
                var outputPanel = 'status_output';
            } else if (procedure.includes('upforgrabs')) {
                var outputPanel = 'upforgrabs_output';
            } else { // procedure.includes('restart')
                var outputPanel = 'advanced_output';
            }

            document.getElementById(outputPanel).value = "";

            $.post("ajax_admin_demo_farm.php",
            {
                procedure: procedure
            },
            function(data, status){
                var entireData = "";
                data = $.parseJSON(data);
                $.each(data, function(i, item) {
                    entireData = entireData + item + "\n";
                });
                document.getElementById(outputPanel).value = entireData;
                this_button.button('reset');
            });
        });

    </script>
</html>
