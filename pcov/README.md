<p align="center">
    <a href="https://www.chialab.io/p/docker-php">
        <img alt="Docker PHP Images logo" width="144" height="144" src="https://raw.githack.com/chialab/docker-php/master/logo.svg" />
    </a>
</p>

<p align="center">
  <strong>Docker PHP images</strong>
</p>

<p align="center">
    <a href="https://github.com/chialab/docker-php/actions"><img alt="GitHub Workflow Status" src="https://img.shields.io/github/actions/workflow/status/chialab/docker-php/main.yml?branch=main&style=flat-square"></a>
    <a href="https://github.com/chialab/docker-php"><img alt="Source link" src="https://img.shields.io/badge/Source-GitHub-lightgrey.svg?style=flat-square"></a>
    <a href="https://www.chialab.it"><img alt="Authors link" src="https://img.shields.io/badge/Authors-Chialab-lightgrey.svg?style=flat-square"></a>
    <a href="https://hub.docker.com/r/chialab/php-pcov/"><img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/chialab/php-pcov.svg?style=flat-square"></a>
    <a href="https://github.com/chialab/docker-php/blob/master/LICENSE"><img alt="License" src="https://img.shields.io/github/license/chialab/docker-php.svg?style=flat-square"></a>
</p>

---

Docker images built on top of the [official PHP images](https://hub.docker.com/r/_/php/) with the addition of some common and useful extensions, installed with [mlocati/docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer), and are meant for *continuout integration purposes*. You can find these images on the [Docker Hub](https://hub.docker.com/r/chialab/php-pcov/) (and if you're reading this file, you're probably already there).

An automated build is set up, so they should be always up-to-date with the Dockerfiles in the [GitHub repository](https://github.com/chialab/docker-php). Also, every time an official PHP image is updated, a rebuild is triggered, so that you will always find the latest security patches installed in these images.

For more production-like environments, you might want to choose an [image *without* PCOV installed](https://hub.docker.com/r/chialab/php/), instead.

## Available tags
- `latest`
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
- `8.0`
- `8.0-apache`
- `8.0-fpm`
- `8.1`
- `8.1-apache`
- `8.1-fpm`
- `8.2`
- `8.2-apache`
- `8.2-fpm`
- `8.3`
- `8.3-apache`
- `8.3-fpm`
- `8.4`
- `8.4-apache`
- `8.4-fpm`

As you might have guessed, all tags are built on top of the corresponding tag of the official image. Not all tags are supported in order to easen maintenance.

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

Docker PHP Images is released under the [MIT](https://github.com/chialab/docker-php/blob/master/LICENSE) license.
