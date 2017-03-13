# Servo's SaltStack Configuration

[![Build Status](https://travis-ci.org/servo/saltfs.svg)](https://travis-ci.org/servo/saltfs)

## What's going on?

Salt is a configuration management tool that we use to automate Servo's
infrastructure. See [the tutorials](https://docs.saltstack.com/en/2016.3/topics/tutorials/index.html) to get started.

## Contributing

There are guides available on [the servo wiki](https://github.com/servo/servo/wiki/Buildbot-administration),
as well as some documention in-tree in the `docs` folder.
If you see a way that these configurations could be improved, or try to set up
your own instance and run into trouble, file [an issue](https://github.com/servo/saltfs/issues/new)!

## Travis

TravisCI is set up to test all configurations.

## License

This repository is distributed under the terms of both the MIT license
and the Apache License (Version 2.0).

See [LICENSE-APACHE](LICENSE-APACHE) and [LICENSE-MIT](LICENSE-MIT) for details.

Note that some files in underscore-prefix directories (e.g. under `_modules`)
are copies (possibly with changes) of files from the
[main Salt repo](https://github.com/saltstack/salt); these files have headers
detailing the source of those files, any changes made, and the original license
notice associated with those files.
