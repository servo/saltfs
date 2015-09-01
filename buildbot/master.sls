{% from 'common/map.jinja' import common %}

buildbot-master:
  pip.installed:
    - pkgs:
      - buildbot == 0.8.12
      - service_identity == 14.0.0
      - txgithub == 15.0.0
      - boto == 2.38.0
    - require:
      - pkg: pip
  service.running:
    - enable: True
    - watch:
      - pip: buildbot-master
      - file: /home/servo/buildbot/master
      - file: /etc/init/buildbot-master.conf

/home/servo/buildbot/master:
  file.recurse:
    - source: salt://buildbot/master
    - user: servo
    - group: servo
    - dir_mode: 755
    - file_mode: 644
    - template: jinja
    - context:
        common: {{ common }}

/etc/init/buildbot-master.conf:
  file.managed:
    - source: salt://buildbot/buildbot-master.conf
    - user: root
    - group: root
    - mode: 644

/usr/local/bin/github_buildbot.py:
  file.managed:
    - source: salt://buildbot/github_buildbot.py
    - user: root
    - group: root
    - mode: 755

/etc/init/buildbot-github-listener.conf:
  file.managed:
    - source: salt://buildbot/buildbot-github-listener.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644

buildbot-github-listener:
  service.running:
    - enable: True
    - watch:
      - file: /usr/local/bin/github_buildbot.py
      - file: /etc/init/buildbot-github-listener.conf

remove-old-build-logs:
  cron.present:
    - name: 'find /home/servo/buildbot/master/*/*.bz2 -mtime +5 -delete'
    - user: root
    - minute: 1
    - hour: 0

iptables:
  service.running:
    - enable: True
    - reload: True

# Open TCP ports for nginx, Homu, Buildbot, ssh
{% for port in '54856','9001','9010','ssh' %}
iptables-open-port-{{ port }}:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - dport: ssh
    - proto: tcp
    - save: True
{% endfor %}

# Enable SSH IPv6 connections
iptables-enable-ipv6:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - dport: ssh
    - proto: tcp
    - save: True
    - family: ipv6

# Open ports for ntp
{% for family in 'ipv4','ipv6' %}
iptables-enable-ntp-{{ family }}:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - dport: ntp
    - proto: udp
    - save: True
    - family: {{ family }}
{% endfor %}

# Open the ports Salt needs, but only to the minions.
# Minion IPs should probably come from Pillar? Spelling out the list here
# doesn't seem like the right way.
{% for minion in '208.52.161.130',
                 '208.52.161.128',
                 '63.135.170.19',
                 '52.88.241.130',
                 '52.11.58.66',
                 '52.36.147.44',
                 '52.37.172.87',
                 '96.126.114.185' %}
{%  for port in '4504','4506' %}
iptables-salt-ports-{{minion}}-{{port}}:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - dport: {{ port }}
    - source: {{ minion }}
    - proto: tcp
    - save: True
{% endfor %}
{% endfor %}

# Reject everything else.
iptables-reject:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: DROP
