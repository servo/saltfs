{% if grains["kernel"] != "Darwin" %}
{% set users_path = "/home" %}
{% else %}
{% set users_path = "/Users" %}
{% endif %}

buildbot-slave.pip:
  pip.installed:
    - name: buildbot-slave == 0.8.12

{{ users_path }}/servo/buildbot/slave:
  file.recurse:
    - source: salt://buildbot/slave
    - template: jinja
    - user: servo
    {% if grains["kernel"] != "Darwin" %}
    - group: servo
    {% else %}
    - group: staff
    {% endif %}
    - dir_mode: 755
    - file_mode: 644
    {% if grains["kernel"] != "Darwin" %}
    - watch_in:
      - service: buildbot-slave
    {% endif %}

{% if grains["kernel"] != "Darwin" %}

/etc/init/buildbot-slave.conf:
  file.managed:
    - source: salt://buildbot/buildbot-slave.conf
    - user: root
    {% if grains["kernel"] != "Darwin" %}
    - group: root
    {% else %}
    - group: wheel
    {% endif %}
    - mode: 644
    - watch_in:
      - service: buildbot-slave

buildbot-slave:
  service:
    - running
    - enable: True

{% else %}

/Library/LaunchDaemons/net.buildbot.buildslave.plist:
  file.managed:
    - source: salt://buildbot/net.buildbot.buildslave.plist
    - user: root
    - group: wheel
    - mode: 644

launchctl unload /Library/LaunchDaemons/net.buildbot.buildslave.plist:
  cmd.run

launchctl load -w /Library/LaunchDaemons/net.buildbot.buildslave.plist:
  cmd.run

{% endif %}

