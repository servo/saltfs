# Used to keep the Salt tree up to date on the master
git:
  pkg.installed:
    - pkgs:
      - git
