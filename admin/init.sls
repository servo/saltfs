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

/etc/sshd_config:
  file.managed:
    - user: root
    {% if grains['os'] == 'MacOS' %}
    - group: wheel
    {% elif grains['os'] == 'Ubuntu' %}
    - group: root
    {% endif %}
    - mode: 644
    - source: salt://{{ tpldir }}/files/sshd_config

wheel:
    group.present

{% for ssh_user in admin.ssh_users %}
{{ ssh_user }}:
    group.present:
        - members:
            - {{ ssh_user }}
    user.present:
        - empty_password: True
        - gid_from_name: True
        - groups:
            - wheel
        - require:
            - group:
                - wheel
                - {{ ssh_user }}
    ssh_auth.present:
        - user: {{ ssh_user }}
        - source: salt://{{ tpldir }}/files/ssh/{{ ssh_user }}.pub
        - require:
            - user: {{ ssh_user }}
{% endfor %}
