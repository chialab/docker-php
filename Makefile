.PHONY: pull build-nopull build test

PARENT_IMAGE = php
IMAGE = chialab/php
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
	5.6-fpm \
	7.0 \
	7.0-apache \
	7.0-fpm
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
		echo " - Building $(IMAGE):$${tag}..."; \
		docker build --quiet -t $(IMAGE):$${tag} $${dir}; \
	done

build: pull build-nopull

test:
	@echo 'Testing loaded extensions...'
	@for tag in $(TAGS); do \
		echo " - $${tag}... \c"; \
		test=`docker images $(IMAGE) | grep "\s$${tag}\s"`; \
		if [ -z "$${test}" ]; then \
			echo 'FAIL [Missing image!!!]'; \
			exit 1; \
		fi; \
		modules=`docker run --rm $(IMAGE):$${tag} php -m`; \
		for ext in $(EXTENSIONS); do \
			if ([ "$${tag:0:1}" != '7' ] || [ "$${NO_PHP_7/$$ext}" = "$(NO_PHP_7)" ]) && [ "$${modules/$$ext}" = "$${modules}" ]; then \
				echo "FAIL [$${ext}]"; \
				exit 1; \
			fi \
		done; \
		if [ "$${tag/'-apache'}" != "$${tag}" ]; then \
			apache=`docker run --rm $(IMAGE):$${tag} apache2ctl -M 2> /dev/null`; \
			if [ "$${apache/'rewrite_module'}" = "$${apache}" ]; then \
				echo 'FAIL [mod_rewrite]'; \
				exit 1; \
			fi \
		fi; \
		if [ "$${tag/'-apache'}" = "$${tag}" ] && [ "$${tag/'-fpm'}" = "$${tag}" ]; then \
			test=`docker run --rm $(IMAGE):$${tag} composer --version | grep '^Composer version \d\d*\.\d\d*'`; \
			if [ -z "$${test}" ]; then \
				echo 'FAIL [Composer]'; \
				exit 1; \
			fi \
		fi; \
		echo 'OK'; \
	done
