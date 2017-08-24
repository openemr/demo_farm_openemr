#!/bin/bash
#
# Copyright (C) 2017 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# TODO: -serve the development translations set from ec2 instance host and set up nginx to do this by sharing the volume with "website" on it
#       -create scripts for each demo to (restartOne.sh etc.)
#       -set up php conf mechanism like the nginx where bring in conf file via volume (separate for each version of ubuntu)
#

# create aws ami t2.medium ec2 instance with 50GB storage space (likely overkill but docker can take up lots of storage space and will optimize this over time)
#  -install docker and git via link: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html
#  -in home directory, clone demo_farm_openemr(https://github.com/bradymiller/demo_farm_openemr.git)
#  -in home directory, clone translations_development_openemr (https://github.com/openemr/translations_development_openemr.git)
#  -in home directory, make a 'html/translations' directory (mkdir -p ~/html/translations)
#  -place following cron entry:
#    00 08 * * * bash ~/demo_farm_openemr/docker/scripts/restartFarm.sh > /dev/null

# for building pre-openemr-16 with the Dockerfile (cd to path with the Dockerfile)
#docker build -t pre-openemr-16 .

# to collect the docker images
#docker pull nginx
#docker pull mysql
#docker pull phpmyadmin/phpmyadmin
#docker pull bradymiller/pre-openemr-16

# to start network
#docker network create mynet

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
                    bradymiller/pre-openemr-16
docker run --detach --name two-openemr \
                    --env "DOCKERDEMO=two" \
                    --env "DOCKERMYSQLHOST=mysql-openemr" \
                    -v ~/demo_farm_openemr/docker/php/16-04/php.ini:/etc/php/7.0/apache2/php.ini:ro \
                    --net mynet \
                    bradymiller/pre-openemr-16
docker run --detach --name three-openemr \
                    --env "DOCKERDEMO=three" \
                    --env "DOCKERMYSQLHOST=mysql-openemr" \
                    -v ~/demo_farm_openemr/docker/php/16-04/php.ini:/etc/php/7.0/apache2/php.ini:ro \
                    --net mynet \
                    bradymiller/pre-openemr-16
docker run --detach --name four-openemr \
                    --env "DOCKERDEMO=four" \
                    --env "DOCKERMYSQLHOST=mysql-openemr" \
                    -v ~/demo_farm_openemr/docker/php/16-04/php.ini:/etc/php/7.0/apache2/php.ini:ro \
                    --net mynet \
                    bradymiller/pre-openemr-16
docker run --detach --name five-openemr \
                    --env "DOCKERDEMO=five" \
                    --env "DOCKERMYSQLHOST=mysql-openemr" \
                    -v ~/demo_farm_openemr/docker/php/16-04/php.ini:/etc/php/7.0/apache2/php.ini:ro \
                    --net mynet \
                    bradymiller/pre-openemr-16
docker run --detach --name six-openemr \
                    --env "DOCKERDEMO=six" \
                    --env "DOCKERMYSQLHOST=mysql-openemr" \
                    -v ~/demo_farm_openemr/docker/php/16-04/php.ini:/etc/php/7.0/apache2/php.ini:ro \
                    --net mynet \
                    bradymiller/pre-openemr-16
docker run --detach --name reverse-proxy \
                    -p 80:80 \
                    -v ~/demo_farm_openemr/docker/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
                    -v ~/html:/usr/share/nginx/html:ro \
                    --net mynet \
                    nginx

