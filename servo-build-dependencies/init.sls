{% from 'common/map.jinja' import common %}

include:
  - python

servo-dependencies:
  cmd.run:
    - name: |
        curl https://sh.rustup.rs -sSf |
        sh -s -- --default-toolchain none -y
    - runas: servo
    - creates:
      - {{ common.servo_home }}/.rustup
      - {{ common.servo_home }}/.cargo/bin/rustup
  pkg.installed:
    {% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: cmake-ppa
      - pkgrepo: gcc-ppa
      - pkgrepo: ffmpeg-ppa
      - pkgrepo: llvm-deb
    {% endif %}
    - pkgs:
      - ccache
      - git
      {% if grains['os'] == 'MacOS' %}
      - autoconf@2.13
      - automake
      - cmake
      - ffmpeg
      - freetype
      - llvm
      - openssl
      - pkg-config
      - yasm
      - zlib
      - gstreamer
      - gst-plugins-base
      - gst-plugins-good
      - libgstreamer1.0-dev
      {% elif grains['os'] == 'Ubuntu' %}
      - autoconf2.13
      - libgstreamer-plugins-base1.0-dev
      - gstreamer1.0-plugins-base
      - gstreamer1.0-libav
      {% if grains['osrelease'] == '14.04' %}
      - cmake: 3.2.2-2~ubuntu14.04.1~ppa1
      {% else %}
      - cmake
      {% endif %}
      - curl
      - dbus-x11
      - freeglut3-dev
      - gcc-5
      - g++-5
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
      - libpulse-dev
      - libssl-dev
      - libswscale-dev
      - libswresample-dev
      - llvm-4.0-dev
      - libclang-4.0-dev
      - clang-4.0
      - xorg-dev
      - xpra
      - xserver-xorg-input-void
      - xserver-xorg-video-dummy
      {% elif grains['os'] in ['CentOS', 'Fedora'] %}
      - bzip2-devel
      - cabextract
      - cmake
      - curl
      - dbus-devel
      - expat-devel
      - fontconfig-devel
      - freeglut-devel
      - freetype-devel
      - gcc-c++
      - glib2-devel
      - gperf
      - libtool
      - libX11-devel
      - libXcursor-devel
      - libXi-devel
      - libXmu-devel
      - libXrandr-devel
      - llvm-devel
      - mesa-libEGL-devel
      - mesa-libGL-devel
      - mesa-libOSMesa-devel
      - openssl-devel
      - rpm-build
      - ttmkfdir
      {% endif %}
  {% if salt['pillar.get']('fully_managed', True) %}
  pip.installed:
    - pkgs:
      - ghp-import
    - require:
      - pkg: pip
      - pip: virtualenv
    {% if grains['os'] == 'MacOS' %}
    - ignore_installed: True
    {% endif %}
  {% endif %}

{% if grains['os'] == 'Ubuntu' %}
cmake-ppa:
  pkg.installed:
    - name: python-software-properties
  pkgrepo.managed:
    - ppa: george-edison55/cmake-3.x
    - require:
      - pkg: python-software-properties

gcc-ppa:
  pkgrepo.managed:
    - ppa: ubuntu-toolchain-r/test

ffmpeg-ppa:
  pkgrepo.managed:
    - ppa: jonathonf/ffmpeg-3

llvm-deb:
  pkgrepo.managed:
    - name: 'deb http://apt.llvm.org/{{ grains['oscodename'] }}/ llvm-toolchain-{{ grains['oscodename'] }}-4.0 main'
    - key_url: https://apt.llvm.org/llvm-snapshot.gpg.key

multiverse:
  pkgrepo.managed:
    - name: 'deb http://archive.ubuntu.com/ubuntu {{ grains['oscodename'] }} multiverse'
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
