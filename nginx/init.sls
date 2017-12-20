nginx:
  pkg.installed: []
  {% if grains.get('virtual_subtype', '') != 'Docker' %}
  service.running:
    - enable: True
    - watch:
      - pkg: nginx
      - file: /etc/nginx/sites-available/default
  {% endif %}

/etc/nginx/sites-available/default:
  file.managed:
    - source: salt://nginx/default
    - user: root
    - group: root
    - mode: 644

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

