{% from tpldir ~ '/map.jinja' import salt, salt_ %}

include:
  - .common

# Python modules for extra Salt master functionality
salt-master-dependencies:
  pkg.installed:
    - pkgs:
      - python-git # GitPython for gitfs

{% for base_rootfs_dir in salt.master.config.file_roots.base %}
{% set rootfs_parent_dir = salt_['file.dirname'](base_rootfs_dir) %}
{{ rootfs_parent_dir }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - require_in:
      - service: salt-master

{{ rootfs_parent_dir }}/ADMIN_README:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://{{ tpldir }}/files/master/ADMIN_README
    - require_in:
      - service: salt-master
{% endfor %}

salt-master:
  pkg.installed:
    - name: {{ salt.master.pkg.name }}
    - version: {{ salt.master.pkg.version }}
    - require:
      - sls: salt.common
      - pkg: salt-master-dependencies
  service.running:
    - enable: True
    - require:  # Updates and upgrades must be handled manually
      - file: /etc/salt/master
      - pkg: salt-master

/etc/salt/master:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - contents: |
        {{ salt.master.config|yaml(False)|indent(8) }}
    - require:
      - pkg: salt-master
