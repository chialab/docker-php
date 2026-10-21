ARG BASE_IMAGE=chialab/php:latest
FROM ${BASE_IMAGE}
LABEL maintainer="dev@chialab.io"

# Install XHProf.
# retry: PECL sometimes replies "No releases available" on CI runners.
RUN retry() { for i in 1 2 3; do "$@" && return; sleep 10; done; return 1; }; \
    retry install-php-extensions xhprof
