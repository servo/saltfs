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

  'servo-linux-kvm\d+':
    - match: pcre
    - buildbot.slave
    - servo-build-dependencies
    - servo-build-dependencies.kvm
    - servo-build-dependencies.java
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
    - servo-build-dependencies.linux-gstreamer
    - xvfb

  'servo-windows\d+':
    - match: pcre
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
