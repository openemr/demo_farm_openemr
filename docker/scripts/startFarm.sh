#!/bin/bash
#

# create aws ami t2.medium ec2 instance with 50GB storage space (can take up lots of storage space)
#  -install docker and git via link:
#  -install mysql-client
# in home directory, clone demo_farm_openemr

# for building pre-openemr-16 with the Dockerfile
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
