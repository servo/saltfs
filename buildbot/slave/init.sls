{% from 'common/map.jinja' import common %}

include:
  - python

buildbot-slave-dependencies:
  pip.installed:
    - pkgs:
      - buildbot-slave == 0.8.12
      - twisted == 16.6.0 # NOTE: keep in sync with buildbot-master sls
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
    - require:
      - user: servo

{% if grains['kernel'] == 'Darwin' %}

/Library/LaunchDaemons/net.buildbot.buildslave.plist:
  file.managed:
    - source: salt://{{ tpldir }}/files/net.buildbot.buildslave.plist
    - user: root
    - group: wheel
    - mode: 644
    - watch_in:
      - service: buildbot-slave

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
    {% if grains.get('virtual_subtype', '') != 'Docker' %}
    - watch_in:
      - service: buildbot-slave
    {% endif %}

{% endif %}

{% if grains.get('virtual_subtype', '') != 'Docker' %}
buildbot-slave:
  service.running:
    - enable: True
    - require:
      - user: servo
    - watch:
      - pip: buildbot-slave-dependencies
      - file: {{ common.servo_home }}/buildbot/slave
{% endif %}

{% if grains.get('virtual_subtype', '') != 'Docker' and grains['kernel'] == 'Linux' %}
coreutils:
  pkg.installed

/swapfile:
  cmd.run:
    - name: |
        [ -f /swapfile ] || dd if=/dev/zero of=/swapfile bs=1M count=2048k
        chmod 0600 /swapfile
        mkswap /swapfile
        swapon -a
    - unless:
      - file /swapfile 2>&1 | grep -q "Linux/i386 swap"
  mount.swap:
    - persist: true
{% endif %}
