{% from tpldir ~ '/map.jinja' import config with context %}

{% if grains['kernel'] != 'Darwin' %}
# Ubuntu has python2 as default python
python2:
  pkg.installed:
    - pkgs:
      - python
      - python-dev

python3:
  pkg.installed:
    - pkgs:
      - python3

# Ensure pip is default by purging pip3
pip:
  pkg.installed:
    - pkgs:
      - python-pip
    - reload_modules: True

pip3:
  pkg.purged:
    - pkgs:
      - python3-pip

# Virtualenv package creates virtualenv and virtualenv-3.4 executables
virtualenv:
  pip.installed:
    - pkgs:
      - virtualenv
    - require:
      - pkg: pip
      - pkg: pip3
{% endif %}

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
