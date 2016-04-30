{% from tpldir ~ '/map.jinja' import salt %}

include:
  - .common

salt-master:
  pkg.installed:
    - name: {{ salt.master.pkg.name }}
    - version: {{ salt.master.pkg.version }}
    - require:
      - sls: salt.common
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
