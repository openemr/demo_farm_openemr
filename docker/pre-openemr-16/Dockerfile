#
# Copyright (C) 2017 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# pre-openemr-16 Dockerfile build
#
#
FROM ubuntu:16.04

# Install standard dependencies, except for mysql-server
# (also installingp git, wget, openvpn, and debconf)
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-php \
    libdate-calc-perl \
    libdbd-mysql-perl \
    libdbi-perl \
    libhtml-parser-perl \
    libtiff-tools \
    libwww-mechanize-perl \
    libxml-parser-perl \
    php \
    php-mysql \
    php-cli \
    php-gd \
    php-xsl \
    php-curl \
    php-mcrypt \
    php-soap \
    php-json \
    php-gettext \
    imagemagick \
    php-mbstring \
    php-zip \
    php-ldap \
    git \
    wget \
    openvpn \
    debconf
    
# Install postfix
RUN bash -c 'debconf-set-selections <<< "postfix postfix/mailname string opensourceemr.com"'
RUN bash -c 'debconf-set-selections <<< "postfix postfix/main_mailer_type string Internet\ Site"'
RUN apt-get install -y postfix

# Expose port 80
EXPOSE 80

# Commands after run the image
CMD mkdir -p /home/openemr/git; \
    cd /home/openemr/git; \
    git clone https://github.com/bradymiller/demo_farm_openemr.git; \
    cd ~/; \
    bash /home/openemr/git/demo_farm_openemr/demo_build.sh; \
