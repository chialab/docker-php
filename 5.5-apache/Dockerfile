FROM php:5.5-apache
MAINTAINER paolo.cuffiani@chialab.it

# Install PHP extensions and PECL modules.
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libmemcachedutil2 \
        libmysqlclient18 \
        libpng12-dev \
        libpq-dev \
        zlib1g-dev \
    && docker-php-ext-install calendar iconv intl mbstring mcrypt mysql mysqli pdo_mysql pdo_pgsql pgsql zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && pecl install memcached redis \
    && docker-php-ext-enable memcached.so redis.so

CMD ["apache2-foreground"]
