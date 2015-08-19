/etc/init/xvfb.conf:
  file.managed:
    - source: salt://xvfb/xvfb.conf
    - user: root
    - group: root
    - mode: 644

xvfb:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/init/xvfb.conf

