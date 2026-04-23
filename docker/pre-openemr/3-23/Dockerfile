#
# Copyright (C) 2017-2026 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# pre-openemr Dockerfile build
#
FROM alpine:3.23
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
            php85 \
            php85-apache2 \
            php85-bcmath \
            php85-calendar \
            php85-ctype \
            php85-curl \
            php85-dom \
            php85-fileinfo \
            php85-gd \
            php85-iconv \
            php85-intl \
            php85-ldap \
            php85-mbstring \
            php85-mysqli \
            php85-openssl \
            php85-pdo \
            php85-pdo_mysql \
            php85-pecl-imagick \
            php85-pecl-redis \
            php85-phar \
            php85-session \
            php85-simplexml \
            php85-soap \
            php85-sockets \
            php85-sodium \
            php85-tokenizer \
            php85-xml \
            php85-xmlreader \
            php85-xmlwriter \
            php85-xsl \
            php85-zip \
            php85-zlib \
            rsync \
            tar \
            wget \
            zip
#BELOW LINE NEEDED TO SUPPORT PHP8 ON ALPINE 3.13; SHOULD BE ABLE TO REMOVE THIS IN FUTURE ALPINE VERSIONS
RUN cp /usr/bin/php85 /usr/bin/php
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