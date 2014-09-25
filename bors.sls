https://github.com/graydon/bors:
  git.latest:
    - rev: master
    - target: /home/servo/bors
    - user: servo

/home/servo/bors/bors.cfg:
  file.managed:
    - source: salt://bors/bors.cfg
    - template: jinja
    - user: servo
    - group: servo
    - mode: 644

cd /home/servo/bors && python bors.py:
  cron.present:
    - user: servo
    - minute: '*/3'

