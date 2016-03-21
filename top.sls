# NOTE: Ensure all node types are covered in .travis.yml

base:
  '*':
    - common
    - servo-build-dependencies

  'os:Ubuntu':
    - match: grain
    - ubuntu

  'servo-head':
    - buildbot.slave
    - servo-build-dependencies.android

  'servo-linux-cross\d+':
    - match: pcre
    - buildbot.slave
    - servo-build-dependencies.android
    - servo-build-dependencies.gonk
    - servo-build-dependencies.arm

  'servo-(mac|macpro)\d+':
    - match: pcre
    - osx
    - buildbot.slave

  'servo-linux\d+':
    - match: pcre
    - buildbot.slave
    - xvfb

  'servo-master':
    - buildbot.master
    - homu
    - nginx
    - longview
