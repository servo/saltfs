{% from tpldir ~ '/map.jinja' import homu %}

python3:
  pkg.installed:
    - pkgs:
      - python3

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
      - toml == 0.9.1  # Please ensure this is in sync with requirements.txt
    - bin_env: /home/servo/homu/_venv
    - require:
      - virtualenv: homu
  service.running:
    - enable: True
    - require:
      - pip: homu
    - watch:
      - file: /home/servo/homu/cfg.toml
      - file: /etc/init/homu.conf

/home/servo/homu/cfg.toml:
  file.managed:
    - source: salt://{{ tpldir }}/files/cfg.toml
    - template: jinja
    - user: servo
    - group: servo
    - mode: 644

/etc/init/homu.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/homu.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pip: homu
      - file: /home/servo/homu/cfg.toml
