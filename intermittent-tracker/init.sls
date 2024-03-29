{% from 'common/map.jinja' import common %}
{% from tpldir ~ '/map.jinja' import tracker %}

include:
  - common
  - python

tracker-debugging-packages:
  pip.installed:
    - pkgs:
      - github3.py == 1.0.0a4

# by convention, setup.py is for direct loose dependencies, and requirements.txt
# is for transitive exact dependencies, because only end users should get to pin
# package versions, not their dependencies.
#
# but to make deployment repeatable, we want to install our application with
# setup.py *and* install its dependencies with requirements.txt.
#
# unfortunately putting both pkgs and requirements in pip.installed does *not*
# do the equivalent of pip install git+https://... -r requirements.txt (which
# would do what we want) but rather just pip install -r requirements.txt,
# ignoring the pkgs, so we need to break the install into two parts.

intermittent-tracker-deps:
  # use virtualenv rather than venv to ensure pip is up to date
  # (fixes ModuleNotFoundError for setuptools_rust in cryptography==39.0.1)
  virtualenv.managed:
    - name: /home/servo/intermittent-tracker/_venv
    - venv_bin: virtualenv
    - python: python3.7
    - system_site_packages: False
    - require:
      - pkg: python3
      - pip: virtualenv
  pip.installed:
    - requirements:
      - /home/servo/intermittent-tracker/requirements.txt
    - bin_env: /home/servo/intermittent-tracker/_venv
    - force_reinstall: True  # upgrade: True doesn’t work for git+@ packages
    - require:
      - virtualenv: intermittent-tracker
      - file: /home/servo/intermittent-tracker/requirements.txt

intermittent-tracker:
  virtualenv.managed:
    - name: /home/servo/intermittent-tracker/_venv
    - venv_bin: virtualenv
    - python: python3.7
    - system_site_packages: False
    - require:
      - pkg: python3
      - pip: virtualenv
  pip.installed:
    - pkgs:
      - git+https://github.com/servo/intermittent-tracker@{{ tracker.rev }}
    - bin_env: /home/servo/intermittent-tracker/_venv
    - force_reinstall: True  # upgrade: True doesn’t work for git+@ packages
    - require:
      - virtualenv: intermittent-tracker-deps
      - file: /home/servo/intermittent-tracker/requirements.txt
  service.running:
    - enable: True
    - name: tracker
    - require:
      - pip: intermittent-tracker
    - watch:
      - file: /home/servo/intermittent-tracker/config.json
      - file: /lib/systemd/system/tracker.service
      - pip: intermittent-tracker

/home/servo/intermittent-tracker/requirements.txt:
  file.managed:
    - source: https://github.com/servo/intermittent-tracker/raw/{{ tracker.rev }}/requirements.txt
    - skip_verify: True  # ok because source is content-addressed and https
    - user: root
    - group: root
    - mode: 644

/home/servo/intermittent-tracker/config.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/config.json
    - template: jinja
    - user: servo
    - group: servo
    - mode: 644

/lib/systemd/system/tracker.service:
  file.managed:
    - source: salt://{{ tpldir }}/files/tracker.service
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        common: {{ common }}
    - require:
      - pip: intermittent-tracker
      - file: /home/servo/intermittent-tracker/config.json
