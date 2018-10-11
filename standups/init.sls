{% from tpldir ~ '/map.jinja' import standups %}

include:
  - common
  - python

standups:
  virtualenv.managed:
    - name: /home/servo/standups/_venv
    - venv_bin: virtualenv-3.5
    - python: python3
    - system_site_packages: False
    - pip_pkgs:
      # This package is required to install the non-code resources that are present
      # in the tracker package's git repository.
      - setuptools-git
    - require:
      - pkg: python3
      - pip: virtualenv
  pip.installed:
    - pkgs:
      - git+https://github.com/servo/standups@{{ standups.rev }}
    - bin_env: /home/servo/standups/_venv
    - upgrade: True
    - require:
      - virtualenv: standups
  {% if grains.get('virtual_subtype', '') != 'Docker' %}
  service.running:
    - enable: True
    - name: standups
    - require:
      - pip: standups
    - watch:
      - file: /home/servo/standups/config.json
      - file: /etc/init/standups.conf
      - pip: standups
  {% endif %}

/home/servo/standups/config.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/config.json
    - template: jinja
    - user: servo
    - group: servo
    - mode: 644

/home/servo/standups/standups.json:
  file.managed:
    - user: servo
    - group: servo
    - mode: 644

/etc/init/standups.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/standups.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pip: standups
      - file: /home/servo/standups/config.json
      - file: /home/servo/standups/standups.json
