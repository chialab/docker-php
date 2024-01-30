ARG BASE_IMAGE=php:latest
FROM ${BASE_IMAGE}
LABEL maintainer="dev@chialab.io"

# Fix Debian 9 (Stretch) source list, because it has been moved to archive
RUN if [ "$(grep '^VERSION_ID=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')" -eq "9" ]; then \
        sed -i -e 's/deb.debian.org/archive.debian.org/g' \
               -e 's/security.debian.org/archive.debian.org/g' \
               -e '/stretch-updates/d' /etc/apt/sources.list; \
    fi

# Download script to install PHP extensions and dependencies
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions

RUN DEBIAN_FRONTEND=noninteractive apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq -y \
      curl \
      git \
      zip unzip \
# iconv, mbstring and pdo_sqlite are omitted as they are already installed
    && PHP_EXTENSIONS=" \
      amqp \
      bcmath \
      bz2 \
      calendar \
      event \
      exif \
      gd \
      gettext \
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
      sockets \
      xsl \
      zip \
    " \
    && case "$PHP_VERSION" in \
      5.6.*) PHP_EXTENSIONS="$PHP_EXTENSIONS mcrypt mysql";; \
      7.0.*|7.1.*) PHP_EXTENSIONS="$PHP_EXTENSIONS mcrypt";; \
    esac \
    # Install Imagick from master on PHP >= 8.3, because imagick 3.7.0 broke on latest PHP releases and Imagick maintainers don't care to tag a newer release
    && if [ $(php -r 'echo PHP_VERSION_ID;') -lt 80300 ]; then \
      PHP_EXTENSIONS="$PHP_EXTENSIONS imagick"; \
      else PHP_EXTENSIONS="$PHP_EXTENSIONS https://api.github.com/repos/Imagick/imagick/tarball/28f27044e435a2b203e32675e942eb8de620ee58"; \
    fi \
    && install-php-extensions $PHP_EXTENSIONS \
    && if command -v a2enmod; then a2enmod rewrite; fi

# Install Composer.
ENV PATH=$PATH:/root/composer/vendor/bin \
  COMPOSER_ALLOW_SUPERUSER=1 \
  COMPOSER_HOME=/root/composer
RUN cd /opt \
  # Download installer and check for its integrity.
  && curl -sSL https://getcomposer.org/installer > composer-setup.php \
  && curl -sSL https://composer.github.io/installer.sha384sum > composer-setup.sha384sum \
  && sha384sum --check composer-setup.sha384sum \
  # Install Composer 2.
  && php composer-setup.php --install-dir=/usr/local/bin --filename=composer --2 \
  # Remove installer files.
  && rm /opt/composer-setup.php /opt/composer-setup.sha384sum
