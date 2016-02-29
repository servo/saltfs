# Disable service autostart on package install
# Use Salt to manage service [re-]start on package change
/usr/sbin/policy-rc.d:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - source: salt://{{ tpldir }}/files/policy-rc.d
