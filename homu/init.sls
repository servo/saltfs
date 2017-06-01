{% from tpldir ~ '/map.jinja' import homu %}

include:
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
      - bottle==0.12.13
      - certifi==2017.4.17
      - chardet==3.0.3
      - github3.py==0.9.6
      - homu==0.2.0
      - idna==2.5
      - Jinja2==2.9.6
      - MarkupSafe==1.0
      - packaging==16.8
      - pyparsing==2.1.10
      - requests==2.14.2
      - retrying==1.3.3
      - six==1.10.0
      - toml==0.9.1
      - uritemplate==3.0.0
      - uritemplate.py==3.0.2
      - urllib3==1.21.1
      - waitress==1.0.2
    - upgrade: True
    - bin_env: /home/servo/homu/_venv
    - require:
      - virtualenv: homu
  {% if grains.get('virtual_subtype', '') != 'Docker' %}
  service.running:
    - enable: True
    - require:
      - pip: homu
    - watch:
      - file: /home/servo/homu/cfg.toml
      - file: /etc/init/homu.conf
  {% endif %}

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
        secrets: {{ pillar['homu'] }}

/etc/init/homu.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/homu.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pip: homu
      - file: /home/servo/homu/cfg.toml
