#!/bin/bash
#
# Copyright (C) 2017 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

# Always check for a new versions of the custom docker images
# NOTE 14.04 does not work with development OpenEMR since php version is too low,
#      but collecting it in case somebody wishes to make it work with older
#      OpenEMR versions.
docker pull bradymiller/pre-openemr:16.04
docker pull bradymiller/pre-openemr:14.04
docker pull bradymiller/pre-openemr:17.10
docker pull bradymiller/pre-openemr:18.04
docker pull bradymiller/pre-openemr:3.5
docker pull bradymiller/pre-openemr:3.6
docker pull bradymiller/pre-openemr:3.7
docker pull bradymiller/php-ssh:7.1-fpm-alpine

# update demo_farm_openemr repo
cd ~/demo_farm_openemr
git fetch origin
git pull origin master
cd ~/

# update translations_development_openemr repo and place in html dir
cd ~/translations_development_openemr
git fetch origin
git pull origin master
cd ~/
cp ~/translations_development_openemr/languageTranslations_utf8.sql ~/html/translations/

# update optional wkhtmltopdf-openemr
cd ~/wkhtmltopdf-openemr
git fetch origin
git pull origin master
cd ~/

# rebuild simple website and copy translations to website
cp -r ~/demo_farm_openemr/docker/html/* ~/html/
cp ~/translations_development_openemr/languageTranslations_utf8.sql ~/html/translations/

# restart openemr demo docker containers
# (note do not restart nginx, php, mysql, and phpmyadmin dockers)
# (also note doing the demo 'four' at end to be more efficient since it will set up 10 subdemos)
# (also note demo 'five' is at beginning since this is the "main" demos)
# (also note that demo 'edu' are just refreshing subdemos to allow persistent demos that
#  do not reset; for example `edu empty` and `edu c` subdemos are not being reset)
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh five
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh one
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh two
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh three
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh six
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh seven
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh eight
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh nine
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh ten
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh eleven
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh four
#bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh edu empty
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh edu a
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh edu b