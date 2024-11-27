ARG BASE_IMAGE=chialab/php:latest
FROM ${BASE_IMAGE}
LABEL maintainer="dev@chialab.io"

# Install XDebug. Use beta version for PHP 8.4
RUN if [ $(php-config --vernum) -lt 80400 ]; then \
      install-php-extensions xdebug; \
    else \
      install-php-extensions xdebug-beta; \
    fi
