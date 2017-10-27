{% from 'common/map.jinja' import root %}
{% from tpldir ~ '/map.jinja' import admin %}

admin-packages:
  pkg.installed:
    - pkgs:
      - tmux
      - mosh
      {% if grains['os'] != 'MacOS' %}
      - screen # Installed by default on OS X
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

# Admin state is never run on Windows. We care about accounts primarily on
# buildmaster, which is always a Linux.
{% if grains['os'] != 'MacOS' %}
sshusers:
    group.present

/etc/sshd_config:
    file.managed:
        - user: root
        - group: root
        - mode: 644
        - source: salt://{{ tlpdir }}/files/sshd_config
{% for ssh_user in admin.ssh_users %}
{{ ssh_user }}:
    group.present: []
    user.present:
        - empty_password: True
        - gid_from_name: True
        - groups:
            - sshusers
        - require:
            - group: sshusers
            - group: {{ ssh_user }}
    file.managed:
        - name: /home/{{ ssh_user }}/.ssh/authorized_keys
        - user: {{ ssh_user }}
        - group: {{ ssh_user }}
        - mode: 600
        - contents:
            - {% include tpldir ~ '/files/ssh/' ~ ssh_user ~ '.pub' %}
        - require:
            - user: {{ ssh_user }}
{% endfor %}
{% endif %}
