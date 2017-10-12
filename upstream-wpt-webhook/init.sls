{% from tpldir ~ '/map.jinja' import webhook %}

include:
  - python

upstream-wpt-webhook:
  virtualenv.managed:
    - name: /home/servo/upstream-wpt-sync-webhook/_venv
    - venv_bin: virtualenv-3.5
    - python: python3
    - system_site_packages: False
    - require:
      - pkg: python3
      - pip: virtualenv
  pip.installed:
    - pkgs:
      - git+https://github.com/servo-automation/upstream-wpt-sync-webhook@{{ webhook.rev }}
    - bin_env: /home/servo/upstream-wpt-sync-webhook/_venv
    - require:
      - virtualenv: upstream-wpt-webhook
  {% if grains.get('virtual_subtype', '') != 'Docker' %}
  service.running:
    - enable: True
    - name: upstream-wpt-sync
    - require:
      - pip: upstream-wpt-webhook
      - file: /srv/web-platform-tests
    - watch:
      - file: /home/servo/upstream-wpt-sync-webhook/config.json
      - file: /etc/init/wpt-webhook.conf
  {% endif %}

web-platform-tests:
  file.exists:
    - name: /srv/web-platform-tests

/home/servo/upstream-wpt-sync-webhook/config.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/config.json
    - template: jinja
    - user: servo
    - group: servo
    - mode: 644

/etc/init/wpt-webhook.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/wpt-webhook.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pip: upstream-wpt-webhook
      - file: /home/servo/upstream-wpt-sync-webhook/config.json
