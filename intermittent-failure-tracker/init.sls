{% from tpldir ~ '/map.jinja' import tracker %}

include:
  - python

intermittent-failure-tracker:
  virtualenv.managed:
    - name: /home/servo/intermittent-failure-tracker/_venv
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
      - git+https://github.com/servo/intermittent-failure-tracker@{{ tracker.rev }}
    - bin_env: /home/servo/intermittent-failure-tracker/_venv
    - upgrade: True
    - require:
      - virtualenv: intermittent-failure-tracker
  {% if grains.get('virtual_subtype', '') != 'Docker' %}
  service.running:
    - enable: True
    - name: failure-tracker
    - require:
      - pip: intermittent-failure-tracker
    - watch:
      - file: /home/servo/intermittent-failure-tracker/config.json
      - file: /etc/init/failure-tracker.conf
      - pip: intermittent-failure-tracker
  {% endif %}

/home/servo/intermittent-failure-tracker/config.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/config.json
    - template: jinja
    - user: servo
    - group: servo
    - mode: 644

/home/servo/intermittent-failure-tracker/intermittent_errors.json:
  file.managed:
    - user: servo
    - group: servo
    - mode: 644

/etc/init/failure-tracker.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/tracker.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pip: intermittent-failure-tracker
      - file: /home/servo/intermittent-failure-tracker/config.json
      - file: /home/servo/intermittent-failure-tracker/intermittent_errors.json
