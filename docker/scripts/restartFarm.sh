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
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

bash ~/demo_farm_openemr/docker/scripts/startFarm.sh
