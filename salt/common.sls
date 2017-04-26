{% from tpldir ~ '/map.jinja' import salt %}

{% if grains['os'] == 'Ubuntu' %}
salt:
  pkgrepo.managed:
    - name: 'deb http://repo.saltstack.com/apt/ubuntu/{{ grains['osrelease'] }}/amd64/archive/{{ salt.version }} {{ grains['oscodename'] }} main'
    - file: /etc/apt/sources.list.d/saltstack.list
    - key_url: https://repo.saltstack.com/apt/ubuntu/{{ grains['osrelease'] }}/amd64/archive/{{ salt.version }}/SALTSTACK-GPG-KEY.pub

/etc/apt/sources.list.d/saltstack.list:
  file.exists:
    - require:
      - pkgrepo: salt
    - require_in:
      - file: /etc/apt/sources.list.d
{% endif %}
