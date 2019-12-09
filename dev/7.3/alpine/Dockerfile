FROM chialab/php:7.3-alpine
LABEL maintainer="dev@chialab.io"

# Install XDebug
RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del .phpize-deps
