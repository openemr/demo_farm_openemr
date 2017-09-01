#!/bin/bash
#
# Copyright (C) 2017 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
#
# create aws ami t2.medium ec2 instance with 60GB storage space (likely overkill but docker can take up lots of storage space and will optimize this over time)
#  -install docker and git via link: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html
#  -install mysql client (sudo yum update; sudo yum install mysql)
#  -in home directory, clone demo_farm_openemr(https://github.com/openemr/demo_farm_openemr.git)
#  -in home directory, clone translations_development_openemr (https://github.com/openemr/translations_development_openemr.git)
#  -in home directory, make a 'html/translations' directory (mkdir -p ~/html/translations)
#  -place following in cron : copy stuff from docker/cron/cron

# Bring in the demo function library
source ~/demo_farm_openemr/docker/scripts/demoLibrary.source

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
docker pull nginx
docker pull mysql
docker pull phpmyadmin/phpmyadmin

# Always check for a new versions of the docker images
# NOTE 14.04 does not work with development OpenEMR since php version is too low,
#      but collecting it in case somebody wishes to make it work with older
#      OpenEMR versions.
docker pull bradymiller/pre-openemr:16.04
docker pull bradymiller/pre-openemr:14.04
docker pull bradymiller/pre-openemr:17.04
docker pull bradymiller/pre-openemr:17.10

# to start network
docker network create mynet

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

# rebuild simple website and copy translations to website
cp -r ~/demo_farm_openemr/docker/html/* ~/html/
cp ~/translations_development_openemr/languageTranslations_utf8.sql ~/html/translations/

# bring in the dockers (note reverse-proxy needs to be done last)
startMysql
startPhpmyadmin
startDemo "one" "mysql-openemr" "7.0" "16-04" "16.04"
startDemo "two" "mysql-openemr" "7.0" "16-04" "16.04"
startDemo "three" "mysql-openemr" "7.0" "16-04" "16.04"
startDemo "four" "mysql-openemr" "7.0" "16-04" "16.04"
startDemo "five" "mysql-openemr" "7.0" "16-04" "16.04"
startDemo "six" "mysql-openemr" "7.0" "16-04" "16.04"
startDemo "seven" "mysql-openemr" "7.0" "17-04" "17.04"
startDemo "eight" "mysql-openemr" "7.1" "17-10" "17.10"
startNginx
