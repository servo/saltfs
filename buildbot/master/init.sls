{% from 'common/map.jinja' import common %}

buildbot-config:
  file.recurse:
    - name: {{ common.servo_home }}/buildbot/master
    - source: salt://{{ tpldir }}/files/config
    - user: servo
    - group: servo
    - dir_mode: 755
    - file_mode: 644
    - template: jinja
    - context:
        common: {{ common }}
        buildbot_credentials: {{ pillar['buildbot']['credentials'] }}
    - require:
      - user: servo

buildbot-config-ownership:
  file.directory:
    - name: {{ common.servo_home }}/buildbot/master
    - user: servo
    - group: servo
    - recurse:
      - user
      - group
    - require:
      - user: servo
      - file: buildbot-config

/usr/local/bin/stop-buildbot.py:
  file.managed:
    - source: salt://{{ tpldir }}/files/stop-buildbot.py
    - user: root
    - group: root
    - mode: 755

buildbot-master:
  pip.installed:
    - pkgs:
      - buildbot == 0.8.12
      - service_identity == 14.0.0
      - txgithub == 15.0.0
      - boto == 2.38.0
      - pyyaml == 3.11
    - require:
      - pkg: pip
  cmd.run:  # Need to create/upgrade DB file on new Buildbot version
    - name: |
        '/usr/local/bin/stop-buildbot.py' \
            '{{ common.servo_home }}/buildbot/master' \
        && buildbot upgrade-master '{{ common.servo_home }}/buildbot/master'
    - runas: servo
    - env:
      - PYTHONDONTWRITEBYTECODE: "1"
    - require:
      - user: servo
      - file: buildbot-config-ownership
      - file: /usr/local/bin/stop-buildbot.py
    - onchanges:
      - pip: buildbot-master
  file.managed:
    - name:  /etc/init/buildbot-master.conf
    - source: salt://{{ tpldir }}/files/buildbot-master.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        common: {{ common }}
  service.running:
    - enable: True
    # Buildbot must be restarted manually! See 'Buildbot administration' on the
    # wiki and https://github.com/servo/saltfs/issues/304.
    - require:
      - pip: buildbot-master
      - file: buildbot-config-ownership
      - cmd: buildbot-master
      - file: buildbot-master


/usr/local/bin/github_buildbot.py:
  file.managed:
    - source: salt://{{ tpldir }}/files/github_buildbot.py
    - user: root
    - group: root
    - mode: 755

buildbot-github-listener:
  file.managed:
    - name: /etc/init/buildbot-github-listener.conf
    - source: salt://{{ tpldir }}/files/buildbot-github-listener.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        common: {{ common }}
  service.running:
    - enable: True
    - watch:
      - file: /usr/local/bin/github_buildbot.py
      - file: buildbot-github-listener


remove-old-build-logs:
  cron.present:
    - name: 'find {{ common.servo_home }}/buildbot/master/*/*.bz2 -mtime +5 -delete'
    - user: root
    - minute: 1
    - hour: 0
