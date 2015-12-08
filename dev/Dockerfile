FROM chialab/php:latest
MAINTAINER dev@chialab.it

# Install XDebug.
# RUN pecl install xdebug \
#     && echo "zend_extension=\"$(php-config --extension-dir)/xdebug.so\"" > $PHP_INI_DIR/conf.d/xdebug.ini

# Install dev tools.
RUN composer global require --no-ansi "phpmd/phpmd" "phpunit/phpunit=4.*" "squizlabs/php_codesniffer"
