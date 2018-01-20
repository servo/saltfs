base:
  '*':
    - travis
    - buildbot.common

  'servo-master\d+':
    - match: pcre
    - buildbot.master
    - homu
    - wpt-sync

  'servo-(linux|mac|macpro)\d+':
    - match: pcre
    - buildbot.slave

  'linux\d+':
    - match: pcre
    - buildbot.slave

  'servo-linux-cross\d+':
    - match: pcre
    - buildbot.slave
