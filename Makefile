SHELL := /bin/bash
ALL: build
.PHONY: build test push

PARENT_IMAGE := php
IMAGE := chialab/php
VERSION ?= latest
PHP_VERSION = $(firstword $(subst -, ,$(VERSION)))

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
	pdo_mysql \
	pdo_pgsql \
	pgsql \
	redis \
	soap \
	xsl \
	zip \
	sockets
ifeq (,$(findstring $(PHP_VERSION), 7.2 7.3 7.4 8.0 8.1 8.2 8.3 latest alpine))
	# Add more extensions to PHP < 7.2.
	EXTENSIONS += mcrypt
endif
ifeq (,$(findstring $(PHP_VERSION), 7.0 7.1 7.2 7.3 7.4 8.0 8.1 8.2 8.3 latest alpine))
	# Add more extensions to 5.x series images.
	EXTENSIONS += mysql
endif

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
