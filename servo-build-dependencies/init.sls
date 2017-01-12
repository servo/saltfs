include:
  - python

servo-dependencies:
  pkg.installed:
    - pkgs:
      - cmake
      - git
      - ccache
      {% if grains['kernel'] == 'Darwin' %}
      - autoconf@2.13
      - automake
      - pkg-config
      - openssl
      - freetype
      - ffmpeg
      - yasm
      {% else %}
      - libglib2.0-dev
      - libgl1-mesa-dri
      - libgles2-mesa-dev
      - freeglut3-dev
      - libfreetype6-dev
      - xorg-dev
      - libssl-dev
      - libbz2-dev
      - xserver-xorg-input-void
      - xserver-xorg-video-dummy
      - xpra
      - libosmesa6-dev
      - gperf
      - autoconf2.13
      - libdbus-glib-1-dev
      - libavformat-dev
      - libavcodec-dev
      - libavutil-dev
      {% endif %}
  pip.installed:
    - pkgs:
      - ghp-import
      - s3cmd
    - require:
      - pkg: pip
      - pip: virtualenv

{% if grains['os'] == 'Ubuntu' %}
multiverse:
  pkgrepo.managed:
    - name: 'deb http://archive.ubuntu.com/ubuntu trusty multiverse'
    - file: /etc/apt/sources.list.d/multiverse.list
    - require_in:
      - pkg: ttf-mscorefonts-installer

/etc/apt/sources.list.d/multiverse.list:
  file.exists:
    - require:
      - pkgrepo: multiverse
    {% if salt['pillar.get']('fully_managed', True) %}
    - require_in:
      - file: /etc/apt/sources.list.d
    {% endif %}

ttf-mscorefonts-installer:
  debconf.set:
    - data: { 'msttcorefonts/accepted-mscorefonts-eula': { 'type': 'boolean', 'value': True } }
  pkg.installed:
    - pkgs:
      - ttf-mscorefonts-installer
    - require:
      - debconf: ttf-mscorefonts-installer
{% endif %}
