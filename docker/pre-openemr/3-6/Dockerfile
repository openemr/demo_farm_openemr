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
FROM alpine:3.6

# Install standard dependencies, except for mysql-server
# (also installing git, wget, openvpn, mysql-client, zip, bash, and rsync)
RUN apk add --no-cache apache2 \
            php7 \
            php7-ctype \
            php7-session \
            php7-apache2 \
            php7-xml \
            php7-json \
            php7-pdo \
            php7-pdo_mysql \
            php7-curl \
            php7-ldap \
            php7-mcrypt \
            php7-xml \
            php7-xsl \
            php7-gd \
            php7-zip \
            php7-soap \
            php7-mbstring \
            php7-mysqli \
            php7-tokenizer \
            curl \
            imagemagick-dev \
            git \
            wget \
            openvpn \
            mysql-client \
            zip \
            bash \
            rsync

# Install postfix (try it without any configuration to see what happens)
RUN apk add --no-cache postfix

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
