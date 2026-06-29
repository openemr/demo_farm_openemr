#!/bin/bash
#
# Copyright (C) 2017 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

# Always pull fresh copies of the flex image tags used by the demo farm.
# Tag → cluster mapping lives in startDemoWrapper (demoLibrary.source).
docker pull openemr/openemr:flex-3.23-php-8.5
docker pull openemr/openemr:flex-3.23-php-8.4
docker pull openemr/openemr:flex-3.23-php-8.3
docker pull openemr/openemr:flex-3.22-php-8.4
docker pull openemr/openemr:flex-3.22-php-8.2

# update demo_farm_openemr repo
cd ~/demo_farm_openemr || exit 1
git fetch origin
git pull origin master
cd ~/ || exit 1

# update translations_development_openemr repo and place in html dir
cd ~/translations_development_openemr || exit 1
git fetch origin
git pull origin master
cd ~/ || exit 1
cp ~/translations_development_openemr/languageTranslations_utf8.sql ~/html/translations/

# update optional wkhtmltopdf-openemr
cd ~/wkhtmltopdf-openemr || exit 1
git fetch origin
git pull origin master
cd ~/ || exit 1

# rebuild simple website and copy translations to website
cp -r ~/demo_farm_openemr/docker/html/* ~/html/
cp ~/translations_development_openemr/languageTranslations_utf8.sql ~/html/translations/

# restart openemr demo docker containers
# (note do not restart nginx, php, mysql, and phpmyadmin dockers)
# (also note demo 'five' is at beginning since this is the production demo)
# (also note doing the demo 'four' at end to be more efficient since it will set up 3 subdemos)
# (also note placed the `edu` demo docker at the end)
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh five
sleep 30m
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh one
sleep 5m
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh two
sleep 5m
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh three
sleep 5m
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh six
sleep 5m
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh seven
sleep 5m
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh eight
sleep 5m
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh nine
sleep 5m
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh ten
sleep 5m
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh eleven
sleep 5m
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh four
sleep 5m
bash ~/demo_farm_openemr/docker/scripts/restartDemo.sh edu

# Reclaim disk: drop images that are no longer tagged (the prior
# flex image layer that the docker pulls above just replaced) and
# not in use by any container. Without this, dangling layers
# accumulate fast since flex is rebuilt nightly upstream.
docker image prune -f
