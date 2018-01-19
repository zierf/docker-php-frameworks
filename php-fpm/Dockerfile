FROM php:7-fpm-alpine
MAINTAINER zier <florianzier@users.noreply.github.com>

# install php extensions
RUN docker-php-ext-configure mysqli --with-mysqli=mysqlnd \
    && docker-php-ext-install mysqli pdo_mysql

# install composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# use HTTPS for package repository
#RUN composer config --global repositories.packagist composer https://packagist.org
