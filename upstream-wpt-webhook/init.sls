{% from tpldir ~ '/map.jinja' import webhook %}

include:
  - python

upstream-wpt-webhook:
  group.present:
    - members:
      - wpt-sync
    - require:
      - user: wpt-sync
  user.present:
    - name: wpt-sync
    - fullname: WPT Sync Webhook
    - shell: /bin/bash
    - home: /home/wpt-sync
  virtualenv.managed:
    - name: /home/wpt-sync/upstream-wpt-sync-webhook/_venv
    - venv_bin: virtualenv-3.5
    - python: python3
    - user: wpt-sync
    - system_site_packages: False
    - require:
      - pkg: python3
      - pip: virtualenv
  pip.installed:
    - pkgs:
      - git+https://github.com/servo-automation/upstream-wpt-sync-webhook@{{ webhook.rev }}
    - bin_env: /home/wpt-sync/upstream-wpt-sync-webhook/_venv
    - upgrade: True
    - require:
      - virtualenv: upstream-wpt-webhook
  {% if grains.get('virtual_subtype', '') != 'Docker' %}
  service.running:
    - enable: True
    - name: wpt-webhook
    - require:
      - pip: upstream-wpt-webhook
      - git: web-platform-tests
    - watch:
      - file: /home/wpt-sync/upstream-wpt-sync-webhook/config.json
      - file: /etc/init/wpt-webhook.conf
      - pip: upstream-wpt-webhook
  {% endif %}

web-platform-tests:
  git.latest:
    - user: wpt-sync
    - branch: master
    - depth: 1
    - target: /home/wpt-sync/upstream-wpt-sync-webhook/web-platform-tests
    - name: https://github.com/w3c/web-platform-tests.git

/home/wpt-sync/upstream-wpt-sync-webhook/config.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/config.json
    - template: jinja
    - user: wpt-sync
    - group: wpt-sync
    - mode: 644

/etc/init/wpt-webhook.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/wpt-webhook.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pip: upstream-wpt-webhook
      - file: /home/wpt-sync/upstream-wpt-sync-webhook/config.json
