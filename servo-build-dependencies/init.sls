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
servo-darwin-homebrew-versions-dependencies:
  module.run:
    - name: pkg.install
    - pkgs:
      - autoconf213
    - taps:
      - homebrew/versions

# Warning: These states that manually run brew link only check that some
# version of the Homebrew package is linked, not necessarily the version
# linked above. Whether this handles updates properly is an open question.
# These should be replaced by a custom Salt state.
homebrew-link-autoconf:
  cmd.run:
    - name: 'brew link --overwrite autoconf'
    - runas: {{ homebrew.user }}
    - creates: /usr/local/Library/LinkedKegs/autoconf
    - require:
      - pkg: servo-dependencies
      - module: servo-darwin-homebrew-versions-dependencies

homebrew-link-openssl:
  cmd.run:
    - name: 'brew link --force openssl'
    - runas: {{ homebrew.user }}
    - creates: /usr/local/Library/LinkedKegs/openssl
    - require:
      - pkg: servo-dependencies
{% else %}
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
    - require_in:
      - file: /etc/apt/sources.list.d

ttf-mscorefonts-installer:
  debconf.set:
    - data: { 'msttcorefonts/accepted-mscorefonts-eula': { 'type': 'boolean', 'value': True } }
  pkg.installed:
    - pkgs:
      - ttf-mscorefonts-installer
    - require:
      - debconf: ttf-mscorefonts-installer
{% endif %}
