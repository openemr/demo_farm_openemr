#
# Copyright (C) 2017-2019 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# pre-openemr Dockerfile build
#
FROM alpine:3.17

# Install standard dependencies, except for mysql-server
# (also installing git, wget, openvpn, mysql-client, zip, bash, and rsync)
RUN apk --no-cache upgrade
RUN apk add --no-cache apache2 \
            php81 \
            php81-ctype \
            php81-session \
            php81-apache2 \
            php81-json \
            php81-pdo \
            php81-pdo_mysql \
            php81-curl \
            php81-ldap \
            php81-openssl \
            php81-xml \
            php81-xsl \
            php81-gd \
            php81-zip \
            php81-soap \
            php81-mbstring \
            php81-zlib \
            php81-mysqli \
            php81-sockets \
            php81-iconv \
            php81-tokenizer \
            php81-xmlreader \
            php81-simplexml \
            php81-xmlwriter \
            php81-phar \
            php81-fileinfo \
            php81-calendar \
            php81-sodium \
            php81-intl \
            perl \
            tar \
            curl \
            imagemagick \
            nodejs \
            npm \
            git \
            wget \
            openvpn \
            mysql-client \
            zip \
            bash \
            rsync \
            jq

#BELOW LINE NEEDED TO SUPPORT PHP8 ON ALPINE 3.13; SHOULD BE ABLE TO REMOVE THIS IN FUTURE ALPINE VERSIONS
RUN cp /usr/bin/php81 /usr/bin/php

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
