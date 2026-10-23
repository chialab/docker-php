SHELL := /bin/bash
ALL: build
.PHONY: build build-base test push

PARENT_IMAGE := php
BASE_IMAGE_NAME := chialab/php-base
IMAGE := chialab/php
VERSION ?= latest
PHP_VERSION = $(firstword $(subst -, ,$(VERSION)))
FLAVOR = $(if $(findstring -,$(VERSION)),$(patsubst $(PHP_VERSION)-%,%,$(VERSION)),cli)
# EOL versions are built from eol/ instead of the official images.
EOL_DIR = $(wildcard eol/$(PHP_VERSION)/$(FLAVOR))
BASE_IMAGE = $(if $(EOL_DIR),$(REGISTRY)$(BASE_IMAGE_NAME):$(VERSION),$(PARENT_IMAGE):$(VERSION))
DOCKERFILE = $(if $(findstring alpine,$(VERSION)),Dockerfile.alpine,Dockerfile)

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
ifeq (,$(findstring $(PHP_VERSION), 7.2 7.3 7.4 8.0 8.1 8.2 8.3 8.4 8.5 latest alpine))
	# Add more extensions to PHP < 7.2.
	EXTENSIONS += mcrypt
endif
ifeq (,$(findstring $(PHP_VERSION), 7.0 7.1 7.2 7.3 7.4 8.0 8.1 8.2 8.3 8.4 8.5 latest alpine))
	# Add more extensions to 5.x series images.
	EXTENSIONS += mysql
endif

build: $(if $(EOL_DIR),build-base)
	@echo " =====> Building $(REGISTRY)$(IMAGE):$(VERSION)..."
	docker image build --quiet --build-arg 'BASE_IMAGE=$(BASE_IMAGE)' -f $(DOCKERFILE) -t $(REGISTRY)$(IMAGE):$(VERSION) .

build-base:
	@if [[ -z "$(EOL_DIR)" ]]; then \
		echo 'No eol/ Dockerfile for $(VERSION)'; \
		exit 1; \
	fi
	@echo " =====> Building $(BASE_IMAGE)..."
	docker image build --quiet --build-context patches=eol/patches --build-context scripts=eol/scripts -t $(BASE_IMAGE) $(EOL_DIR)

test:
	@echo -e "=====> Testing loaded extensions... \c"
	@if ! docker image inspect $(REGISTRY)$(IMAGE):$(VERSION) > /dev/null 2>&1; then \
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
	@if [[ "$(VERSION)" == *'-fpm'* ]]; then \
		if ! docker container run --rm $(REGISTRY)$(IMAGE):$(VERSION) php-fpm -t > /dev/null 2>&1; then \
			echo 'FAIL [php-fpm]'; \
			exit 1; \
		fi \
	fi
	@if [[ -n "$(EOL_DIR)" && -z `docker container run --rm $(REGISTRY)$(IMAGE):$(VERSION) sh -c '/bin/echo $$PHP_PATCHES'` ]]; then \
		echo 'FAIL [PHP_PATCHES]'; \
		exit 1; \
	fi
	@if [[ -z `docker container run --rm $(REGISTRY)$(IMAGE):$(VERSION) composer --version 2> /dev/null | grep '^Composer version 2\.[0-9][0-9]*'` ]]; then \
		echo 'FAIL [Composer]'; \
		exit 1; \
	fi
	@echo 'OK'

push:
	docker image push $(REGISTRY)$(IMAGE):$(VERSION)
