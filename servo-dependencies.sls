{% if grains['kernel'] != 'Darwin' %}
FIX enable multiverse:
  pkgrepo.absent:
    - name: deb http://archive.ubuntu.com/ubuntu trusty multiverse

enable multiverse:
  pkgrepo.managed:
    - name: deb http://archive.ubuntu.com/ubuntu trusty multiverse

ttf-mscorefonts-installer:
  debconf.set:
    - name: ttf-mscorefonts-installer
    - data: { 'msttcorefonts/accepted-mscorefonts-eula': { 'type': 'boolean', 'value': True } }
  pkg.installed:
    - pkgs:
      - ttf-mscorefonts-installer
    - requires:
      - debconf: ttf-mscorefonts-installer
{% endif %}

{% if grains['kernel'] == 'Darwin' %}
# Workaround for https://github.com/saltstack/salt/issues/26414
servo-darwin-homebrew-versions-dependencies:
  module.run:
    - name: pkg.install
    - pkgs:
      - automake
      - autoconf213
    - taps:
      - homebrew/versions
    - require_in:
      - pkg: servo-dependencies

homebrew-link-autoconf:
  cmd.run:
    - name: 'brew link --overwrite autoconf'
    - user: administrator
      # Warning: Only checks that some autoconf Homebrew package is linked,
      # not necessarily the version installed above.
      # Whether this handles updating autoconf properly is an open question.
      # This state should be replaced by a custom Salt state.
    - creates: /usr/local/Library/LinkedKegs/autoconf
    - require:
      - module: servo-darwin-homebrew-versions-dependencies
    - require_in:
      - pkg: servo-dependencies
{% endif %}

servo-dependencies:
  pkg.installed:
    - pkgs:
      - cmake
      - git
      - ccache
      {% if grains['kernel'] == 'Darwin' %}
      - pkg-config
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
      {% endif %}
  pip.installed:
    - pkgs:
      - virtualenv
      - ghp-import
