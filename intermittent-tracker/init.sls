{% from 'common/map.jinja' import common %}
{% from tpldir ~ '/map.jinja' import tracker %}

include:
  - common
  - python

tracker-debugging-packages:
  pip.installed:
    - pkgs:
      - github3.py == 1.0.0a4

intermittent-tracker:
  virtualenv.managed:
    - name: /home/servo/intermittent-tracker/_venv
    - venv_bin: virtualenv
    - python: python3
    - system_site_packages: False
    - require:
      - pkg: python3
      - pip: virtualenv
  pip.installed:
    - pkgs:
      - git+https://github.com/servo/intermittent-tracker@{{ tracker.rev }}
    - bin_env: /home/servo/intermittent-tracker/_venv
    - upgrade: True
    - require:
      - virtualenv: intermittent-tracker
  service.running:
    - enable: True
    - name: tracker
    - require:
      - pip: intermittent-tracker
    - watch:
      - file: /home/servo/intermittent-tracker/config.json
      - file: /lib/systemd/system/tracker.service
      - pip: intermittent-tracker

/home/servo/intermittent-tracker/config.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/config.json
    - template: jinja
    - user: servo
    - group: servo
    - mode: 644

/lib/systemd/system/tracker.service:
  file.managed:
    - source: salt://{{ tpldir }}/files/tracker.service
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        common: {{ common }}
    - require:
      - pip: intermittent-tracker
      - file: /home/servo/intermittent-tracker/config.json
