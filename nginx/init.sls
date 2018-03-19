nginx:
  pkg.installed: []
  {% if grains.get('virtual_subtype', '') != 'Docker' %}
  service.running:
    - enable: True
    - watch:
      - pkg: nginx
      - file: /etc/nginx/sites-available/default
    - require:
      - cmd: create-cert
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

/root/renew.sh:
  file.managed:
    - source: salt://nginx/renew.sh
    - template: jinja
    - user: root
    - group: root
    - mode: 644

bash /root/renew.sh:
  cron.present:
    - identifier: build-cert-renew
    - user: root
    - minute: 40
    - hour: 2
    - dayweek: 1
    - require:
      - pkg: certbot
      - file: /root/renew.sh

create-cert:
  cmd.run:
    - name: |
        mkdir -p /etc/letsencrypt/live/build.servo.org &&
        openssl req -x509 -newkey rsa:4096 -new -nodes -days 365 \
        -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=build.servo.org" \
        -keyout /etc/letsencrypt/live/build.servo.org/privkey.pem \
        -out /etc/letsencrypt/live/build.servo.org/fullchain.pem
    - user: root
    - creates: /etc/letsencrypt/live/build.servo.org/fullchain.pem