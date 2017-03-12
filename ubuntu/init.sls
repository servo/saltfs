# Disable service autostart on package install
# Use Salt to manage service [re-]start on package change
/usr/sbin/policy-rc.d:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - source: salt://{{ tpldir }}/files/policy-rc.d

# Workaround for https://github.com/saltstack/salt/issues/26605:
# For each pkgrepo state which adds any repositories to the sources.list.d
# folder (instead of the main /etc/apt/sources.list file), create an extra,
# no-op file.exists state which requires the pkgrepo state and require_ins
# this state
/etc/apt/sources.list.d:
  file.directory:
    - user: root
    - group: root
    - file_mode: 644
    - dir_mode: 755
    - recurse:
      - user
      - group
      - mode
    - clean: True

/etc/apt/sources.list:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://{{ tpldir }}/files/sources.list
