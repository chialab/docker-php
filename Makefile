SHELL := /bin/bash
.PHONY: pull build-nopull build test

PARENT_IMAGE := php
IMAGE := chialab/php
VERSION ?= latest
PHP_VERSION = $(firstword $(subst -, ,$(VERSION)))

# Extensions.
EXTENSIONS := \
	bcmath \
	bz2 \
	calendar \
	exif \
	iconv \
	intl \
	gd \
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
	zip
ifeq (,$(findstring $(PHP_VERSION), 7.2 latest))
	# Add more extensions to PHP < 7.2.
	EXTENSIONS += mcrypt
endif
ifeq (,$(findstring $(PHP_VERSION), 7.0 7.1 7.2 latest))
	# Add more extensions to 5.x series images.
	EXTENSIONS += mysql
endif

build:
	@echo " =====> Building $(IMAGE):$(VERSION)..."
	@dir="$(subst -,/,$(VERSION))"; \
	if [[ "$(VERSION)" == 'latest' ]]; then \
		dir='.'; \
	fi; \
	docker build --quiet -t $(IMAGE):$(VERSION) $${dir}

test:
	@echo -e "=====> Testing loaded extensions... \c"
	@if [[ -z `docker images $(IMAGE) | grep "\s$(VERSION)\s"` ]]; then \
		echo 'FAIL [Missing image!!!]'; \
		exit 1; \
	fi
	@modules=`docker run --rm $(IMAGE):$(VERSION) php -m`; \
	for ext in $(EXTENSIONS); do \
		if [[ "$${modules}" != *"$${ext}"* ]]; then \
			echo "FAIL [$${ext}]"; \
			exit 1; \
		fi \
	done
	@if [[ "$(VERSION)" == *'-apache' ]]; then \
		apache=`docker run --rm $(IMAGE):$(VERSION) apache2ctl -M 2> /dev/null`; \
		if [[ "$${apache}" != *'rewrite_module'* ]]; then \
			echo 'FAIL [mod_rewrite]'; \
			exit 1; \
		fi \
	fi
	@if [[ -z `docker run --rm $(IMAGE):$(VERSION) composer --version 2> /dev/null | grep '^Composer version [0-9][0-9]*\.[0-9][0-9]*'` ]]; then \
		echo 'FAIL [Composer]'; \
		exit 1; \
	fi
	@echo 'OK'
