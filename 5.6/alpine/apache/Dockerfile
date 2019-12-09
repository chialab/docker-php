FROM php:5.6-fpm-alpine
LABEL maintainer="dev@chialab.io"

# Install PHP extensions and PECL modules.
RUN buildDeps=" \
      bzip2-dev \
      icu-dev \
      postgresql-dev \
      openldap-dev \
      libmemcached-dev \
    " \
    runtimeDeps=" \
      freetype-dev \
      libldap \
      icu-libs \
      libbz2 \
      libpng-dev \
      libjpeg-turbo-dev \
      libmemcached-libs \
      libmcrypt-dev \
      libpq \
      libzip \
      libxml2-dev \
      libzip-dev \
    " \
    && apk add --no-cache --virtual .build-deps $buildDeps \
    && apk add --no-cache $runtimeDeps \
    && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
    && apk add --no-cache ca-certificates \
    && docker-php-ext-install \
        bcmath \
        bz2 \
        calendar \
        exif \
        iconv \
        intl \
        mbstring \
        mcrypt \
        mysqli \
        opcache \
        pdo_mysql \
        pdo_pgsql \
        soap \
        zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
        gd \
        ldap \
    && pecl install \
        memcached-2.2.0 \
        redis-4.3.0 \
    && docker-php-ext-enable \
        memcached \
        redis \
    && apk add --no-cache \
        apache2 \
        apache2-ctl \
        apache2-utils \
        apache2-proxy \
        apache2-ssl \
    && apk del .build-deps .phpize-deps

# Load mod_rewrite and setup FPM
RUN sed -i '/LoadModule rewrite_module/s/^#//g' /etc/apache2/httpd.conf \
    && sed -i 's#AllowOverride [Nn]one#AllowOverride All#' /etc/apache2/httpd.conf \
    && sed -i "s#/var/www/localhost/htdocs#/var/www/html#" /etc/apache2/httpd.conf \
    && sed -i "s#/var/www/localhost/cgi-bin#/var/www/html/cgi-bin#" /etc/apache2/httpd.conf \
    && sed -i "/LoadModule mpm_prefork_module/s/^/#/g" /etc/apache2/httpd.conf \
    && sed -i "/LoadModule mpm_event_module/s/^#//g" /etc/apache2/httpd.conf \
    && sed -i "s#DirectoryIndex index.html#DirectoryIndex index.php#" /etc/apache2/httpd.conf \
    && echo "ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:9000/var/www/html/$1" >> /etc/apache2/httpd.conf \
    && echo "ProxyPassMatch ^/(fpm-ping|fpm-status) fcgi://127.0.0.1:9000" >> /etc/apache2/httpd.conf \
    && mkdir -p /run/apache2

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && ln -s $(composer config --global home) /root/composer
ENV PATH=$PATH:/root/composer/vendor/bin COMPOSER_ALLOW_SUPERUSER=1
