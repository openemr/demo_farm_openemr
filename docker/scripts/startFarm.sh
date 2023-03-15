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
#  -in home directory, make a 'capsules' directory (mkdir -p ~/capsules)
#  -in home directory, clone the optional wkhtmltopdf-openemr composer package via git:
#    -git clone https://github.com/openemr/wkhtmltopdf-openemr.git
#  -place following in cron : copy stuff from docker/cron/cron
#  -ensure commented out ssh cert stuff in nginx conf script(see line 9 of ~/demo_farm_openemr/docker/nginx/nginx.conf), restart reverse proxy,
#   and follow instructions here to prime the SAN certificate (after prime, can then uncomment the ssh cert stuff and restart reverse proxy):
#    https://miki725.github.io/docker/crypto/2017/01/29/docker+nginx+letsencrypt.html
#      1) comment out the ssh cert stuff near line 9 in ~/demo_farm_openemr/docker/nginx/nginx.conf
#      2) run bash ~/demo_farm_openemr/docker/scripts/primeLetsencrypt.sh
#      2) then can uncomment the ssh cert stuff near line 9 in ~/demo_farm_openemr/docker/nginx/nginx.conf and should then work after restart reverse proxy
#  -set up place to store credentials
#      1) mkdir ~/cred
#      2) store sasl_passwd and sasl_passwd.db files in ~/cred to support postfix connection to amazon ses for email
#         - see http://docs.aws.amazon.com/ses/latest/DeveloperGuide/postfix.html for how to create these 2 files
#      3) store the .htpasswd file which is used to control access to the admin web panel for the demo farm
#         - see https://www.1and1.com/cloud-community/learn/web-server/nginx/set-up-password-authentication-with-nginx/ to see how this file is created
#      4) store the pem key to log into the demo farm ec2 instance which is used by the administration web utilities
#      5) store the github key in the github-key file, which is used for composer
#

# Bring in the demo function library
source ~/demo_farm_openemr/docker/scripts/demoLibrary.source

# for building pre-openemr with the Dockerfiles (cd to path with the Dockerfile)
#cd ~/demo_farm_openemr/docker/pre-openemr/16-04/
#docker build -t openemr/pre-openemr:16.04 .
#cd ~/demo_farm_openemr/docker/pre-openemr/18-04/
#docker build -t openemr/pre-openemr:18.04 .
#cd ~/demo_farm_openemr/docker/pre-openemr/20-04/
#docker build -t openemr/pre-openemr:20.04 .
#cd ~/demo_farm_openemr/docker/pre-openemr/20-04-14/
#docker build -t openemr/pre-openemr:20.04-14 .
#cd ~/demo_farm_openemr/docker/pre-openemr/20-04-16/
#docker build -t openemr/pre-openemr:20.04-16 .
#cd ~/demo_farm_openemr/docker/pre-openemr/22-04-16/
#docker build -t openemr/pre-openemr:22.04-16 .
#cd ~/demo_farm_openemr/docker/pre-openemr/22-04-18/
#docker build -t openemr/pre-openemr:22.04-18 .
#cd ~/demo_farm_openemr/docker/pre-openemr/3-10/
#docker build -t openemr/pre-openemr:3.10 .
#cd ~/demo_farm_openemr/docker/pre-openemr/3-11/
#docker build -t openemr/pre-openemr:3.11 .
#cd ~/demo_farm_openemr/docker/pre-openemr/3-12/
#docker build -t openemr/pre-openemr:3.12 .
#cd ~/demo_farm_openemr/docker/pre-openemr/3-13/
#docker build -t openemr/pre-openemr:3.13 .
#cd ~/demo_farm_openemr/docker/pre-openemr/3-13-8/
#docker build -t openemr/pre-openemr:3.13-8 .
#cd ~/demo_farm_openemr/docker/pre-openemr/3-14/
#docker build -t openemr/pre-openemr:3.14 .
#cd ~/demo_farm_openemr/docker/pre-openemr/3-14-8/
#docker build -t openemr/pre-openemr:3.14-8 .
#cd ~/demo_farm_openemr/docker/pre-openemr/3-15/
#docker build -t openemr/pre-openemr:3.15 .
#cd ~/demo_farm_openemr/docker/pre-openemr/3-15-8/
#docker build -t openemr/pre-openemr:3.15-8 .
#cd ~/demo_farm_openemr/docker/pre-openemr/3-16/
#docker build -t openemr/pre-openemr:3.16 .
#cd ~/demo_farm_openemr/docker/pre-openemr/3-17/
#docker build -t openemr/pre-openemr:3.17 .
#cd ~/demo_farm_openemr/docker/pre-openemr/edge/
#docker build -t openemr/pre-openemr:edge .
#cd ~/demo_farm_openemr/docker/php-ssh/
#docker build -t openemr/php-ssh:7.1-fpm-alpine .

# to collect the standard docker images
docker pull nginx
docker pull mariadb:10.6
docker pull phpmyadmin/phpmyadmin

# Always check for a new versions of the custom docker images
# NOTE 14.04 does not work with development OpenEMR since php version is too low,
#      but collecting it in case somebody wishes to make it work with older
#      OpenEMR versions.
docker pull openemr/pre-openemr:16.04
docker pull openemr/pre-openemr:18.04
docker pull openemr/pre-openemr:20.04
docker pull openemr/pre-openemr:20.04-14
docker pull openemr/pre-openemr:20.04-16
docker pull openemr/pre-openemr:22.04-16
docker pull openemr/pre-openemr:22.04-18
docker pull openemr/pre-openemr:3.10
docker pull openemr/pre-openemr:3.11
docker pull openemr/pre-openemr:3.12
docker pull openemr/pre-openemr:3.13
docker pull openemr/pre-openemr:3.13-8
docker pull openemr/pre-openemr:3.14
docker pull openemr/pre-openemr:3.14-8
docker pull openemr/pre-openemr:3.15
docker pull openemr/pre-openemr:3.15-8
docker pull openemr/pre-openemr:3.16
docker pull openemr/pre-openemr:3.17
docker pull openemr/pre-openemr:edge
docker pull openemr/php-ssh:7.1-fpm-alpine

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

# update optional wkhtmltopdf-openemr
cd ~/wkhtmltopdf-openemr
git fetch origin
git pull origin master
cd ~/

# rebuild simple website and copy translations to website
cp -r ~/demo_farm_openemr/docker/html/* ~/html/
cp ~/translations_development_openemr/languageTranslations_utf8.sql ~/html/translations/

# bring in the dockers (note reverse-proxy needs to be done last)
# (also note doing the demo 'four' at end to be more efficient since it will set up 10 subdemos)
# (also note demo 'five' is at beginning since this is the "main" demos)
# (also note placed the `edu` demos docker at the end)
startMysql
startPhpmyadmin
startDemoWrapper "five"
sleep 30m
startDemoWrapper "one"
sleep 5m
startDemoWrapper "two"
sleep 5m
startDemoWrapper "three"
sleep 5m
startDemoWrapper "six"
sleep 5m
startDemoWrapper "seven"
sleep 5m
startDemoWrapper "eight"
sleep 5m
startDemoWrapper "nine"
sleep 5m
startDemoWrapper "ten"
sleep 5m
startDemoWrapper "eleven"
sleep 5m
startDemoWrapper "four"
sleep 5m
startDemoWrapper "edu"
sleep 5m
startPhp
startNginx
