#
# Copyright (C) 2017-2024 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# pre-openemr Dockerfile build
#
FROM alpine:3.20

# Install standard dependencies, except for mysql-server
# (also installing git, wget, openvpn, mysql-client, zip, bash, and rsync)
RUN apk --no-cache upgrade
RUN apk add --no-cache apache2 \
            bash \
            curl \
            git \
            imagemagick \
            jq \
            mariadb-connector-c \
            mysql-client \
            nodejs \
            npm \
            openvpn \
            perl \
            php83 \
            php83-apache2 \
            php83-bcmath \
            php83-calendar \
            php83-ctype \
            php83-curl \
            php83-dom \
            php83-fileinfo \
            php83-gd \
            php83-iconv \
            php83-intl \
            php83-json \
            php83-ldap \
            php83-mbstring \
            php83-mysqli \
            php83-openssl \
            php83-pdo \
            php83-pdo_mysql \
            php83-pecl-imagick \
            php83-phar \
            php83-session \
            php83-simplexml \
            php83-soap \
            php83-sockets \
            php83-sodium \
            php83-tokenizer \
            php83-xml \
            php83-xmlreader \
            php83-xmlwriter \
            php83-xsl \
            php83-zip \
            php83-zlib \
            rsync \
            tar \
            wget \
            zip

#BELOW LINE NEEDED TO SUPPORT PHP8 ON ALPINE 3.13; SHOULD BE ABLE TO REMOVE THIS IN FUTURE ALPINE VERSIONS
RUN cp /usr/bin/php83 /usr/bin/php

# Install composer for openemr package building
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Install postfix (and stunnel to work with aws ses email)
RUN apk add --no-cache postfix
RUN apk add --no-cache stunnel openssl
RUN openssl req \
        -new \
        -out /etc/stunnel/mail.pem \
        -keyout /etc/stunnel/mail.pem \
        -nodes \
        -x509 \
        -days 3650 \
        -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=openemr.io"

# Start up apache error log and ensure it has proper permissions
RUN mkdir -p /var/www/localhost/htdocs/log
RUN echo "start log" > /var/www/localhost/htdocs/log/logPhp.txt
RUN chmod 666 /var/www/localhost/htdocs/log/logPhp.txt

#fix issue with apache2 dying
RUN mkdir -p /run/apache2

# Expose port 80
EXPOSE 80

# Commands after run the image
CMD mkdir -p /home/openemr/git; \
    cd /home/openemr/git; \
    git clone https://github.com/openemr/demo_farm_openemr.git; \
    cd ~/; \
    bash /home/openemr/git/demo_farm_openemr/demo_build.sh; \
