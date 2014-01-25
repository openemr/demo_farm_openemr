
The repo will hold the pieces for an OpenEMR demo farm.

1. Set up a ubuntu appliance
   a. Install and remove the ubuntu development package at:
      http://www.open-emr.org/wiki/index.php/Ubuntu-Debian_OpenEMR_Development_Package_Installation
   b. Config php and apache
   c. Set up /etc/rc.local file from:
      https://github.com/bradymiller/demo_farm_openemr.git repo
   d. At some point will hopefull offer a download link with this appliance.
2. Change triggerOpenemrDevelopmentDemo in /etc/rc.local  to true
3. Set a static ip address in appliance
4. Shutdown appliance and set a snapshot in vmware and have it revert to
   snapshot on shutdown.
5. Place ip address along with git branch and options in
   in the ip_map_branch.txt file in the:
   https://github.com/bradymiller/demo_farm_openemr.git repo
6. Start the appliance
