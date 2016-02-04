# NOTE: Ensure all node types are covered in .travis.yml

base:
  '*':
    - common
    - servo-dependencies

  'servo-master':
    - buildbot.master
    - homu
    - nginx

  'servo-(mac|macpro)\d+':
    - match: pcre
    - buildbot.slave

  'servo-linux\d+':
    - match: pcre
    - buildbot.slave
    - xvfb

  'linux\d+':
    - match: pcre
    - buildbot.slave
    - xvfb

  'servo-linux-android\d+':
    - match: pcre
    - buildbot.slave
    - android-dependencies
    - gonk-dependencies

  'servo-head':
    - buildbot.slave
    - android-dependencies
