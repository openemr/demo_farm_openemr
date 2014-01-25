#!/bin/sh
# Copyright (C) 2014 Brady Miller <brady@sparmy.com>
#
#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 2 of the License, or
#(at your option) any later version.
#
#This script is for the OpenEMR demo farms
#

# PUBLIC REPOS
OPENEMRREPO=https://github.com/openemr/openemr.git
TRANSLATIONSREPO=https://github.com/openemr/translations_development_openemr.git

# PATH VARIABLES
WEB=/var/www
OPENEMR=$WEB/openemr
LOG=$WEB/log/logSetup.txt
GITMAIN=/home/openemr/git
GIT=$GITMAIN/openemr
GITDEMOFARMMAP=$GITMAIN/demo_farm_openemr/ip_map_branch.txt
GITTRANS=$GITMAIN/translations_development_openemr
TRANSSERVEDIR=$WEB/translations
FILESSERVEDIR=$WEB/files
TMPDIR=/tmp/openemr-tmp

# PATH OF INSTALL SCRIPT
INST=$OPENEMR/contrib/util/installScripts/InstallerAuto.php
INSTTEMP=$OPENEMR/contrib/util/installScripts/InstallerAutoTemp.php

# Turn off apache to avoid users messing up while setting up
#  (start it again below after install/configure openemr
service httpd stop

# Placemarker for installing new needed modules and other config issues
# that arise in the future

# Collect ip address
tempx=`/sbin/ifconfig`
tempy=${tempx#*inet addr:}
IPADDRESS=${tempy%% *}
echo -n "IP ADDRESS is "
echo $IPADDRESS
echo -n "IP ADDRESS is " >> $LOG
echo $IPADDRESS

# COLLECT MAPPED BRANCH AND OPTIONS
# Grab branch
GITBRANCH=${cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 2}
echo -n "git branch is "
echo $GITBRANCH
echo -n "git branch is " >> $LOG
echo $GITBRANCH
# Grab serve development translation set option
sdt=${cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 3}
echo -n "sdt option is "
echo $sdt
echo -n "sdt option is " >> $LOG
echo $sdt
# Grab use development translation set option
udt=${cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 4}
echo -n "udt option is "
echo $udt
echo -n "udt option is " >> $LOG
echo $udt
# Grab serve packages option
sp=${cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 5}
echo -n "sp option is "
echo $sp
echo -n "sp option is " >> $LOG
echo $sp

# SET OPTIONS
# set if serve development translation set
if [ "$sdt" eq 1  ]; then
 translationServe=true;
else
 translationServe=false;
fi
# set if use development translation set
if [ "$udt" eq 1  ]; then
 translationsDevelopment=true;
else
 translationDevelopment=false;
fi
# set if serve packages
if [ "$sp" eq 1  ]; then
 packageServe=true;
else
 packageServe=false;
fi


# COLLECT THE GIT REPO (it should not exist yet, but will check)
if ! [ -d $GITMAIN ]; then
 echo "Downloading the OpenEMR git repository"
 echo "Downloading the OpenEMR git repository" >> $LOG
 mkdir -p $GITMAIN
 cd $GITMAIN
 git clone $OPENEMRREPO
 cd $GIT
 git checkout origin/$GITBRANCH
 cd $GITMAIN
 if $translationServe ; then
  # download the translations git repo and place the set sql file for serving
  git clone $TRANSLATIONSREPO
  mkdir -p $TRANSSERVEDIR
  cp $GITTRANS/languageTranslations_utf8.sql $TRANSSERVEDIR/
 fi
else
 echo "ERROR, The OpenEMR git repository already exist"
 echo "ERROR, The OpenEMR git repository already exist" >> $LOG
fi

# COPY THE GIT REPO OPENEMR COPY TO THE WEB DIRECTOY
echo "Copy git OpenEMR to web directory"
echo "Copy git OpenEMR to web directory" >> $LOG
rm -fr $OPENEMR/*
rsync --recursive --exclude .git $GIT/* $OPENEMR/

#INSTALL AND CONFIGURE OPENEMR
echo "Configuring OpenEMR"
echo "Configuring OpenEMR" >> $LOG
#
# Set file and directory permissions
chmod 666 $OPENEMR/sites/default/sqlconf.php
chown -R apache:apache $OPENEMR/sites/default/documents
chown -R apache:apache $OPENEMR/sites/default/edi
chown -R apache:apache $OPENEMR/sites/default/era
chown -R apache:apache $OPENEMR/library/freeb
chown -R apache:apache $OPENEMR/sites/default/letter_templates
chown -R apache:apache $OPENEMR/interface/main/calendar/modules/PostCalendar/pntemplates/cache
chown -R apache:apache $OPENEMR/interface/main/calendar/modules/PostCalendar/pntemplates/compiled
chown -R apache:apache $OPENEMR/gacl/admin/templates_c
#
# Run installer class for the demo (note to avoid malicious use, script is activated by removing an exit command,
#   and the active script is then removed after completion.
sed -e 's@^exit;@ @' <$INST >$INSTTEMP
if $translationsDevelopment  ; then
 php -f $INSTTEMP development_translations=yes >> $LOG
else
 php -f $INSTTEMP >> $LOG
fi
rm -f $INSTTEMP

#reinstitute file permissions
chmod 644 $OPENEMR/sites/default/sqlconf.php
echo "Done configuring OpenEMR"
echo "Done configuring OpenEMR" >> $LOG

if $packageServe ; then
 #Package the development version into a tarball and zip file to be available thru web browser
 # This is basically to allow download of most recent cvs version from the cvs Demo appliance
 # It will also ease transfer/testing openemr on windows systems when using the Developer appliance
 echo "Creating OpenEMR Development packages"
 echo "Creating OpenEMR Development packages" >> $LOG

 # Prepare the development package
 mkdir -p $TMPDIR/openemr
 rsync --recursive --exclude .git $GIT/* $TMPDIR/openemr/
 chmod    a+w $TMPDIR/openemr/sites/default/sqlconf.php
 chmod -R a+w $TMPDIR/openemr/sites/default/documents
 chmod -R a+w $TMPDIR/openemr/sites/default/edi
 chmod -R a+w $TMPDIR/openemr/sites/default/era
 chmod -R a+w $TMPDIR/openemr/library/freeb
 chmod -R a+w $TMPDIR/openemr/sites/default/letter_templates
 chmod -R a+w $TMPDIR/openemr/interface/main/calendar/modules/PostCalendar/pntemplates/cache
 chmod -R a+w $TMPDIR/openemr/interface/main/calendar/modules/PostCalendar/pntemplates/compiled
 chmod -R a+w $TMPDIR/openemr/gacl/admin/templates_c

 # Create the web file directory
 mkdir $FILESSERVEDIR

 # Save the tar.gz cvs package
 cd $TMPDIR
 rm -f $FILESSERVEDIR/openemr-cvs.tar.gz
 tar -czf $FILESSERVEDIR/openemr-cvs.tar.gz openemr
 cd $FILESSERVEDIR
 md5sum openemr-cvs.tar.gz > openemr-linux-md5.txt

 # Save the .zip cvs package
 cd $TMPDIR
 rm -f $FILESSERVEDIR/openemr-cvs.zip
 zip -rq $FILESSERVEDIR/openemr-cvs.zip openemr
 cd $FILESSERVEDIR
 md5sum openemr-cvs.zip > openemr-windows-md5.txt

 # Create the time stamp
 date > date-cvs.txt

 # Clean up
 rm -fr $TMPDIR
 echo "Done creating OpenEMR Development packages"
 echo "Done creating OpenEMR Development packages" >> $LOG
fi
