/etc/sysctl.conf:
  file.managed:
    - user: root
    - group: wheel
    - mode: 644
    - source: salt://{{ tpldir }}/files/sysctl.conf

/etc/profile:
  file.managed:
    - user: root
    - group: wheel
    - mode: 644
    - source: salt://{{ tpldir }}/files/profile
