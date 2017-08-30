#!/bin/bash
#
# Copyright (C) 2017 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

# Always check for a new versions of the docker images
#  (this was migrated to here from start script to reduce downtime of demos)
# NOTE 14.04 does not work with development OpenEMR since php version is too low,
#      but collecting it in case somebody wishes to make it work with older
#      OpenEMR versions.
docker pull bradymiller/pre-openemr:16.04
docker pull bradymiller/pre-openemr:14.04
docker pull bradymiller/pre-openemr:17.04
docker pull bradymiller/pre-openemr:17.10

# update demo_farm_openemr repo
#  (this was migrated to here from start script to reduce downtime of demos)
cd ~/demo_farm_openemr
git fetch origin
git pull origin master
cd ~/

# update translations_development_openemr repo and place in html dir
#  (this was migrated to here from start script to reduce downtime of demos)
cd ~/translations_development_openemr
git fetch origin
git pull origin master
cd ~/
cp ~/translations_development_openemr/languageTranslations_utf8.sql ~/html/translations/

# rebuild simple website and copy translations to website
# (this was migrated to here from start script to reduce downtime of demos)
cp -r ~/demo_farm_openemr/docker/html/* ~/html/
cp ~/translations_development_openemr/languageTranslations_utf8.sql ~/html/translations/

# restart openemr demo docker containers
# (note do not restart nginx, mysql, and phpmyadmin dockers)
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh one &
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh two &
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh three &
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh four &
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh five &
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh six &
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh seven &
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh eight &

