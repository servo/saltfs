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

{% for ssh_user in admin.ssh_users %}
useraccount-{{ ssh_user }}:
    user.present:
        - name: {{ ssh_user }}
        - empty_password: True
account-sshkey-{{ ssh_user }}:
  ssh_auth.present:
    - user: {{ ssh_user }}
    - source: salt://{{ tpldir }}/files/ssh/{{ ssh_user }}.pub

# FIXME Remove this state to disallow root login.
root-sshkey-{{ ssh_user }}:
  ssh_auth.present:
    - user: root
    - source: salt://{{ tpldir }}/files/ssh/{{ ssh_user }}.pub

# FIXME This is just as bad as all sharing root login.
{% if grains['os'] == 'MacOS' %}
/etc/sudoers:
    file.append:
        - text: {{ ssh_user }} ALL=(ALL) ALL
{% elif grains['os'] == 'Ubuntu' %}
/etc/sudoers:
    file.append:
        - text: {{ ssh_user }} ALL=(ALL:ALL) ALL
{% endif %}
{% endfor %}



