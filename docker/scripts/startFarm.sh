#!/bin/bash
#
# Copyright (C) 2017 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

# create aws ami t2.medium ec2 instance with 60GB storage space (likely overkill but docker can take up lots of storage space and will optimize this over time)
#  -install docker and git via link: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html
#  -in home directory, clone demo_farm_openemr(https://github.com/openemr/demo_farm_openemr.git)
#  -in home directory, clone translations_development_openemr (https://github.com/openemr/translations_development_openemr.git)
#  -in home directory, make a 'html/translations' directory (mkdir -p ~/html/translations)
#  -place following cron entry:
#    00 08 * * * bash ~/demo_farm_openemr/docker/scripts/restartFarm.sh > /dev/null

# for building pre-openemr with the Dockerfiles (cd to path with the Dockerfile)
#cd ~/demo_farm_openemr/docker/pre-openemr/16-04/
#docker build -t pre-openemr:16.04 .
#cd ~/demo_farm_openemr/docker/pre-openemr/14-04/
#docker build -t pre-openemr:14.04 .
#cd ~/demo_farm_openemr/docker/pre-openemr/17-04/
#docker build -t pre-openemr:17.04 .
#cd ~/demo_farm_openemr/docker/pre-openemr/17-10/
#docker build -t pre-openemr:17.10 .

# to collect the docker images
#docker pull nginx
#docker pull mysql
#docker pull phpmyadmin/phpmyadmin

# Always check for a new versions of the docker images
#  (this was migrated to restart script to reduce downtime of demos)
# NOTE 14.04 does not work with development OpenEMR since php version is too low,
#      but collecting it in case somebody wishes to make it work with older
#      OpenEMR versions.
#docker pull bradymiller/pre-openemr:16.04
#docker pull bradymiller/pre-openemr:14.04
#docker pull bradymiller/pre-openemr:17.04
#docker pull bradymiller/pre-openemr:17.10

# to start network
#docker network create mynet

# update demo_farm_openemr repo
#  (this was migrated to restart script to reduce downtime of demos)
#cd ~/demo_farm_openemr
#git fetch origin
#git pull origin master
#cd ~/

# update translations_development_openemr repo and place in html dir
#  (this was migrated to restart script to reduce downtime of demos)
#cd ~/translations_development_openemr
#git fetch origin
#git pull origin master
#cd ~/

# rebuild simple website and copy translations to website
# (this was migrated to restart script to reduce downtime of demos)
#cp -r ~/demo_farm_openemr/docker/html/* ~/html/
#cp ~/translations_development_openemr/languageTranslations_utf8.sql ~/html/translations/

# bring in the dockers (note reverse-proxy needs to be done last)
docker run --detach --name mysql-openemr \
                    --env "MYSQL_ROOT_PASSWORD=hey" \
                    --net mynet \
                    mysql
docker run --detach --name phpmyadmin-openemr \
                    --env "PMA_HOST=mysql-openemr" \
                    --net mynet \
                     phpmyadmin/phpmyadmin
docker run --detach --name one-openemr \
                    --env "DOCKERDEMO=one" \
                    --env "DOCKERMYSQLHOST=mysql-openemr" \
                    -v ~/demo_farm_openemr/docker/php/16-04/php.ini:/etc/php/7.0/apache2/php.ini:ro \
                    --net mynet \
                    bradymiller/pre-openemr:16.04
docker run --detach --name two-openemr \
                    --env "DOCKERDEMO=two" \
                    --env "DOCKERMYSQLHOST=mysql-openemr" \
                    -v ~/demo_farm_openemr/docker/php/16-04/php.ini:/etc/php/7.0/apache2/php.ini:ro \
                    --net mynet \
                    bradymiller/pre-openemr:16.04
docker run --detach --name three-openemr \
                    --env "DOCKERDEMO=three" \
                    --env "DOCKERMYSQLHOST=mysql-openemr" \
                    -v ~/demo_farm_openemr/docker/php/16-04/php.ini:/etc/php/7.0/apache2/php.ini:ro \
                    --net mynet \
                    bradymiller/pre-openemr:16.04
docker run --detach --name four-openemr \
                    --env "DOCKERDEMO=four" \
                    --env "DOCKERMYSQLHOST=mysql-openemr" \
                    -v ~/demo_farm_openemr/docker/php/16-04/php.ini:/etc/php/7.0/apache2/php.ini:ro \
                    --net mynet \
                    bradymiller/pre-openemr:16.04
docker run --detach --name five-openemr \
                    --env "DOCKERDEMO=five" \
                    --env "DOCKERMYSQLHOST=mysql-openemr" \
                    -v ~/demo_farm_openemr/docker/php/16-04/php.ini:/etc/php/7.0/apache2/php.ini:ro \
                    --net mynet \
                    bradymiller/pre-openemr:16.04
docker run --detach --name six-openemr \
                    --env "DOCKERDEMO=six" \
                    --env "DOCKERMYSQLHOST=mysql-openemr" \
                    -v ~/demo_farm_openemr/docker/php/16-04/php.ini:/etc/php/7.0/apache2/php.ini:ro \
                    --net mynet \
                    bradymiller/pre-openemr:16.04
docker run --detach --name seven-openemr \
                    --env "DOCKERDEMO=seven" \
                    --env "DOCKERMYSQLHOST=mysql-openemr" \
                    -v ~/demo_farm_openemr/docker/php/17-04/php.ini:/etc/php/7.0/apache2/php.ini:ro \
                    --net mynet \
                    bradymiller/pre-openemr:17.04
docker run --detach --name eight-openemr \
                    --env "DOCKERDEMO=eight" \
                    --env "DOCKERMYSQLHOST=mysql-openemr" \
                    -v ~/demo_farm_openemr/docker/php/17-10/php.ini:/etc/php/7.1/apache2/php.ini:ro \
                    --net mynet \
                    bradymiller/pre-openemr:17.10
# Keep below running, so don't run after do initial start
#docker run --detach --name reverse-proxy \
#                    -p 80:80 \
#                    -v ~/demo_farm_openemr/docker/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
#                    -v ~/html:/usr/share/nginx/html:ro \
#                    --net mynet \
#                    nginx

