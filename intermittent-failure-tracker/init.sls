{% from 'common/map.jinja' import common %}
{% from tpldir ~ '/map.jinja' import tracker %}

include:
  - common
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
  service.running:
    - enable: True
    - name: failure-tracker
    - require:
      - pip: intermittent-failure-tracker
    - watch:
      - file: /home/servo/intermittent-failure-tracker/config.json
      - file: /lib/systemd/system/failure-tracker.service
      - pip: intermittent-failure-tracker

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
    - replace: False

/lib/systemd/system/failure-tracker.service:
  file.managed:
    - source: salt://{{ tpldir }}/files/tracker.service
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        common: {{ common }}
    - require:
      - pip: intermittent-failure-tracker
      - file: /home/servo/intermittent-failure-tracker/config.json
      - file: /home/servo/intermittent-failure-tracker/intermittent_errors.json
