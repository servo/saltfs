nginx:
  pkg.installed: []
  service.running:
    - enable: True
    - watch:
      - pkg: nginx

/etc/nginx/sites-available/default:
  file.managed:
    - source: salt://nginx/default
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: nginx

/etc/nginx/conf.d/https_headers.conf:
  file.managed:
    - source: salt://nginx/https_headers.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: nginx

/etc/nginx/sites-enabled/default:
  file.symlink:
    - target: /etc/nginx/sites-available/default

