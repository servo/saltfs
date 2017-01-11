{% from tpldir ~ '/map.jinja' import common %}

python2:
  pkg.installed:
    - pkgs:
      - python
    {% if grains['os'] == 'MacOS' %}
    - refresh: True
    {% endif %}

python3:
  pkg.installed:
    - pkgs:
      - python3

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

# virtualenv == 14.0.6 package creates virtualenv and virtualenv-3.5 executables
# note that the version of the second may change between virtualenv versions
virtualenv:
  pip.installed:
    - pkgs:
      - virtualenv == 14.0.6
    - require:
      - pkg: pip

servo:
  user.present:
    - fullname: Tom Servo
    - shell: /bin/bash
    - home: {{ common.servo_home }}

{% if grains['os'] != 'MacOS' %}
UTC:
    timezone.system
{% endif %}

{% for hostname, ip in common.hosts.items() %}
host-{{ hostname }}:
  host.present:
    - name: {{ hostname }}
    - ip: {{ ip }}
{% endfor %}

{% for ssh_user in common.ssh_users %}
{{ ssh_user }}:
  user.present:
    - createhome: True
    - optional_groups:
        - wheel
    - empty_password: True

sshkey-{{ ssh_user }}:
  ssh_auth.present:
    - user: {{ ssh_user }}
    - source: salt://{{ tpldir }}/ssh/{{ ssh_user }}.pub
{% endfor %}
