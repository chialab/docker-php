FROM chialab/php:5.6-apache
MAINTAINER paolo.cuffiani@chialab.it

# Install XDebug.
RUN pecl install xdebug \
    && echo "zend_extension=\"$(php-config --extension-dir)/xdebug.so\"" > $PHP_INI_DIR/conf.d/xdebug.ini

CMD ["apache2-foreground"]
