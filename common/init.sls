{% from tpldir ~ '/map.jinja' import config with context %}

python2:
  pkg.installed:
    - pkgs:
      - python

{% if grains['os'] == 'Ubuntu' %}
python2-dev:
  pkg.installed:
    - pkgs:
      - python-dev
{% endif %}

pip:
  pkg.installed:
    - pkgs:
      {% if grains['os'] == 'Ubuntu' %}
      - python-pip
      {% elif grains['os'] == 'MacOS' %}
      - python # pip is included with python in homebrew
      {% endif %}
    - reload_modules: True

# Virtualenv package creates virtualenv and virtualenv-3.4 executables
virtualenv:
  pip.installed:
    - pkgs:
      - virtualenv
    - require:
      - pkg: pip

servo:
  user.present:
    - fullname: Tom Servo
    - shell: /bin/bash
    - home: {{ config.servo_home }}

{% for hostname, ip in config.hosts.items() %}
host-{{ hostname }}:
  host.present:
    - name: {{ hostname }}
    - ip: {{ ip }}
{% endfor %}

{% for ssh_user in config.ssh_users %}
sshkey-{{ ssh_user }}:
  ssh_auth.present:
    - user: root
    - source: salt://{{ tpldir }}/ssh/{{ ssh_user }}.pub
{% endfor %}
