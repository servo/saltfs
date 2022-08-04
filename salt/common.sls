{% from tpldir ~ '/map.jinja' import salt %}

{% if grains['os'] == 'Ubuntu' %}
salt:
  pkgrepo.managed:
    - name: 'deb http://repo.saltproject.io/py3/ubuntu/{{ grains['osrelease'] }}/amd64/archive/{{ salt.version }} {{ grains['oscodename'] }} main'
    - file: /etc/apt/sources.list.d/saltstack.list
    - key_url: https://repo.saltproject.io/py3/ubuntu/{{ grains['osrelease'] }}/amd64/archive/{{ salt.version }}/SALTSTACK-GPG-KEY.pub

no-old-salt:
  pkgrepo.absent:
    - name: 'deb http://repo.saltstack.com/apt/ubuntu/18.04/amd64/archive/3001.8 bionic main'
    - file: /etc/apt/sources.list.d/saltstack.list

/etc/apt/sources.list.d/saltstack.list:
  file.exists:
    - require:
      - pkgrepo: salt
    - require_in:
      - file: /etc/apt/sources.list.d
{% endif %}
