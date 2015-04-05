base:
  '*':
    - common
    - servo-dependencies

  'servo-master':
    - buildbot-master
    - bors
    - homu
    - nginx

  'servo-(linux|mac)\d+':
    - match: pcre
    - buildbot-slave

  'servo-linux\d+':
    - match: pcre
    - xvfb

  'servo-linux-android\d+':
    - match: pcre
    - buildbot-slave
    - android-dependencies
    - gonk-dependencies

  'servo-head':
    - match: pcre
    - buildbot-slave
    - android-dependencies
