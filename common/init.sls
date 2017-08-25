{% from tpldir ~ '/map.jinja' import common %}

servo:
  user.present:
    - fullname: Tom Servo
    - shell: /bin/bash
    - home: {{ common.servo_home }}

{% if grains['os'] == 'Ubuntu' %}
locales-directory:
  # locale.present is a little fragile and needs this dir
  cmd.run:
    - name: mkdir -p /usr/share/i18n/locales
    - unless: test -d /usr/share/i18n/locales

utf8_locale:
  locale.present:
    - name: en_US.UTF-8

default_locale:
  locale.system:
    - name: en_US.UTF-8
    - require:
      - locale: utf8_locale
{% endif %}
