# NOTE: Ensure all node types are covered in .travis.yml

base:
  '*':
    - admin
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
    - osx
    - buildbot.slave
    - servo-build-dependencies

  'servo-linux\d+':
    - match: pcre
    - buildbot.slave
    - servo-build-dependencies
    - xvfb

  'servo-master\d+':
    - match: pcre
    - git
    - buildbot.master
    - homu
    - nginx
    - salt.master
