{% from 'common/map.jinja' import root %}
{% from tpldir ~ '/map.jinja' import admin %}

admin-packages:
  pkg.installed:
    - pkgs:
      - tmux
      {% if grains['os'] != 'MacOS' %}
      - mosh
      - screen # Installed by default on OS X
      {% else %}
      - mobile-shell
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

{% for ssh_user in admin.ssh_users %}
sshkey-{{ ssh_user }}:
  ssh_auth.present:
    - user: root
    - source: salt://{{ tpldir }}/files/ssh/{{ ssh_user }}.pub
{% endfor %}
