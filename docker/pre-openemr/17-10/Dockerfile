#
# Copyright (C) 2017 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# pre-openemr Dockerfile build
#
FROM ubuntu:17.10

# Install standard dependencies, except for mysql-server
# (also installing git, wget, openvpn, debconf, mysql-client, and zip)
# (installing nodejs, node, curl, unzip to allow openemr package building with composer and npm)
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-php \
    libtiff-tools \
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
    debconf \
    mysql-client \
    zip \
    curl \
    unzip

# Special for ubuntu 17.10
RUN apt-get install -y rsync

# Install nodejs/npm
RUN apt-get install -y python-software-properties
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash
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
