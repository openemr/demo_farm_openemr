#!/bin/bash
#
# Copyright (C) 2021 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Script to snapshot a openemr demo docker
#

# Bring in the demo function library
source ~/demo_farm_openemr/docker/scripts/demoLibrary.source

# Ensure have a correct demo name parameter
if [ "$1" == "one" ] ||
   [ "$1" == "two" ] ||
   [ "$1" == "three" ] ||
   [ "$1" == "four" ] ||
   [ "$1" == "five" ] ||
   [ "$1" == "six" ] ||
   [ "$1" == "seven" ] ||
   [ "$1" == "eight" ] ||
   [ "$1" == "nine" ] ||
   [ "$1" == "ten" ] ||
   [ "$1" == "eleven" ] ||
   [ "$1" == "edu" ]; then

      # Ensure have a correct subname parameter
      if [ "$2" == "empty" ] ||
         [ "$2" == "a" ] ||
         [ "$2" == "b" ] ||
         [ "$2" == "c" ] ||
         [ "$2" == "d" ] ||
         [ "$2" == "e" ] ||
         [ "$2" == "f" ] ||
         [ "$2" == "g" ] ||
         [ "$2" == "h" ] ||
         [ "$2" == "i" ]; then

          # Snap the demo
          snapshotDemo "$1" "$2" hey

      else
          echo "ERROR, demo subname parameter not correct"
          echo 1
      fi

else
    echo "ERROR, demo name parameter not correct"
    exit 1
fi
