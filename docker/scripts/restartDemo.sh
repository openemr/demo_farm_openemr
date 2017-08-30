#!/bin/bash
#
# Copyright (C) 2017 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Script to restart a openemr demo docker
#

# Bring in the demo function library
source ~/demo_farm_openemr/docker/scripts/demoLibrary.source

# Ensure have a correct demo name parameter
if [ "$1" != "one" ] &&
   [ "$1" != "two" ] &&
   [ "$1" != "three" ] &&
   [ "$1" != "four" ] &&
   [ "$1" != "five" ] &&
   [ "$1" != "six" ] &&
   [ "$1" != "seven" ] &&
   [ "$1" != "eight" ]; then
    echo "ERROR, demo name parameter not correct"
    exit 1
fi

# Stop the demo
stopDemo "$1" "hey"

# Start the demos
if [ "$1" == "seven" ]; then
    startDemo "$1" "mysql-openemr" "7.0" "17-04" "17.04"
elif [ "$1" == "eight" ]; then
    startDemo "$1" "mysql-openemr" "7.1" "17-10" "17.10"
else
    startDemo "$1" "mysql-openemr" "7.0" "16-04" "16.04"
fi
