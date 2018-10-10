# OS
FROM ubuntu:bionic

# Environment vars
ENV DEBIAN_FRONTEND noninteractive

# General package install
RUN apt-get update && apt-get -y install apache2 \
 libapache2-mod-php7.2 \
 php7.2-common \
 php7.2-sybase \
 php7.2-json \
 php7.2-curl \
 php7.2-xml \
 php7.2-mbstring

# Adding xdebug for PHP
RUN apt-get -y install php-xdebug
COPY php_ini_xdebug.ini /etc/php/7.2/mods-available/xdebug.ini

# Copy the configuration files and remove unused
COPY freetds.conf /etc/freetds/freetds.conf
COPY vhost.conf /etc/apache2/sites-available/app.conf
RUN rm -f /etc/apache2/sites-available/000-default.conf
RUN rm -f /etc/apache2/sites-enabled/000-default.conf
RUN a2ensite app
RUN a2enmod rewrite

# Copy files
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY app /var/www/html

# Add PHP configs
RUN sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php/7.2/apache2/php.ini
RUN sed -i 's/;date.timezone =/date.timezone = UTC/' /etc/php/7.2/apache2/php.ini

# Link Apache default log files to STDOUT
RUN ln -sf /proc/self/fd/1 /var/log/apache2/error.log
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log

WORKDIR /var/www/html
EXPOSE 80

CMD apachectl -DFOREGROUND
