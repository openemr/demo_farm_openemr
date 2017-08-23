#!/bin/bash
#

# stop and remove all containers
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

bash ~/demo_farm_openemr/docker/scripts/startFarm.sh
