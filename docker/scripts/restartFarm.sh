#!/bin/bash
#
# Copyright (C) 2017 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

# stop and remove all containers
#  (except for nginx reverse proxy to ensure 100% uptime of served files)
docker stop one-openemr
docker stop two-openemr
docker stop three-openemr
docker stop four-openemr
docker stop five-openemr
docker stop six-openemr
docker stop phpmyadmin-openemr
docker stop mysql-openemr
docker rm one-openemr
docker rm two-openemr
docker rm three-openemr
docker rm four-openemr
docker rm five-openemr
docker rm six-openemr
docker rm phpmyadmin-openemr
docker rm mysql-openemr

bash ~/demo_farm_openemr/docker/scripts/startFarm.sh
