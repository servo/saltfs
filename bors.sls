https://github.com/servo/bors:
  git.latest:
    - rev: 4375dcc55c93fe611ea7d2bae40180274cfd978e
    - target: /home/servo/bors
    - user: servo

/home/servo/bors/bors.cfg:
  file.managed:
    - source: salt://bors/bors.cfg
    - template: jinja
    - user: servo
    - group: servo
    - mode: 644
