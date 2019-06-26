{% from 'common/map.jinja' import root %}
{% from tpldir ~ '/map.jinja' import admin %}

admin-packages:
  pkg.installed:
    - pkgs:
      - tmux
      - mosh

{% if grains.get('virtual_subtype', '') != 'Docker' %}
UTC:
    timezone.system
{% endif %}

/etc/hosts:
  file.managed:
    - user: {{ root.user }}
    - group: {{ root.group }}
    - mode: 644
    - source: salt://{{ tpldir }}/files/hosts

sshkeys-dir:
  file.directory:
    - name: {{ root.home }}/.ssh
    - user: {{ root.user }}
    - group: {{ root.group }}
    - mode: 700

sshkeys:
  file.managed:
    - name: {{ root.home }}/.ssh/authorized_keys
    - user: {{ root.user }}
    - group: {{ root.group }}
    - mode: 600
    - contents:
      {% for ssh_user in admin.ssh_users %}
      - {% include tpldir ~ '/files/ssh/' ~ ssh_user ~ '.pub' %}
      {% endfor %}
    - require:
      - file: sshkeys-dir
