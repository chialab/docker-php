SHELL := /bin/bash
.PHONY: pull build-nopull build test

PARENT_IMAGE = chialab/php
IMAGE = chialab/php-dev
TAGS = \
	latest \
	5.4 \
	5.4-apache \
	5.4-fpm \
	5.5 \
	5.5-apache \
	5.5-fpm \
	5.6 \
	5.6-apache \
	5.6-fpm
EXTENSIONS = \
	bz2 \
	calendar \
	iconv \
	intl \
	gd \
	mbstring \
	mcrypt \
	memcached \
	mysql \
	mysqli \
	pdo_mysql \
	pdo_pgsql \
	pgsql \
	redis \
	Xdebug \
	zip
NO_PHP_7 = memcached mysql redis

pull:
	@for tag in $(TAGS); do \
		docker pull $(PARENT_IMAGE):$${tag}; \
	done

build-nopull:
	@for tag in $(TAGS); do \
		dir=`echo "$${tag}" | sed s:-:/:`; \
		if [ "$${tag}" = 'latest' ]; then \
			dir='.'; \
		fi; \
		echo " =====> Building $(IMAGE):$${tag}..."; \
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
			if ([[ "$${tag}" != '7'* ]] || [[ "$(NO_PHP_7)" != *"$${ext}"* ]]) && [[ "$${modules}" != *"$${ext}"* ]]; then \
				echo "FAIL [$${ext}]"; \
				exit 1; \
			fi \
		done; \
		if [[ "$${tag}" = *'-apache' ]]; then \
			apache=`docker run --rm $(IMAGE):$${tag} apache2ctl -M 2> /dev/null`; \
			if [[ "$${apache}" != *'rewrite_module'* ]]; then \
				echo 'FAIL [mod_rewrite]'; \
				exit 1; \
			fi \
		fi; \
		if [[ "$${tag}" != *'-apache' ]] && [[ "$${tag}" != *'-fpm' ]]; then \
			if [[ -z `docker run --rm $(IMAGE):latest composer --version | grep '^Composer version \d\d*\.\d\d*'` ]]; then \
				echo 'FAIL [Composer]'; \
				exit 1; \
			fi; \
			if [[ -z `docker run --rm $(IMAGE):latest phpcs --version | grep '^PHP_CodeSniffer version \d\d*\.\d\d*\.\d\d*'` ]]; then \
				echo 'FAIL [PHP_CodeSniffer]'; \
				exit 1; \
			fi; \
			if [[ -z `docker run --rm $(IMAGE):latest phpmd --version | grep '^PHPMD \d\d*\.\d\d*\.\d\d*'` ]]; then \
				echo 'FAIL [PHPMD]'; \
				exit 1; \
			fi; \
			if [[ -z `docker run --rm $(IMAGE):latest phpunit --version | grep '^PHPUnit \d\d*\.\d\d*\.\d\d*'` ]]; then \
				echo 'FAIL [PHPUnit]'; \
				exit 1; \
			fi \
		fi; \
		echo 'OK'; \
	done
