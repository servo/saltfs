nginx:
  pkg.installed: []
  service.running:
    - enable: True
    - watch:
      - pkg: nginx
      - file: /etc/nginx/sites-available/default

/etc/nginx/sites-available/default:
  file.managed:
    - source: salt://nginx/default
    - user: root
    - group: root
    - mode: 644

/etc/nginx/sites-enabled/default:
  file.symlink:
    - target: /etc/nginx/sites-available/default

