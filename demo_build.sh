#!/bin/bash
# Copyright (C) 2014 Brady Miller <brady@sparmy.com>
#
#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 2 of the License, or
#(at your option) any later version.
#
#This script is for the OpenEMR demo farms
#

# === BUILD-TIME TESTING SUPPORT (issue #146) ===============================
# Parse CLI args + set up the action-log emitter that --dry-run mode and the
# fixture-test harness in tools/build-tests/ depend on. None of this is
# load-bearing for production execution: with no flags and no ACTION_LOG env
# var, the helpers degrade to "echo nothing, then exec the command" -- i.e.,
# behave like the previous direct invocations.
#
# Args:
#   --dry-run            Skip side-effecting commands (composer, npm,
#                        mariadb, apk, curl, httpd, postfix, stunnel,
#                        system-path writes). Pure parsing/branching
#                        still runs. Used by tools/build-tests/.
#   <subdemoName>        Optional positional. If present, run a light
#                        reset of just that subdemo (preserves existing
#                        legacy behavior).
#
# Env-var overrides (defaulted to production paths; only set in tests):
#   ACTION_LOG           File path to append ACTION lines to. Default
#                        /dev/null in production -- emitter is a no-op
#                        when not under test.
#   WEB, webUser, GITMAIN, GITDEMOFARM, CAPSULES, OPENEMRTMPDIR
#                        Override hardcoded paths for fixture isolation
#                        (see "PATH VARIABLES" block below).

dryRun=false
lightReset=false
lightResetDemo=""
for _arg in "$@"; do
  case "$_arg" in
    --dry-run) dryRun=true ;;
    --*)
      echo "Unknown flag: $_arg" >&2
      exit 2
      ;;
    *)
      lightReset=true
      lightResetDemo="$_arg"
      ;;
  esac
done
unset _arg

ACTION_LOG="${ACTION_LOG:-/dev/null}"

# _emit_action_log -- internal: read a single line from stdin, redact
# common credential patterns, append to ACTION_LOG. Best-effort: covers
# every credential shape this script currently emits:
#   - mariadb `-p<pass>` from $rpassparam
#   - InstallerAuto `rootpass=<pass>` from $mrp
#   - curl `Authorization: token <github-key>` (rate_limit probe)
#   - composer config `--auth github-oauth.github.com <github-key>`
# In Phase 1 dry-run the github-key values are stubbed to placeholders
# (<DRY_RUN_GITHUB_KEY>) which the `[A-Za-z0-9_]+` body match doesn't
# touch (the `<>` get %q-escaped to `\<\>`). In Phase 2 live runs with
# a real /home/openemr/github-key mounted, the raw token would otherwise
# land in ACTION_LOG — the Authorization / --auth patterns prevent that.
# ACTION_LOG should still be reviewed before being enabled in production.
_emit_action_log () {
  # Anchor the `-p` pattern to start-of-line OR preceded by whitespace
  # so it only matches the standalone mariadb `-p<password>` flag and
  # not the embedded `-p` inside longer flags like `--unsafe-perm`.
  sed -E \
    -e 's/(^|[[:space:]])(-p)[^[:space:]\\]+/\1\2<REDACTED>/g' \
    -e 's/(rootpass=)[^[:space:]\\]+/\1<REDACTED>/g' \
    -e 's/(Authorization:\\ token\\ )[A-Za-z0-9_]+/\1<REDACTED>/g' \
    -e 's/(--auth\\ github-oauth\.github\.com\\ )[A-Za-z0-9_]+/\1<REDACTED>/g' \
    >> "$ACTION_LOG"
}

# run_action <cmd> <arg>... -- argv form. Log a normalized ACTION line, then
# execute the command in live mode or skip in dry-run. Use for commands
# without shell metacharacters (no pipes, no redirects).
run_action () {
  {
    printf 'ACTION:'
    printf ' %q' "$@"
    printf '\n'
  } | _emit_action_log
  if ! $dryRun; then
    "$@"
  fi
}

# run_action_sh <shell-command-string> -- shell form. Log ACTION_SH, then
# eval the string. Use for commands with pipes, redirects, or compound
# logic; variable expansion happens at the call site via double-quoting.
#
# Trust assumption: the wrapped string is built from script-internal
# variables whose values originate in ip_map_branch.txt and the demo-farm
# docker env (DOCKERDEMO, DOCKERMYSQLHOST, etc.) -- not from user input.
# This script is not designed to safely process attacker-controlled values
# in those vars; production callers must ensure ip_map_branch.txt is
# authored by trusted operators and env vars come from the demo-farm
# infrastructure.
run_action_sh () {
  printf 'ACTION_SH: %s\n' "$1" | _emit_action_log
  if ! $dryRun; then
    eval "$1"
  fi
}

# run_action_capture [--stub <value>] <cmd> <arg>... -- log + execute (live)
# or log + emit <value> on stdout (dry-run). Use when the script captures
# command output into a variable: $(run_action_capture ...). The stub keeps
# downstream parsing (jq, conditionals) sane in dry-run mode.
run_action_capture () {
  local _stub=""
  if [ "$1" = "--stub" ]; then
    _stub="$2"
    shift 2
  fi
  {
    printf 'ACTION_CAPTURE:'
    printf ' %q' "$@"
    printf '\n'
  } | _emit_action_log
  if $dryRun; then
    printf '%s\n' "$_stub"
  else
    "$@"
  fi
}
# === END BUILD-TIME TESTING SUPPORT ========================================

# Install demo-farm-specific runtime dependencies that the flex base image
# doesn't bundle. apk add is idempotent — if already installed (e.g., on a
# restartSubdemo re-invocation inside a running container) this is a fast
# no-op rather than an error.
run_action apk add --no-cache postfix stunnel

getRandomThemeOne () {
    if $dryRun; then echo '<RANDOM_THEME_1>'; return; fi
    THEME[0]='style_ash_blue.css'
    THEME[1]='style_burgundy.css'
    THEME[2]='style_cadmium_yellow.css'
    THEME[3]='style_chocolate.css'
    THEME[4]='style_cobalt_blue.css'
    THEME[5]='style_coral.css'
    THEME[6]='style_deep_purple.css'
    THEME[7]='style_dune.css'
    THEME[8]='style_emerald.css'
    THEME[9]='style_forest_green.css'
    THEME[10]='style_mauve.css'
    THEME[11]='style_mustard_green.css'
    THEME[12]='style_olive.css'
    THEME[13]='style_pink.css'
    THEME[14]='style_powder_blue.css'
    THEME[15]='style_red.css'
    THEME[16]='style_sienna.css'
    THEME[17]='style_tangerine.css'
    THEME[18]='style_light.css'
    THEME[19]='style_light.css'
    THEME[20]='style_light.css'
    THEME[21]='style_light.css'
    THEME[22]='style_light.css'
    THEME[23]='style_light.css'
    THEME[24]='style_light.css'
    THEME[25]='style_light.css'
    THEME[26]='style_light.css'
    THEME[27]='style_light.css'
    THEME[28]='style_light.css'
    THEME[29]='style_light.css'
    THEME[30]='style_light.css'
    THEME[31]='style_light.css'
    THEME[32]='style_light.css'
    THEME[33]='style_light.css'
    THEME[34]='style_light.css'
    THEME[35]='style_light.css'

    #choose randomly from 36 choices (0-35)
    RANDOM_THEME_INT=$((RANDOM % 36))

    echo ${THEME[${RANDOM_THEME_INT}]}
}

getRandomThemeTwo () {
    if $dryRun; then echo '<RANDOM_THEME_2>'; return; fi
    THEME[0]='style_cobalt_blue.css'
    THEME[1]='style_forest_green.css'
    THEME[2]='style_light.css'
    THEME[3]='style_dark.css'
    THEME[4]='style_solar.css'
    THEME[5]='style_manila.css'

    #choose randomly from 6 choices (0-5)
    RANDOM_THEME_INT=$((RANDOM % 6))

    echo ${THEME[${RANDOM_THEME_INT}]}
}

#function to collect variables from config files
# 1st param is variable name, 2nd param is filename
collect_var () {
   grep -i "^[[:space:]]*$1[[:space:]=]" "$2" | cut -d = -f 2 | cut -d ';' -f 1 | sed "s/[ 	'\"]//gi"
}

# (lightReset / lightResetDemo are now set by the unified arg parser at the
# top of the script; the legacy "$1" check used to live here.)

# PATH VARIABLES AND CREATED NEEDED DIRS
# Demo farm runs every cluster on the flex (Alpine) base image as of #116,
# so the web root is always Alpine's /var/www/localhost/htdocs.
WEB="${WEB:-/var/www/localhost/htdocs}"
# Web server user: alpine images use 'apache'. Used when dropping privileges
# to run OpenEMR CLI scripts (RootCliGuard in openemr#12267 refuses root).
webUser="${webUser:-apache}"
LOG=$WEB/log/logSetup.txt
mkdir -p $WEB/log

# Expose two static endpoints under <cluster>.openemr.io/log/* that the
# wiki demo pages link to: logPhp.txt (PHP error log) and logSetup.txt
# (this script's own output, written via $LOG below). The pre-openemr
# image used to set this up at image-build time (mkdir + chmod in the
# Dockerfile, error_log directive in a baked-in php.ini); with flex we
# do it at runtime here so flex's normal openemr.sh flow is unaffected.
# PHP_VERSION_ABBR is set by the flex image (e.g. "85" for PHP 8.5).
echo "start log" > $WEB/log/logPhp.txt
chmod 666 $WEB/log/logPhp.txt
run_action_sh "echo 'error_log = $WEB/log/logPhp.txt' > /etc/php${PHP_VERSION_ABBR}/conf.d/99-demo-farm-error-log.ini"
CAPSULES="${CAPSULES:-/home/openemr/capsules}"
GITMAIN="${GITMAIN:-/home/openemr/git}"
GITDEMOFARM="${GITDEMOFARM:-$GITMAIN/demo_farm_openemr}"
# Strip '#' comment lines from ip_map_branch.txt up front so every
# downstream `grep "$IPADDRESS" | cut -f N` lookup ignores them. The
# file uses commented section headers (Production / UP FOR GRABS /
# master / release / parked) to keep groups visually organized.
GITDEMOFARMMAP_SRC=$GITDEMOFARM/ip_map_branch.txt
GITDEMOFARMMAP=$(mktemp)
grep -v '^#' "$GITDEMOFARMMAP_SRC" > "$GITDEMOFARMMAP"
PASSWORDRESETSCRIPT=$GITDEMOFARM/set_pass.php
OPENEMRAPACHECONF=$GITDEMOFARM/openemr-alpine.conf
GITTRANS=$GITMAIN/translations_development_openemr
# OPENEMRTMPDIR (vs TMPDIR(1), used implicitly by mktemp et al.) overrides
# the staging directory for the openemr CVS package built in the packageServe
# branch. Production default matches pre-refactor behavior.
TMPDIR="${OPENEMRTMPDIR:-/tmp/openemr-tmp}"

if $lightReset; then
 echo "This is a light reset"
 echo "This is a light reset" >> $LOG
fi

# Note: Apache is not running yet in alpine, so no need to stop it here.
# (It is started below after complete setup.)

# Record start time
timeStart=`date -u`
echo -n "Started Build: "
echo "$timeStart"
echo -n "Started Build: " >> $LOG
echo "$timeStart" >> $LOG

if $lightReset; then
 demosGo=("$lightResetDemo")
 echo -n "subdemo reset mode for: "
 echo "$lightResetDemo"
 echo -n "subdemo reset mode for: " >> $LOG
 echo "$lightResetDemo"
elif [ "$DOCKERNUMBERDEMOS" == "10" ]; then
 demosGo=("empty" "a" "b" "c" "d" "e" "f" "g" "h" "i")
 echo "10 demos mode"
 echo "10 demos mode" >> $LOG
elif [ "$DOCKERNUMBERDEMOS" == "9" ]; then
 demosGo=("empty" "a" "b" "c" "d" "e" "f" "g" "h")
 echo "9 demos mode"
 echo "9 demos mode" >> $LOG
elif [ "$DOCKERNUMBERDEMOS" == "8" ]; then
 demosGo=("empty" "a" "b" "c" "d" "e" "f" "g")
 echo "8 demos mode"
 echo "8 demos mode" >> $LOG
elif [ "$DOCKERNUMBERDEMOS" == "7" ]; then
 demosGo=("empty" "a" "b" "c" "d" "e" "f")
 echo "7 demos mode"
 echo "7 demos mode" >> $LOG
elif [ "$DOCKERNUMBERDEMOS" == "6" ]; then
 demosGo=("empty" "a" "b" "c" "d" "e")
 echo "6 demos mode"
 echo "6 demos mode" >> $LOG
elif [ "$DOCKERNUMBERDEMOS" == "5" ]; then
 demosGo=("empty" "a" "b" "c" "d")
 echo "5 demos mode"
 echo "5 demos mode" >> $LOG
elif [ "$DOCKERNUMBERDEMOS" == "4" ]; then
 demosGo=("empty" "a" "b" "c")
 echo "4 demos mode"
 echo "4 demos mode" >> $LOG
elif [ "$DOCKERNUMBERDEMOS" == "3" ]; then
 demosGo=("empty" "a" "b")
 echo "3 demos mode"
 echo "3 demos mode" >> $LOG
elif [ "$DOCKERNUMBERDEMOS" == "2" ]; then
 demosGo=("empty" "a")
 echo "2 demos mode"
 echo "2 demos mode" >> $LOG
else
 demosGo=("empty")
 echo "Single demo mode"
 echo "Single demo mode" >> $LOG
fi

DOCKERDEMOORIGINAL=$DOCKERDEMO

for demo in "${demosGo[@]}"
do

 if [ "$demo" == "empty" ]; then
  OPENEMR=$WEB/openemr
  FILESSERVEDIR=$WEB/files
  DOCKERDEMO=$DOCKERDEMOORIGINAL
  FINALWEB=$WEB
 else
  DOCKERDEMO=${DOCKERDEMOORIGINAL}_${demo}
  OPENEMR=${WEB}/${demo}/openemr
  FILESSERVEDIR=$WEB/${demo}/files
  FINALWEB=$WEB/${demo}
 fi

 # Collect ip address or docker demo number
echo -n "Docker Demo is "
echo "$DOCKERDEMO"
echo -n "Docker Demo is " >> $LOG
echo "$DOCKERDEMO" >> $LOG
IPADDRESS=$DOCKERDEMO

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
 # Grab demo data option
 dd=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 8`
 echo -n "dd option is "
 echo "$dd"
 echo -n "dd option is " >> $LOG
 echo "$dd" >> $LOG
 ppapi=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 10`
 echo -n "ppapi option is "
 echo "$ppapi"
 echo -n "ppapi option is " >> $LOG
 echo "$ppapi" >> $LOG
 EXTERNALLINK=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 11`
 echo -n "external link is "
 echo "$EXTERNALLINK"
 echo -n "external link is " >> $LOG
 echo "$EXTERNALLINK" >> $LOG
 mrp=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 12`
 echo -n "mariadb p is "
 echo "$mrp"
 echo -n "mariadb p is " >> $LOG
 echo "$mrp" >> $LOG
 # col 13 (branch_tag) is deprecated; col position preserved with value "0".
 # demo_build.sh no longer reads it -- the clone below uses
 # `git clone --branch <ref> --depth 1` which works for both branches and tags.
 ddu=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 14`
 echo -n "ddu option is "
 echo "$ddu"
 echo -n "ddu option is " >> $LOG
 echo "$ddu" >> $LOG
 funStuff=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 15`
 echo -n "funStuff option is "
 echo "$funStuff"
 echo -n "funStuff option is " >> $LOG
 echo "$funStuff" >> $LOG
 passReset=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 16`
 echo -n "passReset option is "
 echo "$passReset"
 echo -n "passReset option is " >> $LOG
 echo "$passReset" >> $LOG
 useCapsule=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 17`
 echo -n "useCapsule option is "
 echo "$useCapsule"
 echo -n "useCapsule option is " >> $LOG
 echo "$useCapsule" >> $LOG

 # SET OPTIONS
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
 # set if using demo sample data
 if [ "$dd" == "0"  ]; then
  demoData=false;
 else
  demoData=true;
 fi
 # set the mariadb r pass string if needed
 if [ -z "$mrp" ]; then
  rpassparam=
 else
  rpassparam="-p$mrp"
 fi
 # set if doing a demo data upgrade (specific feature to support demo data on most recent codebase)
 if [ "$ddu" == "0" ]; then
  demoDataUpgrade=false;
 else
  demoDataUpgrade=true;
  demoDataUpgradeFrom="$ddu"
 fi
 # set if doing fun stuff (now 1 will support random theme)
 if [ "$funStuff" == "0" ]; then
  randomTheme=false;
 else
  randomTheme=true;
 fi
 # set if doing password reset
 # (if 1, then will reset just admin, if 2, then will reset all the official demo users)
 if [ "$passReset" == "0" ]; then
  passResetAuto=false;
 else
  passResetAuto=true;
 fi
 # set if using a capsule
 if [ "$useCapsule" == "0" ]; then
  useCapsuleBoolean=false;
 else
  useCapsuleBoolean=true;
  useCapsuleFile="$useCapsule"
 fi

 # COLLECT and output demo description
 desc=`cat $GITDEMOFARMMAP | grep "$IPADDRESS" | tr -d '\n' | cut -f 18`
 echo -n "Demo description: "
 echo "$desc"
 echo -n "Demo description: " >> $LOG
 echo "$desc" >> $LOG

 # COLLECT THE GIT REPO (it should not exist yet, but will check)
 if ! [ -d $GIT ]; then
  echo "Downloading the OpenEMR git repository"
  echo "Downloading the OpenEMR git repository" >> $LOG
  mkdir -p $GITMAIN
  cd $GITMAIN || exit 1
  # `--branch <ref>` accepts both branch names and tag names; combined with
  # `--depth 1` this gives a shallow clone of the exact ref.
  run_action git clone --branch "$GITBRANCH" --depth 1 "$OPENEMRREPO"
 else
  echo "ERROR, The OpenEMR git repository already exist"
  echo "ERROR, The OpenEMR git repository already exist" >> $LOG
 fi

 # COPY THE GIT REPO OPENEMR COPY TO THE WEB DIRECTOY
 echo "Copy git OpenEMR to web directory"
 echo "Copy git OpenEMR to web directory" >> $LOG
 mkdir -p $OPENEMR
 run_action_sh "rm -fr \"${OPENEMR:?}\"/*"
 run_action_sh "rsync --recursive --exclude .git $GIT/* $OPENEMR/"
 if ! $packageServe; then
   run_action rm -fr "${GIT:?}"
 fi

 #INSTALL AND CONFIGURE OPENEMR
 echo "Configuring OpenEMR"
 echo "Configuring OpenEMR" >> $LOG
 #
 # Set file and directory permissions
 run_action chmod 666 $OPENEMR/sites/default/sqlconf.php
 run_action chmod -R a+w $OPENEMR/sites/default/documents

 if [ -f $OPENEMR/interface/modules/zend_modules/config/application.config.php ] ; then
  # This is specifically for Zend code that is currently under development, so it works on the demos.
  run_action chmod a+w $OPENEMR/interface/modules/zend_modules/config/application.config.php
  echo "Configuring Zend file permission: application.config.php"
  echo "Configuring Zend file permission: application.config.php" >> $LOG
 fi

 #Build openemr package
 if [ ! -d $OPENEMR/vendor ]; then
  cd $OPENEMR || exit 1

  # install php dependencies. In dry-run we stub a fake key and a rate-limit
  # of 0 so the "Not using composer github api token" branch is exercised
  # deterministically (the other branch would log the real github key).
  GITHUB_KEY_COMPOSER=$(run_action_capture --stub '<DRY_RUN_GITHUB_KEY>' cat /home/openemr/github-key)
  githubTokenRateLimitRequest=$(run_action_capture --stub '{"rate":{"remaining":0}}' curl -H "Authorization: token $GITHUB_KEY_COMPOSER" https://api.github.com/rate_limit)
  githubTokenRateLimit=`echo $githubTokenRateLimitRequest | jq '.rate.remaining'`
  echo "Number of github api requests remaining is $githubTokenRateLimit"
  echo "Number of github api requests remaining is $githubTokenRateLimit" >> $LOG
  if [ "$githubTokenRateLimit" -gt 1000 ]; then
   echo "Using composer github api token"
   echo "Using composer github api token" >> $LOG
   run_action composer config --global --auth github-oauth.github.com $GITHUB_KEY_COMPOSER
  else
   echo "Not using composer github api token"
   echo "Not using composer github api token" >> $LOG
  fi
  run_action_sh "composer install --no-dev &>> $LOG"

  if [ -f $OPENEMR/package.json ]; then
   # install frontend dependencies (need unsafe-perm to run as root)
   run_action_sh "npm install --unsafe-perm &>> $LOG"
   # build css
   run_action_sh "npm run build &>> $LOG"
  fi

  if [ -f $OPENEMR/ccdaservice/package.json ]; then
   # install ccdaservice dependencies (need unsafe-perm to run as root)
   cd $OPENEMR/ccdaservice || exit 1
   run_action_sh "npm install --unsafe-perm &>> $LOG"
   cd $OPENEMR || exit 1
  fi

  # clean up
  run_action_sh "composer global require phing/phing &>> $LOG"
  run_action_sh "/root/.composer/vendor/bin/phing vendor-clean &>> $LOG"
  run_action_sh "/root/.composer/vendor/bin/phing assets-clean &>> $LOG"
  run_action_sh "composer global remove phing/phing &>> $LOG"

  # optimize
  run_action_sh "composer dump-autoload -o &>> $LOG"
 fi

 #
 # Run installer class for the demo.
 # Note: To avoid malicious use, the script must be activated first.
 #       Newer versions of the script are activated with the env var.
 #       Older versions are activated by the sed.
 #       The activation methods are cross-compatible.
 export OPENEMR_ENABLE_INSTALLER_AUTO=1
 INST=$OPENEMR/contrib/util/installScripts/InstallerAuto.php
 INSTTEMP=$OPENEMR/contrib/util/installScripts/InstallerAutoTemp.php
 run_action_sh "sed -e 's@^exit;@ @' <$INST >$INSTTEMP"
 DOCKERPARAMETERS="server=${DOCKERMYSQLHOST} loginhost=% login=${DOCKERDEMO} pass=${DOCKERDEMO} dbname=${DOCKERDEMO}"

 # Drop privileges to the web user: RootCliGuard refuses root for the Installer class (openemr#12267).
 if $translationsDevelopment ; then
  echo "Using online development translation set"
  echo "Using online development translation set" >> $LOG
  if [ -z "$mrp" ] ; then
   run_action_sh "su -p -s /bin/sh \"$webUser\" -c \"php -f $INSTTEMP development_translations=yes $DOCKERPARAMETERS\" >> $LOG"
  else
   run_action_sh "su -p -s /bin/sh \"$webUser\" -c \"php -f $INSTTEMP development_translations=yes rootpass=$mrp $DOCKERPARAMETERS\" >> $LOG"
  fi
 else
  echo "Using included translation set"
  echo "Using included translation set" >> $LOG
  if [ -z "$mrp" ] ; then
   run_action_sh "su -p -s /bin/sh \"$webUser\" -c \"php -f $INSTTEMP $DOCKERPARAMETERS\" >> $LOG"
  else
   run_action_sh "su -p -s /bin/sh \"$webUser\" -c \"php -f $INSTTEMP rootpass=$mrp $DOCKERPARAMETERS\" >> $LOG"
  fi
 fi
 run_action rm -f $INSTTEMP

 if $demoData; then
  # Need to insert the demo data, which is in $dd item in the pieces directory
  echo "Inserting demo data from $dd"
  echo "Inserting demo data from $dd" >> $LOG
  # First, check to ensure the file exists
  if [ -f "$GITDEMOFARM/pieces/$dd" ]; then
    # Now insert the data
    #  -Note need to first clear the current database (can make this an option in future if need to add data without clearing database)
    run_action_sh "mariadb-dump --skip-ssl -h $DOCKERMYSQLHOST -u root $rpassparam --add-drop-table --no-data $DOCKERDEMO | grep ^DROP | awk ' BEGIN { print \"SET FOREIGN_KEY_CHECKS=0;\" } { print \$0 } END { print \"SET FOREIGN_KEY_CHECKS=1;\" } ' | mariadb --skip-ssl -h $DOCKERMYSQLHOST -u root $rpassparam $DOCKERDEMO"
    run_action_sh "mariadb --skip-ssl -h $DOCKERMYSQLHOST -u root $rpassparam $DOCKERDEMO < \"$GITDEMOFARM/pieces/$dd\""
    echo "Completed inserting demo data from $dd"
    echo "Completed inserting demo data from $dd" >> $LOG
  else
   echo "Error, $dd data does not exist"
   echo "Error, $dd data does not exist" >> $LOG
  fi
  if $demoDataUpgrade; then
   # Run the sql upgrade script. This allows using demo data on most recent codebase.
   echo "Upgrading demo data from $demoDataUpgradeFrom"
   echo "Upgrading demo data from $demoDataUpgradeFrom" >> $LOG
   run_action_sh "sed -e \"s@!empty(\\\$_POST\\['form_submit'\\])@true@\" <$OPENEMR/sql_upgrade.php >$OPENEMR/sql_upgrade_temp.php"
   run_action_sh "sed -i \"s@\\\$form_old_version = \\\$_POST\\['form_old_version'\\];@\\\$form_old_version = '${demoDataUpgradeFrom}';@\" $OPENEMR/sql_upgrade_temp.php"
   run_action_sh "sed -i \"1s@^@<?php \\\$_GET['site'] = 'default'; ?>@\" $OPENEMR/sql_upgrade_temp.php"
   # Drop privileges to the web user: RootCliGuard (openemr#12267) refuses root for OpenEMR CLI scripts.
   run_action_sh "su -p -s /bin/sh \"$webUser\" -c \"php -f $OPENEMR/sql_upgrade_temp.php\" >> $LOG"
   run_action rm -f $OPENEMR/sql_upgrade_temp.php
   # Also need to change encoding/collation when using OpenEMR versions at 6 or greater
   VERSION_MAJOR=$(collect_var \$v_major $OPENEMR/version.php)
   if [ -n "$VERSION_MAJOR" ] && [ "$VERSION_MAJOR" -ge "6" ]; then
    echo "Upgrading database/collation to utf8mbf since using version ${VERSION_MAJOR}"
    echo "Upgrading database/collation to utf8mbf since using version ${VERSION_MAJOR}" >> $LOG
     run_action_sh "mariadb --skip-ssl -h $DOCKERMYSQLHOST -u root $rpassparam -e 'SELECT concat(\"ALTER DATABASE \`\",TABLE_SCHEMA,\"\` CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci;\") as _sql FROM \`information_schema\`.\`TABLES\` where \`TABLE_SCHEMA\` like \"'\"${DOCKERDEMO}\"'\" and \`TABLE_TYPE\`=\"BASE TABLE\" group by \`TABLE_SCHEMA\`;' | egrep '^ALTER' | mariadb --skip-ssl -h $DOCKERMYSQLHOST -u root $rpassparam"
     run_action_sh "mariadb --skip-ssl -h $DOCKERMYSQLHOST -u root $rpassparam -e 'SELECT concat(\"ALTER TABLE \`\",TABLE_SCHEMA,\"\`.\`\",TABLE_NAME,\"\` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;\") as _sql FROM \`information_schema\`.\`TABLES\` where \`TABLE_SCHEMA\` like \"'\"${DOCKERDEMO}\"'\" and \`TABLE_TYPE\`=\"BASE TABLE\" group by \`TABLE_SCHEMA\`, \`TABLE_NAME\`;' | egrep '^ALTER' | mariadb --skip-ssl -h $DOCKERMYSQLHOST -u root $rpassparam"
   fi
  fi
  if $translationsDevelopment ; then
   # Need to bring the development translations back in (only can support this in docker mode)
    echo "TODO: Need to support bringing in the translations here in the future"
    echo "TODO: Need to support bringing in the translations here in the future" >> $LOG
    # below is way to slow; need to figure out how to get the innodb optimizations in here (as do in main codebase inserts)
    # plan to make a temp file in /home/openemr/temp/languageTranslations_utf8_temp.sql and modify it for the innodb optimizations
    # mariadb --skip-ssl -h $DOCKERMYSQLHOST -u root $rpassparam $DOCKERDEMO < /home/openemr/git/translations_development_openemr/languageTranslations_utf8.sql
  fi
 fi

 if $useCapsuleBoolean; then
  # Defensive: capsule file must be a non-empty flat segment (no slashes,
  # not "." or ".."). Source is ip_map_branch.txt's capsule column; this
  # guards against typos or malicious edits that could turn the later
  # `rm -fr "${OPENEMR:?}/${useCapsuleFile}"` into something destructive
  # like `rm -fr "${OPENEMR:?}/"` (empty) or path traversal via `..`.
  case "$useCapsuleFile" in
   '' | */* | . | ..)
    echo "ERROR: invalid useCapsuleFile value: '$useCapsuleFile' (must be a non-empty flat segment with no slashes or .. traversal)" | tee -a $LOG >&2
    exit 1
    ;;
  esac
  # load the capsule
  echo "Load $useCapsuleFile capsule"
  echo "Load $useCapsuleFile capsule" >> $LOG
  # First, check to ensure the capsule exists
  if [ -f "$CAPSULES/${useCapsuleFile}.tgz" ]; then
   # ensure unpackaged directory is cleared prior to using
   run_action rm -fr "${OPENEMR:?}/${useCapsuleFile}"
   run_action cp "$CAPSULES/${useCapsuleFile}.tgz" "$OPENEMR/"
   run_action tar -xzf "${useCapsuleFile}.tgz"
   # Note need to first clear the current database
   run_action_sh "mariadb-dump --skip-ssl -h $DOCKERMYSQLHOST -u root $rpassparam --add-drop-table --no-data $DOCKERDEMO | grep ^DROP | awk ' BEGIN { print \"SET FOREIGN_KEY_CHECKS=0;\" } { print \$0 } END { print \"SET FOREIGN_KEY_CHECKS=1;\" } ' | mariadb --skip-ssl -h $DOCKERMYSQLHOST -u root $rpassparam $DOCKERDEMO"
   run_action_sh "mariadb --skip-ssl -h $DOCKERMYSQLHOST -u root $rpassparam $DOCKERDEMO < \"$OPENEMR/${useCapsuleFile}/backup.sql\""
   run_action cp "$OPENEMR/sites/default/sqlconf.php" "$OPENEMR/"
   run_action rsync --delete --recursive --links "$OPENEMR/${useCapsuleFile}/sites" "$OPENEMR/"
   run_action cp "$OPENEMR/sqlconf.php" "$OPENEMR/sites/default/sqlconf.php"
   run_action rm "$OPENEMR/sqlconf.php"
   run_action chmod -R a+w $OPENEMR/sites/default/documents
   if [ -f "$OPENEMR/sites/default/documents/certificates/oaprivate.key" ]; then
    # this file needs special treatment in the alpine demo dockers to work correctly
    run_action chmod 640 "$OPENEMR/sites/default/documents/certificates/oaprivate.key"
    run_action chown apache:apache "$OPENEMR/sites/default/documents/certificates/oaprivate.key"
   fi
   if [ -f "$OPENEMR/sites/default/documents/certificates/oapublic.key" ]; then
    # this file needs special treatment in the alpine demo dockers to work correctly
    run_action chmod 660 "$OPENEMR/sites/default/documents/certificates/oapublic.key"
    run_action chown apache:apache "$OPENEMR/sites/default/documents/certificates/oapublic.key"
   fi
   # clear unpackaged directory
   run_action rm -fr "${OPENEMR:?}/${useCapsuleFile}"
   if $demoDataUpgrade; then
    # Run the sql upgrade script. This allows using capsule on most recent codebase.
    echo "Upgrading capsule from $demoDataUpgradeFrom"
    echo "Upgrading capsule from $demoDataUpgradeFrom" >> $LOG
    run_action_sh "sed -e \"s@!empty(\\\$_POST\\['form_submit'\\])@true@\" <$OPENEMR/sql_upgrade.php >$OPENEMR/sql_upgrade_temp.php"
    run_action_sh "sed -i \"s@\\\$form_old_version = \\\$_POST\\['form_old_version'\\];@\\\$form_old_version = '${demoDataUpgradeFrom}';@\" $OPENEMR/sql_upgrade_temp.php"
    run_action_sh "sed -i \"1s@^@<?php \\\$_GET['site'] = 'default'; ?>@\" $OPENEMR/sql_upgrade_temp.php"
    # Drop privileges to the web user: RootCliGuard (openemr#12267) refuses root for OpenEMR CLI scripts.
    run_action_sh "su -p -s /bin/sh \"$webUser\" -c \"php -f $OPENEMR/sql_upgrade_temp.php\" >> $LOG"
    run_action rm -f $OPENEMR/sql_upgrade_temp.php
   fi
  else
   echo "ERROR: $useCapsuleFile capsule did not exist, so could not use"
   echo "ERROR: $useCapsuleFile capsule did not exist, so could not use" >> $LOG
  fi
 fi

 #set up external link in global
 EXTERNALLINKBASE=$(echo "$EXTERNALLINK" | cut -d '/' -f 1)
 run_action mariadb --skip-ssl -h "$DOCKERMYSQLHOST" -u root $rpassparam -e "UPDATE ${DOCKERDEMO}.globals SET gl_value='https://${EXTERNALLINKBASE}' WHERE gl_name='site_addr_oath'"

 #random theme generator
 if $randomTheme; then
  #collect the random theme

  if [ "$funStuff" == "2" ]; then
   RANDOM_THEME=`getRandomThemeTwo`
  else # "$funStuff" == "1"
   RANDOM_THEME=`getRandomThemeOne`
  fi
  echo -n "random theme is "
  echo "$RANDOM_THEME"
  echo -n "random theme is " >> $LOG
  echo "$RANDOM_THEME" >> $LOG
  #set the random theme
  run_action mariadb --skip-ssl -h "$DOCKERMYSQLHOST" -u root $rpassparam -e "UPDATE ${DOCKERDEMO}.globals SET gl_value='${RANDOM_THEME}' WHERE gl_name='css_header'"
 fi

 # Enable patient portal + REST/FHIR/OAuth APIs for demos with the
 # patient_portals_and_api flag set in ip_map_branch.txt.
 if [ "$ppapi" = "1" ]; then
  echo "Setting up patient portal and API globals"
  echo "Setting up patient portal and API globals" >> $LOG
  run_action mariadb --skip-ssl -h "$DOCKERMYSQLHOST" -u root $rpassparam -e "
    UPDATE ${DOCKERDEMO}.globals SET gl_value='1' WHERE gl_name='portal_onsite_two_enable';
    UPDATE ${DOCKERDEMO}.globals SET gl_value='1' WHERE gl_name='rest_api';
    UPDATE ${DOCKERDEMO}.globals SET gl_value='1' WHERE gl_name='rest_fhir_api';
    UPDATE ${DOCKERDEMO}.globals SET gl_value='1' WHERE gl_name='rest_portal_api';
    UPDATE ${DOCKERDEMO}.globals SET gl_value='3' WHERE gl_name='oauth_password_grant';
    UPDATE ${DOCKERDEMO}.globals SET gl_value='1' WHERE gl_name='rest_system_scopes_api';
    UPDATE ${DOCKERDEMO}.globals SET gl_value='3' WHERE gl_name='ccda_alt_service_enable';
  "
 fi

 #reinstitute file permissions
 run_action chmod 644 $OPENEMR/sites/default/sqlconf.php
 echo "Done configuring OpenEMR"
 echo "Done configuring OpenEMR" >> $LOG

 # Set up to allow demo and testing of hl7 labs feature
 run_action mkdir $OPENEMR/sites/default/procedure_results
 run_action chmod -R a+w $OPENEMR/sites/default/procedure_results

 # Set up swagger api to work
 if [ -f $OPENEMR/swagger/openemr-api.yaml ]; then
  echo "Setting up swagger api"
  echo "Setting up swagger api" >> $LOG
  if [ "$demo" == "empty" ]; then
    demoPath=""
  else
    demoPath="/${demo}"
  fi
  run_action sed -i "s@/apis/default/@${demoPath}/openemr/apis/default/@" $OPENEMR/swagger/openemr-api.yaml
  run_action sed -i "s@/oauth2/default/authorize@${demoPath}/openemr/oauth2/default/authorize@" $OPENEMR/swagger/openemr-api.yaml
  run_action sed -i "s@/oauth2/default/token@${demoPath}/openemr/oauth2/default/token@" $OPENEMR/swagger/openemr-api.yaml
 fi

 #Security stuff
 #1. remove the library/openflashchart/php-ofc-library/ofc_upload_image.php file if it exists
 if [ -f $OPENEMR/library/openflashchart/php-ofc-library/ofc_upload_image.php ]; then
  run_action rm -f $OPENEMR/library/openflashchart/php-ofc-library/ofc_upload_image.php
  echo "Removed ofc_upload_image.php file"
  echo "Removed ofc_upload_image.php file" >> $LOG
 fi
 
 if $packageServe ; then
  # Package the development version into a tarball and zip file to be
  # available thru web browser (useful for testing on Windows etc.).
  echo "Creating OpenEMR Development packages"
  echo "Creating OpenEMR Development packages" >> $LOG

  # Prepare the development package. mkdir is intentionally unwrapped:
  # subsequent `cd $TMPDIR/openemr` needs the directory to exist even in
  # dry-run, where the rsync below is skipped. Matches the same pattern
  # used for $WEB/log and $OPENEMR earlier in the script.
  mkdir -p $TMPDIR/openemr
  run_action_sh "rsync --recursive --exclude .git $GIT/* $TMPDIR/openemr/"
  #Build openemr package
  if [ ! -d $TMPDIR/openemr/vendor ]; then
   cd $TMPDIR/openemr || exit 1

   # install php dependencies (see twin block above for the dry-run stub rationale)
   GITHUB_KEY_COMPOSER=$(run_action_capture --stub '<DRY_RUN_GITHUB_KEY>' cat /home/openemr/github-key)
   githubTokenRateLimitRequestPackage=$(run_action_capture --stub '{"rate":{"remaining":0}}' curl -H "Authorization: token $GITHUB_KEY_COMPOSER" https://api.github.com/rate_limit)
   githubTokenRateLimitPackage=`echo $githubTokenRateLimitRequestPackage | jq '.rate.remaining'`
   echo "Number of github api requests remaining is $githubTokenRateLimitPackage"
   echo "Number of github api requests remaining is $githubTokenRateLimitPackage" >> $LOG
   if [ "$githubTokenRateLimitPackage" -gt 1000 ]; then
    echo "Using composer github api token"
    echo "Using composer github api token" >> $LOG
    run_action composer config --global --auth github-oauth.github.com $GITHUB_KEY_COMPOSER
   else
    echo "Not using composer github api token"
    echo "Not using composer github api token" >> $LOG
   fi
   run_action_sh "composer install --no-dev &>> $LOG"

   if [ -f $TMPDIR/openemr/package.json ]; then
    # install frontend dependencies (need unsafe-perm to run as root)
    run_action_sh "npm install --unsafe-perm &>> $LOG"
    # build css
    run_action_sh "npm run build &>> $LOG"
   fi

   # clean up
   run_action_sh "composer global require phing/phing &>> $LOG"
   run_action_sh "/root/.composer/vendor/bin/phing vendor-clean &>> $LOG"
   run_action_sh "/root/.composer/vendor/bin/phing assets-clean &>> $LOG"
   run_action_sh "composer global remove phing/phing &>> $LOG"

   # remove the node_modules directory
   run_action_sh "rm -fr \"${TMPDIR:?}/openemr/node_modules\" &>> \"$LOG\""

   # optimize
   run_action_sh "composer dump-autoload -o &>> $LOG"
  fi
  run_action chmod a+w $TMPDIR/openemr/sites/default/sqlconf.php
  run_action chmod -R a+w $TMPDIR/openemr/sites/default/documents
  if [ -f $TMPDIR/openemr/interface/modules/zend_modules/config/application.config.php ] ; then
   # This is specifically for Zend code that is currently under development(added in version 4.1.3).
   run_action chmod a+w $TMPDIR/openemr/interface/modules/zend_modules/config/application.config.php
  fi

  # Create the web file directory. Unwrapped: subsequent `cd $FILESSERVEDIR`
  # needs the dir to exist in dry-run, where the tar/zip/md5sum writes
  # below are all skipped.
  mkdir $FILESSERVEDIR

  # Save the tar.gz cvs package
  cd $TMPDIR || exit 1
  run_action rm -f $FILESSERVEDIR/openemr-cvs.tar.gz
  run_action tar -czf $FILESSERVEDIR/openemr-cvs.tar.gz openemr
  cd $FILESSERVEDIR || exit 1
  run_action_sh "md5sum openemr-cvs.tar.gz > openemr-linux-md5.txt"

  # Save the .zip cvs package
  cd $TMPDIR || exit 1
  run_action rm -f $FILESSERVEDIR/openemr-cvs.zip
  run_action zip -rq $FILESSERVEDIR/openemr-cvs.zip openemr
  cd $FILESSERVEDIR || exit 1
  run_action_sh "md5sum openemr-cvs.zip > openemr-windows-md5.txt"

  # Create the time stamp
  run_action_sh "date > date-cvs.txt"

  # Clean up
  run_action rm -fr "${TMPDIR:?}"
  run_action rm -fr "${GIT:?}"
  echo "Done creating OpenEMR Development packages"
  echo "Done creating OpenEMR Development packages" >> $LOG
 fi

 #if $passResetAuto; then
  # run the auto reset password script every 5 minutes
  #nohup php -f ${PASSWORDRESETSCRIPT} ${FINALWEB} 300 ${passReset} >/dev/null 2>&1 &
 #fi
done

# Start Postfix for restarts, uses stunnel to communicate to aws ses email server.
if ! $lightReset; then
  run_action_sh "stunnel /etc/stunnel/stunnel.conf >> $LOG"
  run_action_sh "postfix start >> $LOG"
fi

#restart apache and secure sensitive directories
if ! $lightReset; then
 run_action cp $OPENEMRAPACHECONF /etc/apache2/conf.d/openemr.conf
 run_action_sh "httpd -k start >> $LOG"
fi

echo "Demo install script is complete"
echo "Demo install script is complete" >> $LOG

# Record end time
timeEnd=`date -u`
echo -n "Completed Build: "
echo "$timeEnd"
echo -n "Completed Build: " >> $LOG
echo "$timeEnd" >> $LOG

if ! $lightReset; then
  # to stop docker image from exiting
  echo "hold docker open"
  run_action tail -F -n0 /etc/hosts
fi
