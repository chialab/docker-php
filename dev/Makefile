SHELL := /bin/bash
.PHONY: pull build-nopull build test

PARENT_IMAGE := chialab/php
IMAGE := chialab/php-dev
VERSION ?= latest

# Tags.
TAGS := $(VERSION)
ifneq ($(VERSION),latest)
	# Add `-apache` and `-fpm` suffix.
	TAGS += $(VERSION)-apache $(VERSION)-fpm
endif

# Extensions.
EXTENSIONS := \
	bz2 \
	calendar \
	iconv \
	intl \
	gd \
	mbstring \
	mcrypt \
	memcached \
	mysqli \
	pdo_mysql \
	pdo_pgsql \
	pgsql \
	redis \
	Xdebug \
	zip
ifneq ($(VERSION),$(filter 7.0 7.1 latest, $(VERSION)))
	# Add more extensions to 5.x series images.
	EXTENSIONS += mysql
endif

# add opcache check to php version with zend opcache
ifeq ($(VERSION),$(filter 5.5 5.6 7.0 7.1 latest, $(VERSION)))
	EXTENSIONS += OPcache
endif

pull:
	@for tag in $(TAGS); do \
		docker pull $(PARENT_IMAGE):$${tag}; \
	done

build-nopull:
	@for tag in $(TAGS); do \
		echo " =====> Building $(IMAGE):$${tag}..."; \
		dir="$${tag/-//}"; \
		if [[ "$${tag}" == 'latest' ]]; then \
			dir='.'; \
		fi; \
		docker build --quiet -t $(IMAGE):$${tag} $${dir}; \
	done

build: pull build-nopull

test:
	@echo 'Testing loaded extensions...'
	@for tag in $(TAGS); do \
		echo -e " - $${tag}... \c"; \
		if [[ -z `docker images $(IMAGE) | grep "\s$${tag}\s"` ]]; then \
			echo 'FAIL [Missing image!!!]'; \
			exit 1; \
		fi; \
		modules=`docker run --rm $(IMAGE):$${tag} php -m`; \
		for ext in $(EXTENSIONS); do \
			if [[ "$${modules}" != *"$${ext}"* ]]; then \
				echo "FAIL [$${ext}]"; \
				exit 1; \
			fi \
		done; \
		if [[ "$${tag}" == *'-apache' ]]; then \
			apache=`docker run --rm $(IMAGE):$${tag} apache2ctl -M 2> /dev/null`; \
			if [[ "$${apache}" != *'rewrite_module'* ]]; then \
				echo 'FAIL [mod_rewrite]'; \
				exit 1; \
			fi \
		fi; \
		if [[ -z `docker run --rm $(IMAGE):$${tag} composer --version 2> /dev/null | grep '^Composer version [0-9][0-9]*\.[0-9][0-9]*'` ]]; then \
			echo 'FAIL [Composer]'; \
			exit 1; \
		fi; \
		echo 'OK'; \
	done
