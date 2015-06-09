https://github.com/barosl/homu:
  git.latest:
    - rev: 6796bb1fd14fa87dbafcd2b0e467a6c950f53aa9
    - target: /home/servo/homu
    - user: servo
    - require_in:
      - pip: install_homu

/home/servo/homu/cfg.toml:
  file.managed:
    - source: salt://homu/cfg.toml
    - template: jinja
    - user: servo
    - group: servo
    - mode: 644
    - require_in:
      - service: homu
    - watch_in:
      - service: homu

/home/servo/homu/_venv:
  virtualenv.managed:
    - system_site_packages: False
    - require_in:
      - pip: install_homu

install_homu:
  pip.installed:
    - bin_env: /home/servo/homu/_venv
    - editable: /home/servo/homu

homu:
  service:
    - running
    - enable: True
    - require:
      - pip: install_homu

/etc/init/homu.conf:
  file.managed:
    - source: salt://homu/homu.conf
    - user: root
    - group: root
    - mode: 644
    - require_in:
      - service: homu
    - watch_in:
      - service: homu
