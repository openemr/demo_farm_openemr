[![Build Status](https://travis-ci.org/openemr/demo_farm_openemr.svg?branch=master)](https://travis-ci.org/openemr/demo_farm_openemr)

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
   http://www.open-emr.org/wiki/index.php/Development_Demo#UP_FOR_GRABS_Development_Demos
5. When the demo resets (which is daily), it will now be using your selected repo branch!!

Description of ip_map_branch.txt configuration file
---------------------------------------------------
This file is a tab delimited file for configuration of demos in the demo farm with following settings:
- docker_number: docker name of the OpenEMR demo (in deprecated demos, this is the ip address)
- openemr_repo: set it to the openemr repo you want to grab code from
- branch: git branch of the OpenEMR github repository
- serve_development_translations: set to 1 to have demo serve the daily build of translation set for download, set to 0 to turn this off (this setting has been deprecated)
- use_development_translations: set to 1 to have demo use the daily build of translation set, set to 0 to turn this off
- serve_packages: set to 1 to have demo serve zip/tgz packages of the build for download, set to 0 to turn this off
- legacy_patching: set to 1 if you are using a legacy patched branch, such as rel-411,rel-410 etc. Note that rel-412 and above should be set to 0.
- demo_data: set to 0 if no sql demo data file. If have a sql demo data file, then place the name of it here and place the file in the 'pieces' directory.
- demo_ssh: set to the ssh package if using the offsite portal. Set to 0 if not connecting to offsite portal.
- patient_portals: set to 0 to not use. set to 1 to set up the onsite and wordpress patient portal demo.
- external_link: place the external web address to the demo here
- root_sql_pass: set the root_sql_pass to use. if this is empty, then leave blank (however, only the deprecated demos will leave this empty).
- branch_tag: set this to `branch` when using a github branch and `tag` when using a github tag. 
- description: place description of the demo here

LICENSE
--------------------------------------
GNU GENERAL PUBLIC LICENSE
