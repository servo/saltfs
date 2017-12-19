# Docker usage

## Overview

As part of a move to [TaskCluster](https://docs.taskcluster.net/),
we are moving Linux builds from VMs
to [Docker](https://www.docker.com/) containers.
The Dockerfile in this repository will be used to create container images
that are suitable for running Servo builds.
To ease the transition, we will reuse our [Salt](https://saltstack.com/)
rules for provisioning in containers.

In the future, the Dockerfile and supporting files will be moved into the main
Servo repository.
This will allow our decision task to rebuild our Docker
images when there are any changes,
to enable making builder configuration changes concurrently with code changes,
e.g. adding a new dependency.

## Usage

To build manually, run from the saltfs root:
```sh
$ sudo docker build .
```

Currently, this creates an image capable only of building Servo itself,
not testing (no Xvfb) or cross-compiling (Android, ARM, etc.) yet.
