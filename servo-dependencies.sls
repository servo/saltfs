servo-dependencies:
  pkg.installed:
    - pkgs:
      - cmake
      - git
      {% if grains['kernel'] == 'Darwin' %}
      - pkg-config
      {% else %}
      - libglib2.0-dev
      - libgl1-mesa-dri
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
      {% endif %}

servo-python-dependencies:
  pip.installed:
    - pkgs:
      - virtualenv
      - ghp-import
