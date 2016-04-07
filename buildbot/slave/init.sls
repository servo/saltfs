{% from 'common/map.jinja' import common %}

buildbot-slave-dependencies:
  pip.installed:
    - pkgs:
      - buildbot-slave == 0.8.12
    - require:
      - pkg: pip

{{ common.servo_home }}/buildbot/slave:
  file.recurse:
    - source: salt://{{ tpldir }}/files/config
    - user: servo
    {% if grains['kernel'] == 'Darwin' %}
    - group: staff
    {% else %}
    - group: servo
    {% endif %}
    - dir_mode: 755
    - file_mode: 644
    - template: jinja
    - context:
        common: {{ common }}
    {% if grains['kernel'] != 'Darwin' %}
    - watch_in:
      - service: buildbot-slave
    {% endif %}

{% if grains['kernel'] == 'Darwin' %}

/Library/LaunchDaemons/net.buildbot.buildslave.plist:
  file.managed:
    - source: salt://{{ tpldir }}/files/net.buildbot.buildslave.plist
    - user: root
    - group: wheel
    - mode: 644

launchctl unload /Library/LaunchDaemons/net.buildbot.buildslave.plist:
  cmd.run

launchctl load -w /Library/LaunchDaemons/net.buildbot.buildslave.plist:
  cmd.run

{% else %}

/etc/init/buildbot-slave.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/buildbot-slave.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        common: {{ common }}
    - watch_in:
      - service: buildbot-slave

buildbot-slave:
  service.running:
    - enable: True

{% endif %}
