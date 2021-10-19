# Docker PHP images
[![Build Status](https://travis-ci.org/Chialab/docker-php.svg?branch=master)](https://travis-ci.org/Chialab/docker-php)
[![Docker Pulls](https://img.shields.io/docker/pulls/chialab/php-dev.svg)](https://hub.docker.com/r/chialab/php-dev/)

Docker images built on top of the [official PHP images](https://hub.docker.com/r/_/php/) with the addition of some common and useful extensions, installed with [mlocati/docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer), and are meant for *debugging purposes*. You can find these images on the [Docker Hub](https://hub.docker.com/r/chialab/php-dev/) (and if you're reading this file, you're probably already there).

An automated build is set up, so they should be always up-to-date with the Dockerfiles in the [GitHub repository](https://github.com/Chialab/docker-php). Also, every time an official PHP image is updated, a rebuild is triggered, so that you will always find the latest security patches installed in these images.

For more production-like environments, you might want to choose an [image *without* XDebug installed](https://hub.docker.com/r/chialab/php/), instead.

## Available tags
- `latest`
- `5.6`
- `5.6-apache`
- `5.6-fpm`
- `7.0`
- `7.0-apache`
- `7.0-fpm`
- `7.1`
- `7.1-apache`
- `7.1-fpm`
- `7.2`
- `7.2-apache`
- `7.2-fpm`
- `7.3`
- `7.3-apache`
- `7.3-fpm`
- `7.4`
- `7.4-apache`
- `7.4-fpm`

As you might have guessed, all tags are built on top of the corresponding tag of the official image. Not all tags are supported in order to easen manteinance.

## Installed extensions
The following modules and extensions have been enabled,
in addition to those you can already find in the [official PHP image](https://hub.docker.com/r/_/php/):

- `bcmath`
- `bz2`
- `calendar`
- `exif`
- `iconv`
- `intl`
- `gd`
- `ldap`
- `mbstring`
- `mcrypt` (_only PHP ≤ 7.1_)
- `memcached`
- `mysql` (_only PHP 5.x_)
- `mysqli`
- `pdo_mysql`
- `pdo_pgsql`
- `pgsql`
- `redis`
- `soap`
- `xsl`
- `xdebug`
- `Zend OPcache`
- `zip`

You will probably not need all this stuff. Even if having some extra extensions loaded ain't a big issue in most cases (especially in a development environment), you will very likely want to checkout this repository, remove unwanted extensions from the `Dockerfile`, and build your own image — for sometimes removing is easier than adding. 😉

## Composer
[Composer](https://getcomposer.org) is installed globally in all images. Please, refer to their documentation for usage hints.  
[Prestissimo (composer plugin)](https://github.com/hirak/prestissimo) is installed globally in all images. Plugin that downloads packages in parallel to speed up the installation process of Composer packages.

## Configuring XDebug
XDebug is installed, but not yet configured.
For features like remote debugging, you will need to pass additional configurations via Apache or Nginx configuration files.

### Using Apache
In the directories you want to enable debug in, you will want to specify additional options via `php_value`, e.g.:

```
php_value xdebug.remote_enable 1
php_value xdebug.remote_host 192.168.99.1
```

### Using Nginx
To enable debugging, additional parameters must be passed to the FastCGI PHP interpreter via `fastcgi_param`, e.g.:

```
fastcgi_param PHP_VALUE "xdebug.remote_enable=1\nxdebug.remote_host=192.168.99.1";
```

## Contributing
If you find an issue, or have a special wish not yet fulfilled, please [open an issue on GitHub](https://github.com/Chialab/docker-php/issues) providing as many details as you can (the more you are specific about your problem, the easier it is for us to fix it).

Pull requests are welcome, too! 😁 Please, run `make build` and `make test` before attempting a pull request. Also, it would be nice if you could follow [best practices for writing Dockerfiles](https://docs.docker.com/articles/dockerfile_best-practices/).
