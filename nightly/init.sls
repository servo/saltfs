/home/servo/.s3cfg-servo:
  file.managed:
    - source: salt://{{ tpldir }}/files/s3cfg-servo
    - user: servo
    - group: servo
    - mode: 644

/home/servo/.s3cfg:
  file.managed:
    - source: salt://{{ tpldir }}/files/s3cfg-rust
    - user: servo
    - group: servo
    - mode: 644


s3cmd:
  pip.installed:
    - pkgs:
      - s3cmd
    - require:
      - pkg: pip
