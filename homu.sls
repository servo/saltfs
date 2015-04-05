https://github.com/barosl/homu:
  git.latest:
    - rev: 6796bb1fd14fa87dbafcd2b0e467a6c950f53aa9
    - target: /home/servo/homu
    - user: servo

/home/servo/homu/cfg.toml:
  file.managed:
    - source: salt://homu/cfg.toml
    - template: jinja
    - user: servo
    - group: servo
    - mode: 644

# TODO: add rules to launch the service

