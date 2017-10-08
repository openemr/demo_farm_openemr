#!/bin/bash
#
# Copyright (C) 2017 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Script to refresh the website
#

# update demo_farm_openemr repo which contains the website
cd ~/demo_farm_openemr
git fetch origin
git pull origin master
cd ~/

# copy over website
cp -r ~/demo_farm_openemr/docker/html/* ~/html/
echo "done refreshing website"

