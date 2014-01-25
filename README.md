
The repo will hold the pieces for an OpenEMR demo farm.

Set up a ubuntu appliance
-------------------------
1. Install and remove the ubuntu development package at:
   http://www.open-emr.org/wiki/index.php/Ubuntu-Debian_OpenEMR_Development_Package_Installation
2. Config php and apache
3. Set up /etc/rc.local file from:
   https://github.com/bradymiller/demo_farm_openemr.git repo
4. At some point will hopefully offer a download link with this appliance.

Configure the ubuntu appliance
------------------------------
1. Change triggerOpenemrDevelopmentDemo in /etc/rc.local  to true
2. Set a static ip address in appliance
3. Shutdown appliance and set a snapshot in vmware and have it revert to
   snapshot on shutdown.
4. Place ip address along with git branch and options in
   in the ip_map_branch.txt file in the:
   https://github.com/bradymiller/demo_farm_openemr.git repo
5. Start the appliance

Description of ip_map_branch.txt configuration file
---------------------------------------------------
This file is a tab delimited file for configuration of demos in the demo farm with following settings:
- ip address: local ip address of the OpenEMR demo
- branch: git branch of the OpenEMR github repository
- serve_development_translations: set to 1 to have demo serve the daily build of translation set for download, set to 0 to turn this off
- use_development_translations: set to 1 to have demo use the daily build of translatio set, set to 0 to turn this off
- serve_packages: set to 1 to have demo serve zip/tgz packages of the build for download, set to 0 to turn this off
- description: place description of the demo here
