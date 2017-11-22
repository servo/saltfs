# NOTE: Ensure all node types are covered in .travis.yml

base:
  'not G@os:Windows':
    - match: compound
    - admin
    - common
    - python
    - salt.common

  'os:Ubuntu':
    - match: grain
    - ubuntu

  'servo-linux-cross\d+':
    - match: pcre
    - buildbot.slave
    - servo-build-dependencies
    - servo-build-dependencies.android
    - servo-build-dependencies.arm
    - servo-build-dependencies.ci

  'servo-(mac|macpro)\d+':
    - match: pcre
    - osx
    - buildbot.slave
    - servo-build-dependencies
    - servo-build-dependencies.ci

  'servo-linux\d+':
    - match: pcre
    - buildbot.slave
    - servo-build-dependencies
    - servo-build-dependencies.aws
    - servo-build-dependencies.ci
    - xvfb

  'servo-windows\d+':
    - servo-build-dependencies.ci

  'servo-master\d+':
    - match: pcre
    - git
    - buildbot.master
    - homu
    - intermittent-tracker
    - intermittent-failure-tracker
    - upstream-wpt-webhook
    - nginx
    - salt.master
