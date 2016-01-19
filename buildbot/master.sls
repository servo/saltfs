buildbot:
  pip.installed:
    - pkgs:
      - buildbot == 0.8.12
      - service_identity == 14.0.0

txgithub:
  pip.installed

boto:
  pip.installed

buildbot-master:
  service.running:
    - enable: True
    - require:
      - pip: buildbot

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

buildbot-github-listener:
  service.running:
    - enable: True

/usr/local/bin/github_buildbot.py:
  file.managed:
    - source: salt://buildbot/github_buildbot.py
    - user: root
    - group: root
    - mode: 755
    - watch_in:
      - service: buildbot-github-listener

/etc/init/buildbot-github-listener.conf:
  file.managed:
    - source: salt://buildbot/buildbot-github-listener.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: buildbot-github-listener

find /home/servo/buildbot/master/*/*.bz2 -mtime +5 -exec rm {} ;:
  cron.present:
    - user: root
    - minute: 1 
    - hour: 0
