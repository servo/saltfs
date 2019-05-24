{% from 'common/map.jinja' import common %}
{% from 'homu/map.jinja' import homu %}

include:
  - common
  - python

buildbot-master:
  pip.installed:
    - pkgs:
      - buildbot == 0.8.12
      - service_identity == 14.0.0
      - txgithub == 15.0.0
      - boto == 2.38.0
      - pyyaml == 3.11
      - twisted == 16.6.0  # NOTE: keep in sync with buildbot-slave sls
    - require:
      - pkg: pip
  {% if grains.get('virtual_subtype', '') != 'Docker' %}
  service.running:
    - enable: True
    # Buildbot must be restarted manually! See 'Buildbot administration' on the
    # wiki and https://github.com/servo/saltfs/issues/304.
    - require:
      - user: servo
      - pip: buildbot-master
      - file: ownership-{{ common.servo_home }}/buildbot/master
      - file: /lib/systemd/system/buildbot-master.service
  {% endif %}

deploy-{{ common.servo_home }}/buildbot/master:
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
        homu: {{ homu }}
        buildbot_credentials: {{ pillar['buildbot']['credentials'] }}
        wpt_sync_credentials: {{ pillar['wpt-sync'] }}
    - require:
      - user: servo

ownership-{{ common.servo_home }}/buildbot/master:
  file.directory:
    - name: {{ common.servo_home }}/buildbot/master
    - user: servo
    - group: servo
    - recurse:
      - user
      - group
    - require:
      - file: deploy-{{ common.servo_home }}/buildbot/master

/lib/systemd/system/buildbot-master.service:
  file.managed:
    - source: salt://{{ tpldir }}/files/buildbot-master.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        common: {{ common }}

/usr/local/bin/github_buildbot.py:
  file.managed:
    - source: salt://{{ tpldir }}/files/github_buildbot.py
    - user: root
    - group: root
    - mode: 755

/lib/systemd/system/buildbot-github-listener.service:
  file.managed:
    - source: salt://{{ tpldir }}/files/buildbot-github-listener.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        common: {{ common }}

{% if grains.get('virtual_subtype', '') != 'Docker' %}
buildbot-github-listener:
  service.running:
    - enable: True
    - watch:
      - file: /usr/local/bin/github_buildbot.py
      - file: /lib/systemd/system/buildbot-github-listener.service
{% endif %}

remove-old-build-logs:
  cron.present:
    - name: 'find {{ common.servo_home }}/buildbot/master/*/*.bz2 -mtime +5 -delete'
    - user: root
    - minute: 1
    - hour: 0
