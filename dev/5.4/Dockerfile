FROM chialab/php:5.4
LABEL maintainer="dev@chialab.io"

# Install XDebug.
RUN pecl install xdebug-2.4.1 \
    && echo "zend_extension=\"$(php-config --extension-dir)/xdebug.so\"" > $PHP_INI_DIR/conf.d/xdebug.ini
