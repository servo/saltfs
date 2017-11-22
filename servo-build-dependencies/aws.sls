include:
  - python

aws-cli:
  pip.installed:
    - pkgs:
      - awscli
    - require:
      - pkg: pip
      - pip: virtualenv
