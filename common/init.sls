{% from tpldir ~ '/map.jinja' import common %}

servo:
  user.present:
    - fullname: Tom Servo
    - shell: /bin/bash
    - home: {{ common.servo_home }}

{% if grains['os'] == 'Ubuntu' %}
utf8_locale:
  locale.present:
    - name: en_US.UTF-8

default_locale:
  locale.system:
    - name: en_US.UTF-8
    - require:
      - locale: utf8_locale
{% endif %}
