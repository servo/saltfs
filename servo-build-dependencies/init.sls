{% from 'common/map.jinja' import homebrew %}

servo-dependencies:
  pkg.installed:
    - pkgs:
      - cmake
      - git
      - ccache
      {% if grains['kernel'] == 'Darwin' %}
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

{% if grains['kernel'] == 'Darwin' %}
# Workaround for https://github.com/saltstack/salt/issues/26414
servo-darwin-tap-homebrew-versions:
  cmd.run:
    - name: 'brew tap homebrew/versions'
    - runas: {{ homebrew.user }}
    - unless: 'brew tap | grep homebrew/versions'
    - require:
      - pkg: servo-dependencies

# This should be replaced by a custom Salt state.
servo-darwin-install-autoconf213-and-fix-links:
  cmd.script:
    - source: salt://{{ tpldir }}/files/install-homebrew-autoconf213.sh
    - runas: {{ homebrew.user }}
    - require:
      - pkg: servo-dependencies

ttf-mscorefonts-installer:
  debconf.set:
    - data: { 'msttcorefonts/accepted-mscorefonts-eula': { 'type': 'boolean', 'value': True } }
  pkg.installed:
    - pkgs:
      - ttf-mscorefonts-installer
    - require:
      - debconf: ttf-mscorefonts-installer
{% endif %}
