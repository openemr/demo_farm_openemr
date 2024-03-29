The repo holds the mechanism for an OpenEMR demo farm.

Note that the prior appliance mechanism has been deprecated and now using a mechanism
based on docker. Can see details in the docker/scripts/startFarm.sh script.

How do I set one of the "UP FOR GRABS" OpenEMR demos?
-----------------------------------------------------
1. Fork the https://github.com/openemr/demo_farm_openemr.git repo and make it your own
2. Place your OpenEMR git repo information in the openemr_repo and branch items in
   your ip_map_branch.txt for one of the UP FOR GRABS demo entries ("two"-"five").
3. Place a github pull request on your commit for number 2 above.
4. After I bring in your github pull request, then place your repo and branch
   information in the pertinent UP FOR GRABS demo entries here:
   https://www.open-emr.org/wiki/index.php/Development_Demo#UP_FOR_GRABS_Development_Demos
5. When the demo resets (which is daily), it will now be using your selected repo branch!!

Description of ip_map_branch.txt configuration file
---------------------------------------------------
This file is a tab delimited file for configuration of demos in the demo farm with following settings:
- docker_number: docker name of the OpenEMR demo
- openemr_repo: set it to the openemr repo you want to grab code from
- branch: git branch of the OpenEMR github repository
- serve_development_translations: set to 1 to have demo serve the daily build of translation set for download, set to 0 to turn this off (this setting has been deprecated)
- use_development_translations: set to 1 to have demo use the daily build of translation set, set to 0 to turn this off
- serve_packages: set to 1 to have demo serve zip/tgz packages of the build for download, set to 0 to turn this off
- legacy_patching: set to 1 if you are using a legacy patched branch, such as rel-411,rel-410 etc. Note that rel-412 and above should be set to 0.
- demo_data: set to 0 if no sql demo data file. If have a sql demo data file, then place the name of it here and place the file in the 'pieces' directory.
- demo_ssh: set to the ssh package if using the offsite portal. Set to 0 if not connecting to offsite portal.
- patient_portals: set to 0 to not use. set to 1 to set up the onsite patient portal demo.
- external_link: place the external web address to the demo here
- root_sql_pass: set the root_sql_pass to use. if this is empty, then leave blank (however, only the deprecated demos will leave this empty).
- branch_tag: set this to `branch` when using a github branch and `tag` when using a github tag. 
- demo_data_upgrade_from: when set demo_data above or capsule below, then place the OpenEMR version that the demo data was based on (so it will then be upgraded from that version).
- fun_stuff: set this to randomly select a theme. Set to 0 to turn off. Set to 1 for when using OpenEMR version < 6.0 and set to 2 when using OpenEMR version 6.0 and greater.
- pass_reset: set this to have password(s) reset to default every 5 minutes. Set to 0 to turn off. Set to 1 for demos that just have admin user. Set to 2 for demos that have the standard demo data.
- capsule: set to 0 if no capsule. If have a capsule, then place the name of it here.
- description: place description of the demo here

How to restart the demo farm when the instance does a shutdown/reboot
----------------------------------------------------------------
- Step 1 : First start the following dockers via commmands below
    ```sh
    bash ~/demo_farm_openemr/docker/scripts/restartMysql.sh
    bash ~/demo_farm_openemr/docker/scripts/restartPhpmyadmin.sh
    bash ~/demo_farm_openemr/docker/scripts/restartPhp.sh
    ```
- Step 2 : Then start the nginx (reverse-proxy) docker via command below
    ```sh
    bash ~/demo_farm_openemr/docker/scripts/restartNginx.sh
    ```
- Step 3 : Do a demo farm reset (this will start up all the openemr dockers; same things that happens every night during a farm reset)
    ```sh
    bash ~/demo_farm_openemr/docker/scripts/restartFarm.sh
    ```
- Step 4: Wait for the reset (ie. magic) to happen. Recommend drinking a cup of coffee and watching the following video about 15 times: https://www.youtube.com/watch?v=JnbfuAcCqpY

LICENSE
--------------------------------------
GNU GENERAL PUBLIC LICENSE
