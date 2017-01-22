include:
  - python

servo-dependencies:
  pkg.installed:
    - pkgs:
      - ccache
      - cmake
      - git
      {% if grains['os'] == 'MacOS' %}
      - autoconf@2.13
      - automake
      - ffmpeg
      - freetype
      - llvm
      - openssl
      - pkg-config
      - yasm
      {% elif grains['os'] == 'Ubuntu' %}
      - autoconf2.13
      - curl
      - freeglut3-dev
      - gperf
      - libavcodec-dev
      - libavformat-dev
      - libavutil-dev
      - libbz2-dev
      - libdbus-glib-1-dev
      - libfreetype6-dev
      - libgl1-mesa-dri
      - libglib2.0-dev
      - libgles2-mesa-dev
      - libosmesa6-dev
      - libssl-dev
      - llvm-3.5-dev
      - xorg-dev
      - xpra
      - xserver-xorg-input-void
      - xserver-xorg-video-dummy
      {% endif %}
  {% if salt['pillar.get']('fully_managed', True) %}
  pip.installed:
    - pkgs:
      - ghp-import
      - s3cmd
    - require:
      - pkg: pip
      - pip: virtualenv
  {% endif %}

{% if grains['os'] == 'Ubuntu' and grains['oscodename'] == 'trusty' %}
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
