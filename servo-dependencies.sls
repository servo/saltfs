{% if grains['kernel'] != 'Darwin' %}
FIX enable multiverse:
  pkgrepo.absent:
    - name: deb http://archive.ubuntu.com/ubuntu trusty multiverse

enable multiverse:
  pkgrepo.managed:
    - name: deb http://archive.ubuntu.com/ubuntu trusty multiverse

agree to eula:
  cmd.run:
    - name: echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
{% endif %}

servo-dependencies:
  pkg.installed:
    - pkgs:
      - cmake
      - git
      {% if grains['kernel'] == 'Darwin' %}
      - pkg-config
      - homebrew/versions/autoconf213
      {% else %}
      - libglib2.0-dev
      - libgl1-mesa-dri
      - freeglut3-dev
      - libfreetype6-dev
      - xorg-dev
      - libssl-dev
      - libbz2-dev
      - ttf-mscorefonts-installer
      - xserver-xorg-input-void
      - xserver-xorg-video-dummy
      - xpra
      - libosmesa6-dev
      - gperf
      - autoconf2.13
      {% endif %}
  pip.installed:
    - pkgs:
      - virtualenv
      - ghp-import
