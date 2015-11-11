# Style Guide

Style guide for Salt states (and other code) in this repo. Unfortunately,
no linter exists yet for Salt states, so there is no automated way to
check for compliance with this guide.

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
buildbot-dependencies:
  pip.installed:
    - name: buildbot == 0.8.12
```

*Better*:

```salt
buildbot-dependencies:
  pip.installed:
    - pkgs:
      - buildbot == 0.8.12
```
