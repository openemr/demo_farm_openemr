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
                                <textarea class="form-control" id="check_status_output" rows="31" wrap="off" readonly></textarea>
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
                </div>
            </div>
        </div>
    </body>
    <script>

        $(".procedure-demo").click(function(){

            var this_button = $(this).button();
            this_button.button('loading');

            var procedure = $(this).attr('id');

            document.getElementById('check_status_output').value = "";

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
                document.getElementById('check_status_output').value = entireData;
                this_button.button('reset');
            });
        });

    </script>
</html>
