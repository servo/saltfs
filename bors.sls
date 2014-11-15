https://github.com/servo/bors:
  git.latest:
    - rev: ed7e199c7fa4200e270010a5b7b7b42a2d8893e6
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

