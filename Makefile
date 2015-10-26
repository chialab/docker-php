.PHONY: build

IMAGE = chialab/php
TAGS = \
	latest \
	5.4-apache \
	5.4-fpm \
	5.5-apache \
	5.5-fpm \
	5.6-apache \
	5.6-fpm \
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
		docker pull php:$${tag}; \
	done

build: pull
	@for tag in $(TAGS); do \
		dir=`echo "$${tag}" | sed s:-:/:`; \
		if [ $$tag == 'latest' ]; then \
			dir='.'; \
		fi; \
		docker build $(IMAGE):$${tag} $${dir}; \
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
		echo 'OK'; \
	done

	@echo "Checking Composer... \c";
	@if [[ -z `docker run --rm $(IMAGE):latest composer --version | grep 'Composer version'` ]]; then \
		echo 'FAIL'; \
		exit 1; \
	fi
	@echo 'OK'
