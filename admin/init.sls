{% from 'common/map.jinja' import root %}
{% from tpldir ~ '/map.jinja' import admin, hostkey %}

admin-packages:
  pkg.installed:
    - pkgs:
      - tmux
      - mosh
      {% if grains['os'] != 'MacOS' %}
      - openssh-server # Use default macOS version, not Homebrew's
      - screen # Installed by default on macOS
      {% endif %}

{% if grains['os'] != 'MacOS' and grains.get('virtual_subtype', '') != 'Docker' %}
UTC:
    timezone.system
{% endif %}

/etc/hosts:
  file.managed:
    - user: {{ root.user }}
    - group: {{ root.group }}
    - mode: 644
    - source: salt://{{ tpldir }}/files/hosts

sshd_config:
  file.managed:
    - name: /etc/ssh/sshd_config
    - user: {{ root.user }}
    - group: {{ root.group }}
    - mode: 644
    - template: jinja
    - source: salt://{{ tpldir }}/files/sshd_config
    - defaults:
        hostkey: "{{ hostkey }}"
  cmd.run:
    - name: ssh-keygen -A
    - runas: {{ root.user }}
    - creates:
      - /etc/ssh/{{ hostkey }}

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

{% if grains['os'] != 'MacOS' %}
sshd:
  service.running:
    - name: ssh
    - enable: True
    - require:
      - file: sshkeys
    - watch:
      - file: sshd_config
{% endif %}
