.PHONY: pull build test

PARENT_IMAGE = chialab/php
IMAGE = chialab/php-dev
TAGS = \
	latest \
	5.4-apache \
	5.4-fpm \
	5.5-apache \
	5.5-fpm \
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
		echo 'OK'; \
	done

	@echo "Checking Composer... \c";
	@if [[ -z `docker run --rm $(IMAGE):latest composer --version | grep '^Composer version \d\d*\.\d\d*'` ]]; then \
		echo 'FAIL'; \
		exit 1; \
	fi
	@echo 'OK'

	@echo "Checking PHP_CodeSniffer... \c";
	@if [[ -z `docker run --rm $(IMAGE):latest phpcs --version | grep '^PHP_CodeSniffer version \d\d*\.\d\d*\.\d\d*'` ]]; then \
		echo 'FAIL'; \
		exit 1; \
	fi
	@echo 'OK'

	@echo "Checking PHPMD... \c";
	@if [[ -z `docker run --rm $(IMAGE):latest phpmd --version | grep '^PHPMD \d\d*\.\d\d*\.\d\d*'` ]]; then \
		echo 'FAIL'; \
		exit 1; \
	fi
	@echo 'OK'

	@echo "Checking PHPUnit... \c";
	@if [[ -z `docker run --rm $(IMAGE):latest phpunit --version | grep '^PHPUnit \d\d*\.\d\d*\.\d\d*'` ]]; then \
		echo 'FAIL'; \
		exit 1; \
	fi
	@echo 'OK'
