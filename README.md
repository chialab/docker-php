<p align="center">
    <a href="https://www.chialab.io/p/docker-php">
        <img alt="Docker PHP Images logo" width="144" height="144" src="https://raw.githack.com/chialab/docker-php/master/logo.svg" />
    </a>
</p>

<p align="center">
  <strong>Docker PHP images</strong>
</p>

<p align="center">
    <a href="https://travis-ci.org/chialab/docker-php"><img alt="Build Status" src="https://img.shields.io/travis/chialab/docker-php/master.svg?style=flat-square"></a>
    <a href="https://github.com/chialab/docker-php"><img alt="Source link" src="https://img.shields.io/badge/Source-GitHub-lightgrey.svg?style=flat-square"></a>
    <a href="https://www.chialab.it"><img alt="Authors link" src="https://img.shields.io/badge/Authors-Chialab-lightgrey.svg?style=flat-square"></a>
    <a href="https://hub.docker.com/r/chialab/php/"><img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/chialab/php.svg?style=flat-square"></a>
    <a href="https://github.com/chialab/docker-php/blob/master/LICENSE"><img alt="License" src="https://img.shields.io/github/license/chialab/docker-php.svg?style=flat-square"></a>
</p>

---

Docker images built on top of the [official PHP images](https://hub.docker.com/r/_/php/) with the addition of some common and useful extensions, installed with [mlocati/docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer). You can find these images on the [Docker Hub](https://hub.docker.com/r/chialab/php/) (and if you're reading this file, you're probably already there).

An automated build is set up, so they should be always up-to-date with the Dockerfiles in the [GitHub repository](https://github.com/Chialab/docker-php). Also, every time an official PHP image is updated, a rebuild is triggered, so that you will always find the latest security patches installed in these images.

For development environments, you might want to choose an [image with XDebug installed](https://hub.docker.com/r/chialab/php-dev/), instead.

## Available tags and `Dockerfile` links
- [`latest` (_Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/Dockerfile)
- [`5.4` (_5.4/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/5.4/Dockerfile)
- [`5.4-apache` (_5.4/apache/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/5.4/apache/Dockerfile)
- [`5.4-fpm` (_5.4/fpm/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/5.4/fpm/Dockerfile)
- [`5.5` (_5.5/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/5.5/Dockerfile)
- [`5.5-apache` (_5.5/apache/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/5.5/apache/Dockerfile)
- [`5.5-fpm` (_5.5/fpm/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/5.5/fpm/Dockerfile)
- [`5.6` (_5.6/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/5.6/Dockerfile)
- [`5.6-apache` (_5.6/apache/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/5.6/apache/Dockerfile)
- [`5.6-fpm` (_5.6/fpm/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/5.6/fpm/Dockerfile)
- [`7.0` (_7.0/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/7.0/Dockerfile)
- [`7.0-apache` (_7.0/apache/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/7.0/apache/Dockerfile)
- [`7.0-fpm` (_7.0/fpm/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/7.0/fpm/Dockerfile)
- [`7.1` (_7.1/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/7.1/Dockerfile)
- [`7.1-apache` (_7.1/apache/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/7.1/apache/Dockerfile)
- [`7.1-fpm` (_7.1/fpm/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/7.1/fpm/Dockerfile)
- [`7.2` (_7.2/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/7.2/Dockerfile)
- [`7.2-apache` (_7.2/apache/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/7.2/apache/Dockerfile)
- [`7.2-fpm` (_7.2/fpm/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/7.2/fpm/Dockerfile)
- [`7.3` (_7.3/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/7.3/Dockerfile)
- [`7.3-apache` (_7.3/apache/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/7.3/apache/Dockerfile)
- [`7.3-fpm` (_7.3/fpm/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/7.3/fpm/Dockerfile)
- [`7.4` (_7.4/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/7.4/Dockerfile)
- [`7.4-apache` (_7.4/apache/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/7.4/apache/Dockerfile)
- [`7.4-fpm` (_7.4/fpm/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/7.4/fpm/Dockerfile)

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
- `Zend OPcache`
- `zip`

You will probably not need all this stuff. Even if having some extra extensions loaded ain't a big issue in most cases, you will very likely want to checkout this repository, remove unwanted extensions from the `Dockerfile`, and build your own image — for sometimes removing is easier than adding. 😉

## Composer
[Composer](https://getcomposer.org) is installed globally in all images. Please, refer to their documentation for usage hints.

## Contributing
If you find an issue, or have a special wish not yet fulfilled, please [open an issue on GitHub](https://github.com/Chialab/docker-php/issues) providing as many details as you can (the more you are specific about your problem, the easier it is for us to fix it).

Pull requests are welcome, too! 😁 Please, run `make build` and `make test` before attempting a pull request. Also, it would be nice if you could stick to the [best practices for writing Dockerfiles](https://docs.docker.com/articles/dockerfile_best-practices/).

---

## License

Docker PHP Images is released under the [MIT](https://github.com/chialab/docker-php/blob/master/LICENSE) license.
