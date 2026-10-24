# EOL PHP versions

The official images stop receiving updates once a PHP version reaches end of life. For those
versions we build PHP ourselves from the official images' Dockerfiles, with security patches
applied to the sources, and use the result as the base image instead of `php:<tag>`.

- `<X.Y>/<flavor>/Dockerfile`: the official Dockerfiles, one per tag suffix (`cli`, `apache`,
  `fpm`, `alpine`, `fpm-alpine`).
- `patches/`: `docker-php-source-patch` and one `series.<X.Y>` per version, passed to the build
  as the `patches` named context.

The patches are deb.sury.org's, from the Debian PHP team's
[repository on Salsa](https://salsa.debian.org/php-team/php). Each Dockerfile downloads
`debian/patches` from the Salsa commit in its `DEB_PATCHES` into a `deb-patches` stage. Each
`series.<X.Y>` is an allow-list over that `series`: it names every patch in the same order, with
the ones left out commented as `# <reason>: <name>`. `docker-php-source-patch` fails the build if
the two lists differ, so a new deb.sury.org revision can't add a patch nobody has reviewed.

The build picks a directory up on its own: if `eol/<X.Y>/<flavor>` exists, the Makefile and
`build-images.yml` build it as the base image. No workflow lists EOL versions.

## Adding a version

Add it once deb.sury.org publishes patches for it: `make test` fails an EOL image whose `PHP_PATCHES`
is empty. Until then, keep building on the official image.

1. **Find the source.** Take the last [docker-library/php](https://github.com/docker-library/php)
   commit that still has the `<X.Y>/` directory. For each flavor, pick the variant the plain
   official tag pointed to: `<X.Y>/<debian-suite>/{cli,apache,fpm}` and
   `<X.Y>/alpine<N>/{cli,fpm}` for `alpine` and `fpm-alpine`.
2. **Copy the Dockerfiles** to `eol/<X.Y>/<flavor>/Dockerfile`, with the header used by the
   other versions linking the exact source path at that commit. Copy only the Dockerfile, not
   the scripts next to it: the build adds them from the same commit.
3. **Mark every change** with a `# chialab:` comment:
   - set `ARG DOCKER_PHP_SCRIPTS` to the raw URL of the source path
     (`https://raw.githubusercontent.com/docker-library/php/<commit>/<path>`) just before the
     first `COPY`, and replace the `COPY docker-php-*` and `COPY apache2-foreground` lines with
     `ADD --chmod=755 $DOCKER_PHP_SCRIPTS/<script> …`, one URL per script, as the other
     versions do (`ADD` gives downloaded files mode 600);
   - add the `deb-patches` stage before the first `FROM`, and the patch step right after
     `docker-php-source` is added, as in the other versions: `ENV PHP_PATCHES`,
     `LABEL it.chialab.php.patches` and the `RUN` that bind-mounts `deb-patches` and
     `patches/series.<X.Y>` and runs `docker-php-source-patch`;
   - once the OS release is archived, or a download host or keyserver disappears, fix it the
     same way the older versions do.
4. **Pin deb.sury.org's patches**: see below. The `.github/workflows/track-patches.yml` job picks
   the version up on its own.
5. **Update the range** of EOL versions in the main [README](../README.md).

## Updating deb.sury.org's patches

The `Track deb.sury.org patches` workflow opens an issue when deb.sury.org publishes a build of an
EOL version from a newer commit, listing the patches added to its `series`.

1. **Find the commit.** deb.sury.org's build versions end in `gbp` and the first 6 hex digits of the
   Salsa commit (`8.1.34-9+0~20261021.82+debian13~1.gbp4e430a`), listed in
   `https://packages.sury.org/php/dists/trixie/main/source/Sources.gz`.
2. **Update every flavour's Dockerfile** of the version: the full commit in `DEB_PATCHES`, and
   the deb.sury.org revision without epoch in `PHP_PATCHES` and the label
   (`deb.sury.org-8.1.34-9`).
3. **Review each new patch** and add it to `patches/series.<X.Y>`, either applied or commented out
   with its reason. Apply security and bug-fix backports and the test changes that come with them;
   leave out Debian packaging and paths, build changes for libraries or toolchains other than the
   version's base image, changed defaults and new features.
4. **Build and test** every flavour (`make build test VERSION=<tag>`). A patch that changes a
   `config.m4` only takes effect for extensions built later with `phpize`; one that changes a
   `.re` file takes effect because `re2c`, in `PHPIZE_DEPS`, regenerates its output.

