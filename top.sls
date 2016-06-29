# NOTE: Ensure all node types are covered in .travis.yml

base:
  '*':
    - common
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

  'servo-(mac|macpro)\d+':
    - match: pcre
    - buildbot.slave
    - nightly
    - osx
    - servo-build-dependencies

  'servo-linux\d+':
    - match: pcre
    - buildbot.slave
    - nightly
    - servo-build-dependencies
    - xvfb

  'servo-master\d+':
    - match: pcre
    - buildbot.master
    - git
    - homu
    - nginx
