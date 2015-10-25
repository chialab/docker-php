# Docker PHP images
Docker images built on top of the [official PHP images](https://hub.docker.com/r/_/php/) with the addition of some common and useful extensions. You can find these images on the [Docker Hub](https://hub.docker.com/r/chialab/php/) (and if you're reading this file, you're probably already there).

An automated build is set up, so they should be always up-to-date with the Dockerfiles in the [GitHub repository](https://github.com/Chialab/docker-php). Also, every time an official PHP image is updated, a rebuild is triggered, so that you will always find the latest security patches installed in these images.

For development environments, you might want to choose an [image with XDebug installed](https://hub.docker.com/r/chialab/php-dev/), instead.

## Available tags and `Dockerfile` links
- [`latest` (_Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/Dockerfile)
- [`5.4-apache` (_5.4/apache/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/5.4/apache/Dockerfile)
- [`5.4-fpm` (_5.4/fpm/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/5.4/fpm/Dockerfile)
- [`5.5-apache` (_5.5/apache/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/5.5/apache/Dockerfile)
- [`5.5-fpm` (_5.5/fpm/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/5.5/fpm/Dockerfile)
- [`5.6-apache` (_5.6/apache/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/5.6/apache/Dockerfile)
- [`5.6-fpm` (_5.6/fpm/Dockerfile_)](https://github.com/Chialab/docker-php/blob/master/5.6/fpm/Dockerfile)

As you might have guessed, all tags are built on top of the corresponding tag of the official image. Not all tags are supported in order to easen manteinance.

## Installed extensions
The following modules and extensions have been enabled,
in addition to those you can already find in the [official PHP image](https://hub.docker.com/r/_/php/):

- `calendar`
- `iconv`
- `intl`
- `gd`
- `mbstring`
- `mcrypt`
- `memcached`
- `mysql`
- `mysqli`
- `pdo_mysql`
- `pdo_pgsql`
- `pgsql`
- `redis`
- `zip`

You will probably not need all this stuff. Even if having some extra extensions loaded ain't a big issue in most cases, you will very likely want to checkout this repository, remove unwanted extensions from the `Dockerfile`, and build your own image — for sometimes removing is easier than adding. 😉

## Known issues
- Image virtual size is over 600 MB 😞 Even though PHP official images themselves are over 450 MB, we will try to cut size down as much as we can.
- Tests are needed.

## Contributing
If you find an issue, or have a special wish not yet fulfilled, please [open an issue on GitHub](https://github.com/Chialab/docker-php/issues) providing as many details as you can (the more you are specific about your problem, the easier it is for us to fix it).

Pull requests are welcome, too! 😁 Please, check that things are working as expected before attempting a pull request, as there are no automated tests (yet) to perform such checks for you. Also, it would be nice if you could follow [best practices for writing Dockerfiles](https://docs.docker.com/articles/dockerfile_best-practices/).
