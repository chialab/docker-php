ARG BASE_IMAGE=chialab/php:latest
FROM ${BASE_IMAGE}
LABEL maintainer="dev@chialab.io"

RUN if [ "$(echo "$PHP_VERSION" | cut -d. -f1,2)" = "8.0" ]; then \
        install-php-extensions protobuf opentelemetry-php/ext-opentelemetry@1.1.3; \
    else \
        install-php-extensions protobuf opentelemetry-php/ext-opentelemetry@1.3.1; \
    fi
