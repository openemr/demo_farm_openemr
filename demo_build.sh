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
if [ -d /var/www/html ]; then
 WEB=/var/www/html
 htmlDirApache=true;
else
 WEB=/var/www
 htmlDirApache=false;
fi
OPENEMR=$WEB/openemr
LOG=$WEB/log/logSetup.txt
GITMAIN=/home/openemr/git
# GIT=$GITMAIN/openemr // Need to instead set this below depending on OPENEMRREPONAME below
GITDEMOFARM=$GITMAIN/demo_farm_openemr
GITDEMOFARMMAP=$GITDEMOFARM/ip_map_branch.txt
if $htmlDirApache ; then
 OPENEMRAPACHECONF=$GITDEMOFARM/openemr-html.conf
else
 OPENEMRAPACHECONF=$GITDEMOFARM/openemr.conf
fi
GITTRANS=$GITMAIN/translations_development_openemr
TRANSSERVEDIR=$WEB/translations
FILESSERVEDIR=$WEB/files
TMPDIR=/tmp/openemr-tmp

# WORDPRESS PATIENT PORTAL VARIABLES
WORDPRESS=$WEB/wordpress
GITDEMOWORDPRESSDEMOWEB=$GITDEMOFARM/wordpress_demo/web/wordpress
GITDEMOWORDPRESSDEMOSQL=$GITDEMOFARM/wordpress_demo/database/wordpress.sql

# PATH OF INSTALL SCRIPT
INST=$OPENEMR/contrib/util/installScripts/InstallerAuto.php
INSTTEMP=$OPENEMR/contrib/util/installScripts/InstallerAutoTemp.php

# Turn off apache to avoid users messing up while setting up
#  (start it again below after install/configure openemr
/etc/init.d/apache2 stop

# Placemarker for installing new needed modules and other config issues
# that arise in the future

# Record start time
timeStart=`date -u`
echo -n "Started Build: "
echo "$timeStart"
echo -n "Started Build: " >> $LOG
echo "$timeStart" >> $LOG

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
# Parse out the repo name and set the $GIT variable
OPENEMRREPOFULLNAME=$(basename "$OPENEMRREPO")
echo -n "git repo full name is "
echo "$OPENEMRREPOFULLNAME"
echo -n "git repo full name is " >> $LOG
echo "$OPENEMRREPOFULLNAME" >> $LOG
OPENEMRREPONAME="${OPENEMRREPOFULLNAME%.*}"
echo -n "git repo name is "
echo "$OPENEMRREPONAME"
echo -n "git repo name is " >> $LOG
echo "$OPENEMRREPONAME" >> $LOG
GIT=$GITMAIN/$OPENEMRREPONAME
echo -n "git repo local path is "
echo "$GIT"
echo -n "git repo local path is " >> $LOG
echo "$GIT" >> $LOG
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
# Grab demo ssh option
ds=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 9`
echo -n "ds option is "
echo "$ds"
echo -n "ds option is " >> $LOG
echo "$ds" >> $LOG
wp=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 10`
echo -n "wp option is "
echo "$wp"
echo -n "wp option is " >> $LOG
echo "$wp" >> $LOG
EXTERNALLINK=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 11`
echo -n "external link is "
echo "$EXTERNALLINK"
echo -n "external link is " >> $LOG
echo "$EXTERNALLINK" >> $LOG
mrp=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 12`
echo -n "mysql p is "
echo "$mrp"
echo -n "mysql p is " >> $LOG
echo "$mrp" >> $LOG

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
# set if using demo sample data
if [ "$dd" == "0"  ]; then
 demoData=false;
else
 demoData=true;
fi
# set if using ssh offsite portal connection
if [ "$ds" == "0"  ]; then
 demoSSH=false;
else
 demoSSH=true;
fi
# set if setting up onsite and wordpress patient portals
if [ "$wp" == "0"  ]; then
 portalsDemo=false;
else
 portalsDemo=true;
fi
# set the mysql r pass string if needed
if [ -z "$mrp" ]; then
 rpassparam=
else
 rpassparam="-p$mrp"
fi

# COLLECT and output demo description
desc=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 13`
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
 git checkout $GITBRANCH
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
#first secure things to stop hackers from placing .htaccess files and secure patient directories
echo "Setting OpenEMR configuration script"
echo "Setting OpenEMR configuration script" >> $LOG
cp $OPENEMRAPACHECONF /etc/apache2/sites-available/openemr.conf
a2ensite openemr.conf >> $LOG
/etc/init.d/apache2 start >> $LOG

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

if [ -f $OPENEMR/interface/modules/zend_modules/config/application.config.php ] ; then
 # This is specifically for Zend code that is currently under development, so it works on the demos.
 chown www-data:www-data $OPENEMR/interface/modules/zend_modules/config/application.config.php
 echo "Configuring Zend file permission: application.config.php"
 echo "Configuring Zend file permission: application.config.php" >> $LOG
fi
#
# Run installer class for the demo (note to avoid malicious use, script is activated by removing an exit command,
#   and the active script is then removed after completion.
sed -e 's@^exit;@ @' <$INST >$INSTTEMP
if $translationsDevelopment ; then
 echo "Using online development translation set"
 echo "Using online development translation set" >> $LOG
 if [ -z "$mrp" ] ; then
  php -f $INSTTEMP development_translations=yes >> $LOG
 else
  php -f $INSTTEMP development_translations=yes rootpass=$mrp >> $LOG
 fi
else
 echo "Using included translation set"
 echo "Using included translation set" >> $LOG
 if [ -z "$mrp" ] ; then
  php -f $INSTTEMP >> $LOG
 else
  php -f $INSTTEMP rootpass=$mrp >> $LOG
 fi
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
  mysql -u root $rpassparam openemr < "$GITDEMOFARM/pieces/$dd"
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

# Set up to allow demo and testing of hl7 labs feature
mkdir $OPENEMR/sites/default/procedure_results
chown -R www-data:www-data $OPENEMR/sites/default/procedure_results

#Security stuff
#1. remove the library/openflashchart/php-ofc-library/ofc_upload_image.php file if it exists
if [ -f $OPENEMR/library/openflashchart/php-ofc-library/ofc_upload_image.php ]; then
 rm -f $OPENEMR/library/openflashchart/php-ofc-library/ofc_upload_image.php
 echo "Removed ofc_upload_image.php file"
 echo "Removed ofc_upload_image.php file" >> $LOG
fi

#set up ssh if this is turned on, which is stored in $ds
if $demoSSH; then
 echo "Setting up $ds ssh"
 echo "Setting up $ds ssh" >> $LOG
 #ensure the file exists
 if [ -f "$GITDEMOFARM/ssh/$ds.zip" ]; then
  cd "$GITDEMOFARM/ssh/"
  unzip "$ds.zip"
  cd "$ds"
  #install openvpn
  apt-get update >> $LOG
  apt-get -y install openvpn >> $LOG
  #initiate up ssh tunnel
  bash connect.sh
  cd ~
  echo "Done setting up $ds ssh"
  echo "Done setting up $ds ssh" >> $LOG
 else
  echo "Error, $ds data does not exist"
  echo "Error, $ds data does not exist" >> $LOG
 fi
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
 if [ -f $TMPDIR/openemr/interface/modules/zend_modules/config/application.config.php ] ; then
  # This is specifically for Zend code that is currently under development(added in version 4.1.3).
  chmod   a+w $TMPDIR/openemr/interface/modules/zend_modules/config/application.config.php
 fi

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

if $portalsDemo; then
 # This will install and set up the wordpress patient portal
 echo "Setting up patient portals"
 echo "Setting up patient portals" >> $LOG

 # Prepare the sql files with the external link
 sed -i 's/demo.open-emr.org:2104/'"$EXTERNALLINK"'/g' "$GITDEMOFARM/pieces/portal_onsite_and_wordpress.sql"
 sed -i 's/demo.open-emr.org:2104/'"$EXTERNALLINK"'/g' "$GITDEMOWORDPRESSDEMOSQL"

 # Install the openemr sql stuff for portals
 mysql -u root $rpassparam openemr < "$GITDEMOFARM/pieces/portal_onsite_and_wordpress.sql"  

 # Install wordpress file stuff
 mkdir -p $WORDPRESS
 cp -r $GITDEMOWORDPRESSDEMOWEB/* $WORDPRESS/

 # Install wordpress database stuff
 mysqladmin -u root $rpassparam create wordpress
 mysql -u root $rpassparam --execute "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY 'wordpress'" wordpress
 mysql -u root $rpassparam wordpress < "$GITDEMOWORDPRESSDEMOSQL"

 # Install Postfix to allow email registration on wordpress patient portal demo
 apt-get update >> $LOG
 debconf-set-selections <<< "postfix postfix/mailname string opensourceemr.com"
 debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
 apt-get -y install postfix >> $LOG

 echo "Done setting up patient portals"
 echo "Done setting up patient portals" >> $LOG
fi

echo "Demo install script is complete"
echo "Demo install script is complete" >> $LOG

# Record end time
timeEnd=`date -u`
echo -n "Completed Build: "
echo "$timeEnd"
echo -n "Completed Build: " >> $LOG
echo "$timeEnd" >> $LOG

