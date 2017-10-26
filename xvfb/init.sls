/etc/init/xvfb.conf:
  file.managed:
    - source: salt://xvfb/xvfb.conf
    - user: root
    - group: root
    - mode: 644

xvfb:
  pkg.installed: []
  {% if grains.get('virtual_subtype', '') != 'Docker' %}
  service.running:
    - enable: True
    - watch:
      - pkg: xvfb
      - file: /etc/init/xvfb.conf
  {% endif %}
