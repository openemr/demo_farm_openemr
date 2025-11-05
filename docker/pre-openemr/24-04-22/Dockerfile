#
# Copyright (C) 2018 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# pre-openemr Dockerfile build
#
FROM ubuntu:24.04

# I had to add tzdata for Ubuntu 18.04 as first thing, so it would not go into interactive timezone request mode
# Note this causes some broken things reagarding timezone and defaults to UTC then
# When this bug no longer exists, will remove this entire section and place the debconf package and update call in below RUN
# (Still needed this code when tested on 6/3/18)
RUN apt-get update && apt-get install -y debconf
RUN echo "tzdata tzdata/Areas select America" | debconf-set-selections
RUN echo "tzdata tzdata/Zones/America select Los Angeles" | debconf-set-selections
RUN apt-get install -y tzdata

# Install standard dependencies, except for mysql-server
# (also installing git, wget, openvpn, debconf(note is done in above codeblock for now), mysql-client, and zip)
# (installing nodejs, node, curl, unzip to allow openemr package building with composer and npm)
# I had to remove php-mcrypt for Ubuntu 18.04 since no longer supported in php 7.2
# For php 8.1 json extension is now in core php
RUN apt-get install -y \
    apache2 \
    curl \
    git \
    imagemagick \
    jq \
    libapache2-mod-php \
    libtiff-tools \
    mariadb-client \
    openvpn \
    php8.3 \
    php8.3-bcmath \
    php8.3-cli \
    php8.3-curl \
    php8.3-dom \
    php8.3-gd \
    php8.3-imagick \
    php8.3-intl \
    php8.3-ldap \
    php8.3-mbstring \
    php8.3-mysql \
    php8.3-soap \
    php8.3-xsl \
    php8.3-zip \
    unzip \
    wget \
    zip

# Special for ubuntu 17.10 and 18.04 so far
RUN apt-get install -y rsync

# Install nodejs/npm
RUN apt-get install -y software-properties-common
RUN curl -sL https://deb.nodesource.com/setup_22.x | bash
RUN apt-get install -y nodejs

# Install composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Install and configure postfix and stunnel (stunnel is needed for aws ses email service)
RUN echo "postfix postfix/mailname string openemr.io" | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
RUN apt-get install -y postfix
RUN apt-get install -y stunnel
RUN openssl req \
        -new \
        -out /etc/stunnel/mail.pem \
        -keyout /etc/stunnel/mail.pem \
        -nodes \
        -x509 \
        -days 3650 \
        -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=openemr.io"

# Support rewrite in apache
RUN a2enmod rewrite

# Start up apache error log and ensure it has proper permissions
RUN mkdir -p /var/www/html/log
RUN echo "start log" > /var/www/html/log/logPhp.txt
RUN chmod 666 /var/www/html/log/logPhp.txt

# Expose port 80
EXPOSE 80

# Commands after run the image
CMD mkdir -p /home/openemr/git; \
    cd /home/openemr/git; \
    git clone https://github.com/openemr/demo_farm_openemr.git; \
    cd ~/; \
    bash /home/openemr/git/demo_farm_openemr/demo_build.sh; \
