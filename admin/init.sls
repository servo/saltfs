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

{% if grains['os'] != 'MacOS' %}
UTC:
    timezone.system
{% endif %}

/etc/hosts:
  file.managed:
    - user: root
    {% if grains['os'] == 'MacOS' %}
    - group: wheel
    {% elif grains['os'] == 'Ubuntu' %}
    - group: root
    {% endif %}
    - mode: 644
    - source: salt://{{ tpldir }}/files/hosts

# FIXME we should also explicitly AllowUsers usera userb userc
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


{% for ssh_user in admin.ssh_users %}
{{ ssh_user }}:
    user.present:
        - name: {{ ssh_user }}
        - empty_password: True
        - createhome: True
        - optional_groups:
            - wheel
    ssh_auth.present:
        - user: {{ ssh_user }}
        - source: salt://{{ tpldir }}/files/ssh/{{ ssh_user }}.pub

{% endfor %}

# FIXME This is just as bad as all sharing root login.
/etc/sudoers:
    file.append:
        - text:
            {% for ssh_user in admin.ssh_users %}
            - {{ ssh_user }} ALL=(ALL:ALL) ALL
            {% endfor %}

