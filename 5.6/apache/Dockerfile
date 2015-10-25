FROM php:5.6-apache
MAINTAINER paolo.cuffiani@chialab.it

# Install PHP extensions and PECL modules.
RUN buildDeps=" \
        libmemcached-dev \
        libmysqlclient-dev \
        libsasl2-dev \
    " \
    runtimeDeps=" \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libmcrypt-dev \
        libmemcachedutil2 \
        libpng12-dev \
        libpq-dev \
    " \
    && apt-get update && apt-get install -y $buildDeps $runtimeDeps \
    && docker-php-ext-install calendar iconv intl mbstring mcrypt mysql mysqli pdo_mysql pdo_pgsql pgsql zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && pecl install memcached redis \
    && docker-php-ext-enable memcached.so redis.so \
    && apt-get purge -y --auto-remove $buildDeps

CMD ["apache2-foreground"]
