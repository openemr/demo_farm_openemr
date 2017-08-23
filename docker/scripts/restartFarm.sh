#!/bin/bash
#

docker stop one-openemr
docker stop two-openemr
docker stop three-openemr
docker stop four-openemr
docker stop five-openemr
docker stop six-openemr
docker stop phpmyadmin-openemr
docker stop mysql-openemr
docker stop reverse-proxy
docker rm one-openemr
docker rm two-openemr
docker rm three-openemr
docker rm four-openemr
docker rm five-openemr
docker rm six-openemr
docker rm phpmyadmin-openemr
docker rm mysql-openemr
docker rm reverse-proxy

bash startFarm.sh
