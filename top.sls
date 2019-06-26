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

  'servo-linux\d+':
    - match: pcre
    - buildbot.slave
    - servo-build-dependencies
    - servo-build-dependencies.aws
    - servo-build-dependencies.ci
    - servo-build-dependencies.linux-gstreamer
    - xvfb

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
    - standups
