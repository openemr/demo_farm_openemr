#
# Copyright (C) 2017-2018 Brady Miller <brady.g.miller@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# pre-openemr Dockerfile build
#
FROM alpine:3.8

# Install standard dependencies, except for mysql-server
# (also installing git, wget, openvpn, mysql-client, zip, bash, and rsync)
RUN apk --no-cache upgrade
RUN apk add --no-cache apache2 \
            php7 \
            php7-ctype \
            php7-session \
            php7-apache2 \
            php7-json \
            php7-pdo \
            php7-pdo_mysql \
            php7-curl \
            php7-ldap \
            php7-openssl \
            php7-xml \
            php7-xsl \
            php7-gd \
            php7-zip \
            php7-soap \
            php7-mbstring \
            php7-zlib \
            php7-mysqli \
            php7-sockets \
            php7-iconv \
            php7-tokenizer \
            php7-xmlreader \
            php7-simplexml \
            php7-xmlwriter \
            perl \
            tar \
            curl \
            imagemagick-dev \
            nodejs \
            nodejs-npm \
            git \
            wget \
            openvpn \
            mysql-client \
            zip \
            bash \
            rsync

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
