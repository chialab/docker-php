FROM php:7.4-fpm
LABEL maintainer="dev@chialab.io"

# Download script to install PHP extensions and dependencies
ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions && sync

RUN DEBIAN_FRONTEND=noninteractive apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq -y \
      curl \
      git \
      zip unzip \
    && install-php-extensions \
      bcmath \
      bz2 \
      calendar \
      exif \
      gd \
      intl \
      ldap \
      memcached \
      mysqli \
      opcache \
      pdo_mysql \
      pdo_pgsql \
      pgsql \
      redis \
      soap \
      xsl \
      zip \
      sockets \
      pdo_sqlsrv \
      sqlsrv
# already installed:
#      iconv \
#      mbstring \

# Install Composer.
ENV PATH=$PATH:/root/composer2/vendor/bin:/root/composer1/vendor/bin \
  COMPOSER_ALLOW_SUPERUSER=1 \
  COMPOSER_HOME=/root/composer2 \
  COMPOSER1_HOME=/root/composer1
RUN cd /opt \
  # Download installer and check for its integrity.
  && curl -sSL https://getcomposer.org/installer > composer-setup.php \
  && curl -sSL https://composer.github.io/installer.sha384sum > composer-setup.sha384sum \
  && sha384sum --check composer-setup.sha384sum \
  # Install Composer 2 and expose `composer` as a symlink to it.
  && php composer-setup.php --install-dir=/usr/local/bin --filename=composer2 --2 \
  && ln -s /usr/local/bin/composer2 /usr/local/bin/composer \
  # Install Composer 1, make it point to a different `$COMPOSER_HOME` directory than Composer 2, install `hirak/prestissimo` plugin.
  && php composer-setup.php --install-dir=/usr/local/bin --filename=.composer1 --1 \
  && printf "#!/bin/sh\nCOMPOSER_HOME=\$COMPOSER1_HOME\nexec /usr/local/bin/.composer1 \$@" > /usr/local/bin/composer1 \
  && chmod 755 /usr/local/bin/composer1 \
  && composer1 global require hirak/prestissimo \
  # Remove installer files.
  && rm /opt/composer-setup.php /opt/composer-setup.sha384sum
