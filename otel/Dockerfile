ARG BASE_IMAGE=chialab/php:latest
FROM ${BASE_IMAGE}
LABEL maintainer="dev@chialab.io"

# retry: PECL sometimes replies "No releases available" on CI runners.
RUN retry() { for i in 1 2 3; do "$@" && return; sleep 10; done; return 1; }; \
    if [ "$(echo "$PHP_VERSION" | cut -d. -f1,2)" = "8.0" ]; then \
        retry install-php-extensions protobuf opentelemetry-php/ext-opentelemetry@1.1.3; \
    else \
        retry install-php-extensions protobuf opentelemetry-php/ext-opentelemetry@1.3.1; \
    fi
