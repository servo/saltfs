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

/var/root/remove-build-directories:
  file.managed:
    - user: root
    - group: wheel
    - mode: 654
    - source: salt://{{ tpldir }}/files/remove-build-directories

disable-homebrew-analytics:
  homebrew_analytics.managed:
    - name: disabled
