/home/servo/.s3cfg:
  file.managed:
    - source: salt://{{ tpldir }}/files/s3cfg
    - user: servo
    - group: servo
    - mode: 644


s3cmd:
  pip.installed:
    - pkgs:
      - s3cmd
    - require:
      - pkg: pip
