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
            <div class="page-header">
                <h1>OpenEMR Demo Farm Admin Page</h1>
            </div>
            <div class="row col-xs-12">
                <div class="col-sm-2">
                    <button type="button" class="btn btn-primary" id="check_farm_status_button" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Processing Status">Check Farm Status</button> 
                <div>
                <div class="col-sm-10">
                    <textarea class="form-control" id="check_status_output" rows="10" readonly></textarea>
                </div>
            </div>
        </div>
    </body>

    <script>

        $("#check_farm_status_button").click(function(){

            $(this).button('loading');

            document.getElementById('check_status_output').value = "";

            $.post("ajax_admin_demo_farm.php",
            {
                procedure: "status_farm"
            },
            function(data, status){
                document.getElementById('check_status_output').value = data;
                $(this).button('reset');
                alert(status);
            });
        });

    </script>
</html>
