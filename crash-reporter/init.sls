{% from 'common/map.jinja' import common %}
{% from tpldir ~ '/map.jinja' import crashreporter %}

include:
  - common
  - python

crash-reporter:
  virtualenv.managed:
    - name: /home/servo/crash-reporter/_venv
    - venv_bin: virtualenv-3.5
    - python: python3
    - system_site_packages: False
    - require:
      - pkg: python3
      - pip: virtualenv
  pip.installed:
    - pkgs:
      - git+https://github.com/servo/crash-reporter@{{ crashreporter.rev }}
    - bin_env: /home/servo/crash-reporter/_venv
    - upgrade: True
    - require:
      - virtualenv: crash-reporter
  service.running:
    - enable: True
    - name: crashreporter
    - require:
      - pip: crash-reporter
    - watch:
      - file: /home/servo/crash-reporter/config.json
      - file: /lib/systemd/system/crashreporter.service
      - pip: crash-reporter

/home/servo/crash-reporter/config.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/config.json
    - template: jinja
    - user: servo
    - group: servo
    - mode: 644

/lib/systemd/system/crashreporter.service:
  file.managed:
    - source: salt://{{ tpldir }}/files/crashreporter.service
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        common: {{ common }}
    - require:
      - pip: crash-reporter
      - file: /home/servo/crash-reporter/config.json
