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
  pkg.installed:
    - pkgs:
      - patchutils
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
    - watch:
      - file: /home/wpt-sync/upstream-wpt-sync-webhook/config.json
      - file: /etc/init/wpt-webhook.conf
      - pip: upstream-wpt-webhook
  {% endif %}

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
