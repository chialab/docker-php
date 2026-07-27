SHELL := /bin/bash
ALL: build
.PHONY: build test push

PARENT_IMAGE := chialab/php
IMAGE := chialab/php-otel
VERSION ?= latest
PHP_VERSION = $(firstword $(subst -, ,$(VERSION)))
PHP_MAJOR := $(shell echo $(PHP_VERSION) | grep -oE '^[0-9]+')
ifneq ($(PHP_MAJOR),)
ifeq ($(shell [ $(PHP_MAJOR) -lt 8 ] && echo yes),yes)
$(error PHP_VERSION '$(PHP_VERSION)' is not supported: this image requires PHP >= 8.0)
endif
endif

# Extensions.
EXTENSIONS := \
	amqp \
	bcmath \
	bz2 \
	calendar \
	event \
	exif \
	gd \
	gettext \
	iconv \
	imagick \
	intl \
	ldap \
	mbstring \
	memcached \
	mysqli \
	OPcache \
	opentelemetry \
	pdo_mysql \
	pdo_pgsql \
	pgsql \
	redis \
	soap \
	xsl \
	zip \
	sockets

build:
	@echo " =====> Building $(REGISTRY)$(IMAGE):$(VERSION)..."
	docker image build --quiet --build-arg 'BASE_IMAGE=$(PARENT_IMAGE):$(VERSION)' -t $(REGISTRY)$(IMAGE):$(VERSION) .

test:
	@echo -e "=====> Testing loaded extensions... \c"
	@if [[ -z `docker image ls $(REGISTRY)$(IMAGE) | grep "\s$(VERSION)\s"` ]]; then \
		echo 'FAIL [Missing image!!!]'; \
		exit 1; \
	fi
	@IMAGE_PHP_VERSION=`docker container run --rm $(REGISTRY)$(IMAGE):$(VERSION) sh -c '/bin/echo $$PHP_VERSION' | cut -d '.' -f 1,2`; \
	if [[ "$(PHP_VERSION)" != "latest" && "$(PHP_VERSION)" != "alpine" && "$${IMAGE_PHP_VERSION}" != "$(PHP_VERSION)" ]]; then \
		echo "FAIL [wrong PHP version: expected $(PHP_VERSION), got $${IMAGE_PHP_VERSION}]"; \
		exit 1; \
	fi
	@modules=`docker container run --rm $(REGISTRY)$(IMAGE):$(VERSION) php -m`; \
	for ext in $(EXTENSIONS); do \
		if [[ "$${modules}" != *"$${ext}"* ]]; then \
			echo "FAIL [$${ext}]"; \
			exit 1; \
		fi \
	done
	@if [[ "$(VERSION)" == *'-apache' ]]; then \
		apache=`docker container run --rm $(REGISTRY)$(IMAGE):$(VERSION) apache2ctl -M 2> /dev/null`; \
		if [[ "$${apache}" != *'rewrite_module'* ]]; then \
			echo 'FAIL [mod_rewrite]'; \
			exit 1; \
		fi \
	fi
	@if [[ -z `docker container run --rm $(REGISTRY)$(IMAGE):$(VERSION) composer --version 2> /dev/null | grep '^Composer version 2\.[0-9][0-9]*'` ]]; then \
		echo 'FAIL [Composer]'; \
		exit 1; \
	fi
	@echo 'OK'

push:
	docker image push $(REGISTRY)$(IMAGE):$(VERSION)
