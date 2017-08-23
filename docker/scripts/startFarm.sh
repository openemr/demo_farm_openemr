#!/bin/bash
#
# Copyright (C) 2017 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# TODO: -serve the development translations set from here and set up nginx to do this by sharing the volume with "website" on it
#       -create scripts for each demo to (restartOne.sh etc.)

# create aws ami t2.medium ec2 instance with 50GB storage space (likely overkill but docker can take up lots of storage space and will optimize this over time)
#  -install docker and git via link: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html
#  -install mysql-client
# in home directory, clone demo_farm_openemr

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

# bring in the dockers (note reverse-proxy needs to be done last)
docker run --detach --name mysql-openemr --env "MYSQL_ROOT_PASSWORD=hey" --net mynet mysql
docker run --detach --name phpmyadmin-openemr --env "PMA_HOST=mysql-openemr" --net mynet phpmyadmin/phpmyadmin
docker run --detach --name one-openemr --env "DOCKERDEMO=one" --env "DOCKERMYSQLHOST=mysql-openemr" --net mynet bradymiller/pre-openemr-16
docker run --detach --name two-openemr --env "DOCKERDEMO=two" --env "DOCKERMYSQLHOST=mysql-openemr" --net mynet bradymiller/pre-openemr-16
docker run --detach --name three-openemr --env "DOCKERDEMO=three" --env "DOCKERMYSQLHOST=mysql-openemr" --net mynet bradymiller/pre-openemr-16
docker run --detach --name four-openemr --env "DOCKERDEMO=four" --env "DOCKERMYSQLHOST=mysql-openemr" --net mynet bradymiller/pre-openemr-16
docker run --detach --name five-openemr --env "DOCKERDEMO=five" --env "DOCKERMYSQLHOST=mysql-openemr" --net mynet bradymiller/pre-openemr-16
docker run --detach --name six-openemr --env "DOCKERDEMO=six" --env "DOCKERMYSQLHOST=mysql-openemr" --net mynet bradymiller/pre-openemr-16
docker run --detach -p 80:80 --name reverse-proxy -v ~/demo_farm_openemr/docker/nginx/nginx.conf:/etc/nginx/nginx.conf:ro --net mynet nginx
