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
   [ "$1" != "eight" ] &&
   [ "$1" != "nine" ] &&
   [ "$1" != "ten" ]; then
    echo "ERROR, demo name parameter not correct"
    exit 1
fi

# Stop the demo
stopDemo "$1" "hey"

# Start the demo
startDemoWrapper "$1"

