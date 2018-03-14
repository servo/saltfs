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

/etc/nginx/sites-enabled/default:
  file.symlink:
    - target: /etc/nginx/sites-available/default

certbot:
  pkgrepo.managed:
    - ppa: certbot/certbot
  pkg.installed:
    - pkgs:
      - certbot
      - python-certbot-nginx

certbot renew:
  cron.present:
    - identifier: build-cert-renew
    - user: root
    - minute: 0
    - hour: 0
    - daymonth: 1
    - require:
      - pkg: certbot
