base:
  '*':
    - travis
    - buildbot.common

  'servo-master':
    - buildbot.master
    - homu

  'servo-(linux|mac|macpro)\d+':
    - match: pcre
    - buildbot.slave

  'linux\d+':
    - match: pcre
    - buildbot.slave

  'servo-linux-android\d+':
    - match: pcre
    - buildbot.slave

  'servo-head':
    - buildbot.slave
