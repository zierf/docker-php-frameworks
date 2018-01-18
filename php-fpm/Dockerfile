FROM php:7-fpm-alpine
MAINTAINER zier <florianzier@users.noreply.github.com>

# install php extensions
RUN docker-php-ext-configure mysqli --with-mysqli=mysqlnd \
    && docker-php-ext-install mysqli pdo_mysql

# install gnu iconv, supports //IGNORE and //TRANSLIT
RUN apk --no-cache --allow-untrusted --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing add gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# install composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer
