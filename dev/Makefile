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
	mysqli \
	pdo_mysql \
	pdo_pgsql \
	pgsql \
	Xdebug \
	zip
ifneq ($(VERSION),7.0)
	# Add more extensions to 5.x series images.
	EXTENSIONS += memcached mysql redis
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
		if [[ "$${tag}" != *'-apache' ]] && [[ "$${tag}" != *'-fpm' ]]; then \
			if [[ -z `docker run --rm $(IMAGE):$${tag} composer --version | grep '^Composer version [0-9][0-9]*\.[0-9][0-9]*'` ]]; then \
				echo 'FAIL [Composer]'; \
				exit 1; \
			fi; \
			if [[ -z `docker run --rm $(IMAGE):$${tag} phpcs --version | grep '^PHP_CodeSniffer version [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*'` ]]; then \
				echo 'FAIL [PHP_CodeSniffer]'; \
				exit 1; \
			fi; \
			if [[ -z `docker run --rm $(IMAGE):$${tag} phpmd --version | grep '^PHPMD [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*'` ]]; then \
				echo 'FAIL [PHPMD]'; \
				exit 1; \
			fi; \
			if [[ -z `docker run --rm $(IMAGE):$${tag} phpunit --version | grep '^PHPUnit [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*'` ]]; then \
				echo 'FAIL [PHPUnit]'; \
				exit 1; \
			fi \
		fi; \
		echo 'OK'; \
	done
