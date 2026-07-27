ARG BASE_IMAGE=chialab/php:latest
FROM ${BASE_IMAGE}
LABEL maintainer="dev@chialab.io"

# Install OpenTelemetry.
RUN install-php-extensions protobuf opentelemetry-php/ext-opentelemetry@1.3.1
