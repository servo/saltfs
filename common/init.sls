{% from tpldir ~ '/map.jinja' import config with context %}

{% if grains['kernel'] != 'Darwin' %}
python-pkgs:
  pkg.installed:
    - pkgs:
      - python-pip
      - python-dev
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
