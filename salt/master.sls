{% from tpldir ~ '/map.jinja' import salt %}

include:
  - .common

/etc/salt/master:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - contents: |
        {{ salt.master.config|yaml(False)|indent(8) }}

python-git:  # GitPython for gitfs
  pkg.installed

{% for base_rootfs_dir in salt.master.config.file_roots.base %}
{{ base_rootfs_dir }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755

{{ base_rootfs_dir }}/ADMIN_README:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://{{ tpldir }}/files/master/ADMIN_README
{% endfor %}

salt-master:
  pkg.installed:
    - name: {{ salt.master.pkg }}
    - version: {{ salt.master.version }}
    - require:
      - pkg: python-git
      - sls: salt.common
  service.running:
    - enable: True
    - require:  # Upgrades must be handled manually
      - pkg: salt-master
    - watch:
      - file: /etc/salt/master
