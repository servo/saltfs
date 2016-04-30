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

salt-master:
  pkg.installed:
    - name: {{ salt.master.pkg }}
    - version: {{ salt.master.version }}
    - require:
      - sls: salt.common
  service.running:
    - enable: True
    - require:  # Upgrades must be handled manually
      - pkg: salt-master
    - watch:
      - file: /etc/salt/master
