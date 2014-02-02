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

# PUBLIC REPOS (note the openemr repo is mapped in GITDEMOFARMMAP
TRANSLATIONSREPO=https://github.com/openemr/translations_development_openemr.git

# PATH VARIABLES
WEB=/var/www
OPENEMR=$WEB/openemr
LOG=$WEB/log/logSetup.txt
GITMAIN=/home/openemr/git
GIT=$GITMAIN/openemr
GITDEMOFARM=$GITMAIN/demo_farm_openemr
GITDEMOFARMMAP=$GITDEMOFARM/ip_map_branch.txt
GITTRANS=$GITMAIN/translations_development_openemr
TRANSSERVEDIR=$WEB/translations
FILESSERVEDIR=$WEB/files
TMPDIR=/tmp/openemr-tmp

# PATH OF INSTALL SCRIPT
INST=$OPENEMR/contrib/util/installScripts/InstallerAuto.php
INSTTEMP=$OPENEMR/contrib/util/installScripts/InstallerAutoTemp.php

# Turn off apache to avoid users messing up while setting up
#  (start it again below after install/configure openemr
/etc/init.d/apache2 stop

# Placemarker for installing new needed modules and other config issues
# that arise in the future

# Collect ip address
tempx=`/sbin/ifconfig`
tempy=${tempx#*inet addr:}
IPADDRESS=${tempy%% *}
echo -n "IP ADDRESS is "
echo "$IPADDRESS"
echo -n "IP ADDRESS is " >> $LOG
echo "$IPADDRESS" >> $LOG

# COLLECT MAPPED BRANCH AND OPTIONS
# Grab repo link
OPENEMRREPO=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 2`
echo -n "git repo is "
echo "$OPENEMRREPO"
echo -n "git repo is " >> $LOG
echo "$OPENEMRREPO" >> $LOG
# Grab branch
GITBRANCH=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 3`
echo -n "git branch is "
echo "$GITBRANCH"
echo -n "git branch is " >> $LOG
echo "$GITBRANCH" >> $LOG
# Grab serve development translation set option
sdt=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 4`
echo -n "sdt option is "
echo "$sdt"
echo -n "sdt option is " >> $LOG
echo "$sdt" >> $LOG
# Grab use development translation set option
udt=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 5`
echo -n "udt option is "
echo "$udt"
echo -n "udt option is " >> $LOG
echo "$udt" >> $LOG
# Grab serve packages option
sp=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 6`
echo -n "sp option is "
echo "$sp"
echo -n "sp option is " >> $LOG
echo "$sp" >> $LOG
# Grab legacy patching option
lp=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 7`
echo -n "lp option is "
echo "$lp"
echo -n "lp option is " >> $LOG
echo "$lp" >> $LOG
# Grab demo data option
dd=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 8`
echo -n "dd option is "
echo "$dd"
echo -n "dd option is " >> $LOG
echo "$dd" >> $LOG 

# SET OPTIONS
# set if serve development translation set
if [ "$sdt" == "1"  ]; then
 translationServe=true;
else
 translationServe=false;
fi
# set if use development translation set
if [ "$udt" == "1"  ]; then
 translationsDevelopment=true;
else
 translationsDevelopment=false;
fi
# set if serve packages
if [ "$sp" == "1"  ]; then
 packageServe=true;
else
 packageServe=false;
fi
# set if legacy patching
if [ "$lp" == "1"  ]; then
 legacyPatch=true;
else
 legacyPatch=false;
fi
# set if legacy patching
if [ "$dd" == "0"  ]; then
 demoData=false;
else
 demoData=true;
fi

# COLLECT and output demo description
desc=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 9`
echo -n "Demo description: "
echo "$desc"
echo -n "Demo description: " >> $LOG
echo "$desc" >> $LOG

# COLLECT THE GIT REPO (it should not exist yet, but will check)
if ! [ -d $GIT ]; then
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
  echo "Placing OpenEMR Development translation set"
  echo "Placing OpenEMR Development translation set" >> $LOG
  git clone $TRANSLATIONSREPO
  mkdir -p $TRANSSERVEDIR
  cp $GITTRANS/languageTranslations_utf8.sql $TRANSSERVEDIR/
  echo "Done Placing OpenEMR Development translation set"
  echo "Done Placing OpenEMR Development translation set" >> $LOG
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

#restart apache
#need to do this in case same appliance is serving the development translation set
/etc/init.d/apache2 start

#INSTALL AND CONFIGURE OPENEMR
echo "Configuring OpenEMR"
echo "Configuring OpenEMR" >> $LOG
#
# Set file and directory permissions
chmod 666 $OPENEMR/sites/default/sqlconf.php
chown -R www-data:www-data $OPENEMR/sites/default/documents
chown -R www-data:www-data $OPENEMR/sites/default/edi
chown -R www-data:www-data $OPENEMR/sites/default/era
chown -R www-data:www-data $OPENEMR/library/freeb
chown -R www-data:www-data $OPENEMR/sites/default/letter_templates
chown -R www-data:www-data $OPENEMR/interface/main/calendar/modules/PostCalendar/pntemplates/cache
chown -R www-data:www-data $OPENEMR/interface/main/calendar/modules/PostCalendar/pntemplates/compiled
chown -R www-data:www-data $OPENEMR/gacl/admin/templates_c
#
# Run installer class for the demo (note to avoid malicious use, script is activated by removing an exit command,
#   and the active script is then removed after completion.
sed -e 's@^exit;@ @' <$INST >$INSTTEMP
if $translationsDevelopment ; then
 echo "Using online development translation set"
 echo "Using online development translation set" >> $LOG
 php -f $INSTTEMP development_translations=yes >> $LOG
else
 echo "Using included translation set"
 echo "Using included translation set" >> $LOG
 php -f $INSTTEMP >> $LOG
fi
rm -f $INSTTEMP

if $legacyPatch; then
 #Run the patching script to bring in database changes for script via
 # legacy method. (patch branches rel-412 and higher do not need to
 # do this)
 echo "Upgrading via legacy patch"
 echo "Upgrading via legacy patch" >> $LOG
 echo "<?php \$_GET['site'] = 'default'; ?>" > $OPENEMR/TEMPsql_patch.php
 cat $OPENEMR/sql_patch.php >> $OPENEMR/TEMPsql_patch.php
 php -f $OPENEMR/TEMPsql_patch.php >> $LOG
 rm -f $OPENEMR/TEMPsql_patch.php
 echo "Completed upgrading via legacy patch"
 echo "Completed upgrading via legacy patch" >> $LOG
fi

if $demoData; then
 # Need to insert the demo data, which is in $dd item in the pieces directory
 echo "Inserting demo data from $dd"
 echo "Inserting demo data from $dd" >> $LOG
 # First, check to ensure the file exists
 if [ -f "$GITDEMOFARM/pieces/$dd" ]; then
  # Now insert the data
  mysql -u root < "$GITDEMOFARM/pieces/$dd"
  echo "Completed inserting demo data from $dd"
  echo "Completed inserting demo data from $dd" >> $LOG
 else
  echo "Error, $dd data does not exist"
  echo "Error, $dd data does not exist" >> $LOG
 fi
fi

#reinstitute file permissions
chmod 644 $OPENEMR/sites/default/sqlconf.php
echo "Done configuring OpenEMR"
echo "Done configuring OpenEMR" >> $LOG

#Security stuff
#1. remove the library/openflashchart/php-ofc-library/ofc_upload_image.php file if it exists
if [ -f $OPENEMR/library/openflashchart/php-ofc-library/ofc_upload_image.php ]; then
 rm -f $OPENEMR/library/openflashchart/php-ofc-library/ofc_upload_image.php
 echo "Removed ofc_upload_image.php file"
 echo "Removed ofc_upload_image.php file" >> $LOG
fi

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
