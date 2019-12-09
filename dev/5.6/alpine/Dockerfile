FROM chialab/php:5.6-alpine
LABEL maintainer="dev@chialab.io"

# Install XDebug
RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
    && pecl install xdebug-2.5.5 \
    && docker-php-ext-enable xdebug \
    && apk del .phpize-deps
