buildbot-master:
  pip.installed:
    - pkgs:
      - buildbot == 0.8.12
      - service_identity == 14.0.0
      - txgithub == 15.0.0
      - boto == 2.38.0
    - require:
      - pkg: pip
  service.running:
    - enable: True
    - require:
      - pip: buildbot-master
    - watch:
      - file: /home/servo/buildbot/master
      - file: /etc/init/buildbot-master.conf

/home/servo/buildbot/master:
  file.recurse:
    - source: salt://buildbot/master
    - template: jinja
    - user: servo
    - group: servo
    - dir_mode: 755
    - file_mode: 644

/etc/init/buildbot-master.conf:
  file.managed:
    - source: salt://buildbot/buildbot-master.conf
    - user: root
    - group: root
    - mode: 644

/usr/local/bin/github_buildbot.py:
  file.managed:
    - source: salt://buildbot/github_buildbot.py
    - user: root
    - group: root
    - mode: 755

/etc/init/buildbot-github-listener.conf:
  file.managed:
    - source: salt://buildbot/buildbot-github-listener.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644

buildbot-github-listener:
  service.running:
    - enable: True
    - watch:
      - file: /usr/local/bin/github_buildbot.py
      - file: /etc/init/buildbot-github-listener.conf
