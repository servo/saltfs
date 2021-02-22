{% from 'common/map.jinja' import common %}
{% from tpldir ~ '/map.jinja' import homu %}

include:
  - common
  - python

homu-debugging-packages:
  pkg.installed:
    - pkgs:
      - sqlite3

homu:
  virtualenv.managed:
    - name: /home/servo/homu/_venv
    - venv_bin: virtualenv-3.5
    - python: python3
    - system_site_packages: False
    - require:
      - pkg: python3
      - pip: virtualenv
  pip.installed:
    - pkgs:
      - git+https://github.com/servo/homu@{{ homu.rev }}
      - toml==0.9.1  # Please ensure this is in sync with requirements.txt
      # Pin all other dependencies
      - appdirs==1.4.0
      - bottle==0.12.19
      - certifi==2017.4.17
      - chardet==3.0.3
      - github3.py==0.9.6
      - idna==2.5
      - Jinja2==2.9.6
      - MarkupSafe==1.1
      - packaging==16.8
      - pyparsing==2.1.10
      - requests==2.24.0
      - retrying==1.3.3
      - six==1.10.0
      - toml==0.9.1
      - uritemplate==3.0.0
      - uritemplate.py==3.0.2
      - urllib3==1.25.9
      - waitress==1.4.3
    - upgrade: True
    - bin_env: /home/servo/homu/_venv
    - require:
      - virtualenv: homu
  service.running:
    - enable: True
    - require:
      - pip: homu
    - watch:
      - file: /home/servo/homu/cfg.toml
      - file: /lib/systemd/system/homu.service
      - pip: homu

{{ salt['file.dirname'](homu.db) }}:
  file.directory:
    - user: servo
    - group: servo
    - dir_mode: 700
    - require_in:
      - file: /home/servo/homu/cfg.toml

/home/servo/homu/cfg.toml:
  file.managed:
    - source: salt://{{ tpldir }}/files/cfg.toml
    - user: servo
    - group: servo
    - mode: 644
    - template: jinja
    - context:
        db: {{ homu.db }}
        homu: {{ homu }}
        secrets: {{ pillar['homu']|tojson }}

/lib/systemd/system/homu.service:
  file.managed:
    - source: salt://{{ tpldir }}/files/homu.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        common: {{ common }}
    - require:
      - pip: homu
      - file: /home/servo/homu/cfg.toml
