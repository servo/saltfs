buildbot:
  pip.installed:
    - name: buildbot == 0.8.12

txgithub:
  pip.installed

boto:
  pip.installed

buildbot-master:
  service:
    - running
    - enable: True

/home/servo/buildbot/master:
  file.recurse:
    - source: salt://buildbot/master
    - template: jinja
    - user: servo
    - group: servo
    - dir_mode: 755
    - file_mode: 644
    - require_in:
      - service: buildbot-master
    - watch_in:
      - service: buildbot-master

/etc/init/buildbot-master.conf:
  file.managed:
    - source: salt://buildbot/buildbot-master.conf
    - user: root
    - group: root
    - mode: 644
    - require_in:
      - service: buildbot-master
    - watch_in:
      - service: buildbot-master

buildbot-github-listener:
  service:
    - running
    - enable: True
    
/usr/local/bin/github_buildbot.py:
  file.managed:
    - source: salt://buildbot/github_buildbot.py
    - user: root
    - group: root
    - mode: 755
    - reuqire_in:
      - service: buildbot-github-listener
    - watch_in:
      - service: buildbot-github-listener

/etc/init/buildbot-github-listener.conf:
  file.managed:
    - source: salt://buildbot/buildbot-github-listener.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - reuqire_in:
      - service: buildbot-github-listener
    - watch_in:
      - service: buildbot-github-listener

iptables:
  service.running:
    - enable: True
    - reload: True

# Open TCP ports for nginx, Homu, Buildbot, ssh
{% for port in '54856','9001','9010','ssh' %}
iptables:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - dport: ssh
    - proto: tcp
    - save: True
{% endfor %}

# Enable SSH IPv6 connections
iptables:
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
iptables:
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
{% for minion in '208.52.161.130', '208.52.161.128', '63.135.170.19',
    '208.52.170.250', '66.228.48.56', '173.255.201.95', '45.79.167.177',
    '72.14.176.110','96.126.114.185'  %}
{%  for port in '4504','4506' %}
iptables:
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
iptables:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: DROP

iptables:
  iptables.set_policy
    - chain: INPUT
    - policy: DROP
