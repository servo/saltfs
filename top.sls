base:
  '*':
    - common
    - servo-dependencies

  'servo-master':
    - buildbot.master
    - homu
    - nginx

  'servo-(linux|mac|macpro)\d+':
    - match: pcre
    - buildbot.slave

  'servo-linux\d+':
    - match: pcre
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
    - match: pcre
    - buildbot.slave
    - android-dependencies
