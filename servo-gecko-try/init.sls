{% from tpldir ~ '/map.jinja' import servo-gecko-try %}

user-acct:
  user.present:
    - name: servo-gecko-try
    - fullname: Gecko T. Robot
    - shell: /bin/bash
    - home: /home/servo-gecko-try/

packages:
  pkg.installed:
    - names:
      - mercurial
      - pthon-dev
      - python-virtualenv

servo-gecko-try:
  virtualenv.managed:
    - name: /home/servo-gecko-try/servo-gecko-try/_venv
    - system_site_packages: False
  pip.installed:
    - pkgs:
      - git+https://github.com/Manishearth/servo-gecko-try.git
    - bin_env: /home/servo-gecko-try/servo-gecko-try/_venv
    - upgrade: True
    - require:
      - virtualenv: servo-gecko-try
  service.running:
    - enable: True
    - name: servo-gecko-try
    - require:
      - pip: servo-gecko-try
    - watch:
      - file: /home/servo-gecko-try/servo-gecko-try/config.json
      - file: /etc/init/servo-gecko-try.conf
  {% endif %}

/home/servo-gecko-try/servo-gecko-try/config.json:
  file.managed:
    - source: salt://{{ tlpdir }}/files/config.json
    - user: servo-gecko-try
    - group: servo-gecko-try
    - mode: 644
    - template: jinja
    - context:
        servo-clone: {{ servo-gecko-try.servo-clone}}
        m-c-clone: {{ servo-gecko-try.m-c }}
        autoland-clone: {{ servo-gecko-try.autoland }}

/etc/init/servo-gecko-try.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/servo-gecko-try.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pip: servo-gecko-try
      - file: /home/servo-gecko-try/servo-gecko-try/config.json

https://github.com/servo/servo/:
  git.latest:
    - target: {{ servo-gecko-try.servo-clone }}
    - user: servo-gecko-try

https://hg.mozilla.org/mozilla-central/:
  hg.latest:
    - target: {{ servo-gecko-try.m-c }}
    - user: servo-gecko-try

https://hg.mozilla.org/integration/autoland/:
  hg.latest:
    - target: {{ servo-gecko-try.autoland }}
    - user: servo-gecko-try

http://hg.mozilla.org/hgcustom/version-control-tools/:
  hg.latest:
    - target: {{ servo-gecko-try.vct }}
    - user: servo-gecko-try

/home/servo-gecko-try/.ssh/id_rsa.pub:
   file.managed:
    - user: servo-gecko-try
    - group: servo-gecko-try
    - contents_pillar: servo-gecko-try:servo:id_rsa.pub

/home/servo-gecko-try/.ssh/id_rsa:
  file.managed:
    - user: servo-gecko-try
    - group: servo-gecko-try
    - mode: 600
    - contents_pillar: servo-gecko-try:servo:id_rsa
