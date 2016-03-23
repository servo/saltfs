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

  'servo-linux-cross\d+':
    - match: pcre
    - buildbot.slave
