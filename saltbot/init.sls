{% from tpldir ~ '/map.jinja' import bot %}

npm:
  pkg.installed:
    - name: nodejs
    - version: 8.9.4-1nodesource1
    - skip_verify: True

saltbot:
  git.latest:
    - branch: master
    - target: /root/saltbot/
    - name: https://github.com/jdm/saltbot.git
    - rev: {{ bot.rev }}
  npm.bootstrap:
    - name: /root/saltbot/
    - require:
      - pkg: npm
      - git: saltbot
  service.running:
    - enable: True
    - name: saltbot
    - require:
      - npm: saltbot
    - watch:
      - file: /etc/init/saltbot.conf
      - git: saltbot

node-ppa:
  pkgrepo.managed:
    - humanname: Node PPA
    - name: deb https://deb.nodesource.com/node_8.x trusty main
    - require_in:
      - pkg: npm

/etc/init/saltbot.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/saltbot.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - git: saltbot