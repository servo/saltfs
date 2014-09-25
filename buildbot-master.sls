buildbot:
  pip.installed

/home/servo/buildbot/master:
  file.recurse:
    - source: salt://buildbot/master
    - template: jinja
    - user: servo
    - group: servo
    - dir_mode: 755
    - file_mode: 644
    - watch_in:
      - service: buildbot-master

/etc/init/buildbot-master.conf:
  file.managed:
    - source: salt://buildbot/buildbot-master.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: buildbot-master
    
buildbot-master:
  service:
    - running
    - enable: True

