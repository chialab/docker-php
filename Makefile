.PHONY: pull build test

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

build: pull
	@for tag in $(TAGS); do \
		dir=`echo "$${tag}" | sed s:-:/:`; \
		if [ $$tag == 'latest' ]; then \
			dir='.'; \
		fi; \
		docker build -t $(IMAGE):$${tag} $${dir}; \
	done

test:
	@echo 'Testing loaded extensions...'
	@for tag in $(TAGS); do \
		modules=`docker run --rm $(IMAGE):$${tag} php -m`; \
		echo " - $${tag}... \c"; \
		for ext in $(EXTENSIONS); do \
			if ([[ $$tag != '7'* ]] || [[ "$(NO_PHP_7)" != *$$ext* ]]) && [[ $$modules != *$$ext* ]]; then \
				echo "FAIL [$${ext}]"; \
				exit 1; \
			fi \
		done; \
		if [[ $$tag = *'-apache' ]]; then \
			apache=`docker run --rm $(IMAGE):$${tag} apache2ctl -M 2> /dev/null`; \
			if [[ $$apache != *'rewrite_module'* ]]; then \
				echo 'FAIL [mod_rewrite]'; \
				exit 1; \
			fi \
		fi; \
		if [[ $$tag != *'-apache' ]] && [[ $$tag != *'-fpm' ]]; then \
			if [[ -z `docker run --rm $(IMAGE):$${tag} composer --version | grep '^Composer version \d\d*\.\d\d*'` ]]; then \
				echo 'FAIL [Composer]'; \
				exit 1; \
			fi \
		fi; \
		echo 'OK'; \
	done
