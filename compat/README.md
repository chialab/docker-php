# Docker PHP images: compat

[![PHP 5 build](https://img.shields.io/github/actions/workflow/status/chialab/docker-php/test.5.yml?branch=main&label=PHP%205&style=flat-square)](https://github.com/chialab/docker-php/actions/workflows/test.5.yml?query=branch%3Amain)
[![Source link](https://img.shields.io/badge/Source-GitHub-lightgrey.svg?style=flat-square)](https://github.com/chialab/docker-php)
[![Authors link](https://img.shields.io/badge/Authors-Chialab-lightgrey.svg?style=flat-square)](https://www.chialab.it)
[![Docker Pulls](https://img.shields.io/docker/pulls/chialab/php-compat.svg?style=flat-square)](https://hub.docker.com/r/chialab/php-compat/)
[![License](https://img.shields.io/github/license/chialab/docker-php.svg?style=flat-square)](https://github.com/chialab/docker-php/blob/main/LICENSE)

Compatibility docker images.

### PHP 5.6

Built on top of [`chialab/php:5.6`](../README.md) (same tag), with the `mysql`, `mysqli` and `pdo_mysql` extensions rebuilt
against MariaDB's `libmysqlclient` connector instead of `mysqlnd`. Unlike `mysqlnd` 5.6, it can connect to MySQL 8.0+ servers
whose default authentication plugin is `caching_sha2_password`, as long as the account uses `mysql_native_password`. Accounts
using `caching_sha2_password` aren't supported, and the `mysqlnd`-only APIs (such as `mysqli_stmt::get_result()`) aren't
available.

## Available tags
- `5.6`
- `5.6-apache`
- `5.6-fpm`

## Installed extensions
The following modules and extensions have been enabled,
in addition to those you can already find in the [official PHP image](https://hub.docker.com/r/_/php/):

- `amqp`
- `bcmath`
- `bz2`
- `calendar`
- `event`
- `exif`
- `gd`
- `gettext`
- `iconv`
- `imagick`
- `intl`
- `ldap`
- `mbstring`
- `mcrypt` (_only PHP ≤ 7.1_)
- `memcached`
- `mysql` (_only PHP 5.x_)
- `mysqli`
- `pcov`
- `pdo_mysql`
- `pdo_pgsql`
- `pgsql`
- `redis`
- `soap`
- `sockets`
- `xsl`
- `Zend OPcache`
- `zip`

You will probably not need all this stuff. Even if having some extra extensions loaded ain't a big issue in most cases (especially in a development environment), you will very likely want to checkout this repository, remove unwanted extensions from the `Dockerfile`, and build your own image — for sometimes removing is easier than adding. 😉

## Composer
[Composer](https://getcomposer.org) is installed globally in all images. Please, refer to their documentation for usage hints.
Since 2020/11/01 both version 1 and 2 are installed, available through `composer1` and `composer2` commands respectively (`composer` in now a symlink to `composer2`).  
[Prestissimo (composer plugin)](https://github.com/hirak/prestissimo) is installed globally in all images, for use with Composer version 1. It's a plugin that downloads packages in parallel to speed up the installation process of Composer packages.

## Contributing
If you find an issue, or have a special wish not yet fulfilled, please [open an issue on GitHub](https://github.com/chialab/docker-php/issues) providing as many details as you can (the more you are specific about your problem, the easier it is for us to fix it).

Pull requests are welcome, too! 😁 Please, run `make build` and `make test` before attempting a pull request. Also, it would be nice if you could stick to the [best practices for writing Dockerfiles](https://docs.docker.com/articles/dockerfile_best-practices/).

---

## License

Docker PHP Images is released under the [MIT](https://github.com/chialab/docker-php/blob/main/LICENSE) license.
