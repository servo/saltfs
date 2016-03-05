# Disable service autostart on package install
# Use Salt to manage service [re-]start on package change
/usr/sbin/policy-rc.d:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - source: salt://{{ tpldir }}/files/policy-rc.d

# Workaround for https://github.com/saltstack/salt/issues/26605
# Clean the directory first, and require it in all pkgrepo states
# which add repositories to the sources.list.d folder (instead of
# the main /etc/apt/sources.list file)
/etc/apt/sources.list.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - recurse:
      - user
      - group
      - mode
    - clean: True
