
The repo will hold the pieces for an OpenEMR demo farm.

Set up a ubuntu pre-trigger appliance
-------------------------
1. Install a ubuntu appliance on vmware
2. Install and remove the ubuntu development package at:
   http://www.open-emr.org/wiki/index.php/Ubuntu-Debian_OpenEMR_Development_Package_Installation
3. Config php and apache
4. Set up /etc/rc.local file from:
   https://github.com/bradymiller/demo_farm_openemr.git repo
5. At some point will hopefully offer a download link with this appliance.

Trigger the ubuntu appliance
------------------------------
1. Change triggerOpenemrDevelopmentDemo in /etc/rc.local to true
2. Set a static ip address in appliance (ubuntu 12.04, see example 
   the example /etc/network/interfaces file, which is interfaces
   file in this repo)
3. Shutdown appliance and set a snapshot in vmware and have it revert to
   snapshot on shutdown.
4. Place ip address along with git branch and options in
   in the ip_map_branch.txt file in the repo:
   https://github.com/bradymiller/demo_farm_openemr.git
5. Start the appliance

Description of ip_map_branch.txt configuration file
---------------------------------------------------
This file is a tab delimited file for configuration of demos in the demo farm with following settings:
- ip address: local ip address of the OpenEMR demo
- openemr_repo: set it to the openemr repo you want to grab code from
- branch: git branch of the OpenEMR github repository
- serve_development_translations: set to 1 to have demo serve the daily build of translation set for download, set to 0 to turn this off
- use_development_translations: set to 1 to have demo use the daily build of translation set(this option only works with code based on master/4.1.3), set to 0 to turn this off
- serve_packages: set to 1 to have demo serve zip/tgz packages of the build for download, set to 0 to turn this off
- description: place description of the demo here

How to grow your own OpenEMR demo farm
--------------------------------------
1. Fork the https://github.com/bradymiller/demo_farm_openemr.git repo and make it your own
2. Configure ip_map_branch.txt
3. Set up the pre-trigger appliance, as above (or download it when available)
4. Trigger the appliance, as above. In the /etc/rc.local, place link to your custom demo_farm_openemr repo.

