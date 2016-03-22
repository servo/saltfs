# Style Guide

Style guide for Salt states (and other code) in this repo. Unfortunately,
no linter exists yet for Salt states, so there is no automated way to
check for compliance with this guide.

## General

### Downloads

URLs used for downloads should always use HTTPS.

Note that APT repos are currently an exception - they don't seem to like
HTTPS urls, but they're GPG signed so this is OK.

### Hash functions

Hashes used for download/file verification should be SHA512 or stronger.

## Jinja Usage

### Imports

Guidelines for Jinja imports in .sls files:
 - Put import statements at the top of the file
 - Order import statements from the same directory first
 - Prefer this form for imports from the same directory:

   ```jinja
   {% from tpldir ~ '/map.jinja' import example %}
   ```
 - Prefer this form for imports from other directories:

   ```jinja
   {% from 'common/map.jinja' import common %}
   ```
 - Avoid `with context` because it's unnecessary and inefficient
 - Use meaningful names for variables set in `map.jinja` files,
   e.g. avoid `config`, for clarity when imported into other files

## Package Installation

### Use pkgs instead of name

`pkg.installed`, `pip.installed`, and any other states which install packages
should use the ```pkgs``` option instead of the ```name``` option to specify
which package(s) to install, even if there is only one package. This prevents
problems when adding another package, as in #132 (fixed in #97). Adding another
name option will cause the earlier option to be silently swallowed, which can
be hard to debug. Using pkgs from the beginning ensures correct behavior
regardless of the number of packages.

*Unsafe*:

```salt
essential-dependencies:
  pkg.installed:
    - name: cowsay
```

*Better*:

```salt
essential-dependencies:
  pkg.installed:
    - pkgs:
      - cowsay
```
