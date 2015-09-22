/etc/init/xvfb.conf:
  file.managed:
    - source: salt://xvfb/xvfb.conf
    - user: root
    - group: root
    - mode: 644

xvfb:
  pkg.installed: []
  service.running:
    - enable: True
    - require:
      - pkg: xvfb
    - watch:
      - file: /etc/init/xvfb.conf
