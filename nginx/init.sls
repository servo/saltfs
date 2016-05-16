{% from tpldir ~ '/map.jinja' import nginx %}

# Fix conflicts if Nginx from Ubuntu is previously installed
nginx-distro-pkgs:
  pkg.purged:
    - pkgs:
       - nginx-common
       - nginx-core

nginx:
  pkgrepo.managed:
    - name: 'deb http://nginx.org/packages/ubuntu/ trusty nginx'
    - file: /etc/apt/sources.list.d/nginx.list
      # Available online but not via HTTPS, so serve locally instead
    - key_url: salt://{{ tpldir }}/files/nginx_signing.key
  pkg.installed:
    - name: {{ nginx.pkg }}
    - version: {{ nginx.version }}
    - require:
      - pkg: nginx-distro-pkgs
      - pkgrepo: nginx
  service.running:
    - enable: True
    - watch:
      - pkg: nginx
      - file: /etc/nginx/sites-enabled/default
      - file: /etc/nginx/conf.d
      - file: /etc/nginx/nginx.conf

/etc/apt/sources.list.d/nginx.list:
  file.exists:
    - require:
      - pkgrepo: nginx
    - require_in:
      - file: /etc/apt/sources.list.d

/etc/nginx/sites-available/default:
  file.managed:
    - source: salt://{{ tpldir }}/files/default
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - require:
      - pkg: nginx

/etc/nginx/sites-enabled/default:
  file.symlink:
    - target: /etc/nginx/sites-available/default
    - makedirs: True
    - require:
      - file: /etc/nginx/sites-available/default
      - pkg: nginx

/etc/nginx/conf.d:
  file.directory:
    - user: root
    - group: root
    - clean: True
    - file_mode: 644
    - dir_mode: 755
    - require:
      - pkg: nginx

/etc/nginx/nginx.conf:
  file.managed:
    - user: root
    - group: root
    - source: salt://{{ tpldir }}/files/nginx.conf
    - template: jinja
    - context:
        nginx: {{ nginx }}
    - require:
        - pkg: nginx
