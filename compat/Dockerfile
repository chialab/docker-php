ARG BASE_IMAGE=chialab/php:5.6
FROM ${BASE_IMAGE}
LABEL maintainer="dev@chialab.io"

# Rebuild the MySQL extensions against MariaDB's libmysqlclient instead of mysqlnd: it can connect
# to MySQL 8+ servers whose default authentication plugin (caching_sha2_password) mysqlnd 5.6
# doesn't know, as long as the account itself uses mysql_native_password.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends libmariadbclient-dev-compat; \
    rm -rf /var/lib/apt/lists/*; \
    rm -f "$PHP_INI_DIR"/conf.d/docker-php-ext-mysql.ini "$PHP_INI_DIR"/conf.d/docker-php-ext-mysqli.ini "$PHP_INI_DIR"/conf.d/docker-php-ext-pdo_mysql.ini; \
    docker-php-ext-configure mysql --with-mysql=/usr --with-libdir="lib/$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
    docker-php-ext-configure mysqli --with-mysqli=/usr/bin/mysql_config; \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql=/usr; \
    docker-php-ext-install mysql mysqli pdo_mysql
