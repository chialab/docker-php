# EOL PHP versions

The official images stop receiving updates once a PHP version reaches end of life. For those
versions we build PHP ourselves from the official images' Dockerfiles, with security patches
applied to the sources, and use the result as the base image instead of `php:<tag>`.

- `<X.Y>/<flavor>/Dockerfile`: the official Dockerfiles, one per tag suffix (`cli`, `apache`,
  `fpm`, `alpine`, `fpm-alpine`).
- `scripts/`: the helper scripts copied into the images (`docker-php-*`, `apache2-foreground`),
  passed to the build as the `scripts` named context.
- `patches/`: `docker-php-source-patch` and one `<X.Y>/series` of patches per version, passed to
  the build as the `patches` named context.

The build picks a directory up on its own: if `eol/<X.Y>/<flavor>` exists, the Makefile and
`build-images.yml` build it as the base image. No workflow lists EOL versions.

## Adding a version

Add it once there is a security patch to apply: `make test` fails an EOL image whose
`PHP_PATCHES` is empty. Until then, keep building on the official image.

1. **Find the source.** Take the last [docker-library/php](https://github.com/docker-library/php)
   commit that still has the `<X.Y>/` directory. For each flavor, pick the variant the plain
   official tag pointed to: `<X.Y>/<debian-suite>/{cli,apache,fpm}` and
   `<X.Y>/alpine<N>/{cli,fpm}` for `alpine` and `fpm-alpine`.
2. **Copy the Dockerfiles** to `eol/<X.Y>/<flavor>/Dockerfile`, with the header used by the
   other versions linking the exact source path at that commit. Copy only the Dockerfile, not
   the scripts next to it.
3. **Mark every change** with a `# chialab:` comment:
   - replace the `COPY docker-php-*` and `COPY apache2-foreground` lines with
     `COPY --from=scripts …` (see [Scripts](#scripts));
   - add the patch step right after `docker-php-source` is copied, as in the other versions:
     `ENV PHP_PATCHES`, `LABEL it.chialab.php.patches` and the `RUN` that bind-mounts
     `patches/<X.Y>` and runs `docker-php-source-patch`;
   - once the OS release is archived, or a download host or keyserver disappears, fix it the
     same way the older versions do.
4. **Add the patches** to `patches/<X.Y>/` and list them in its `series`, with a comment
   linking where each one comes from.
5. **Update the range** of EOL versions in the main [README](../README.md).

## Scripts

Each script in `scripts/` covers a range of PHP versions. Versioned scripts are named after the
first version that uses them, and serve every later version until the next file: for example,
`docker-php-ext-install/7.4` is used by both 7.4 and 8.0, and 8.1 has its own file.
Entrypoints vary by flavor rather than version, so they're named `cli` (also for `alpine`),
`fpm` (also for `fpm-alpine`) and `apache`.

When adding a version, compare each script from the docker-library directory with the newest
file in `scripts/`:

- if it's identical, point the new Dockerfile at that file;
- if it differs, add it as `scripts/<script>/<X.Y>` and point the new Dockerfile at it.

`docker-php-source` and `apache2-foreground` are the same for every version so far, so they
have no version directory. If a new version changes one of them, move it into one, like the
other scripts.
