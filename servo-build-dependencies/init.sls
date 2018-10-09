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
   {% if grains['os'] == 'MacOS' %}
    - require:
      - pkg: mac-gstreamer
      - pkg: mac-gst-plugins-base
      - pkg: mac-gst-others
      - pkg: mac-gst-plugins-bad
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
      - wget
      - yasm
      - zlib
      {% elif grains['os'] == 'Ubuntu' %}
      - autoconf2.13
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

{% if grains['os'] == 'MacOS' %}

# When passing options to homebrew, the options will not be passed
# to any dependencies that are built. Thus it is imperative we 
# build the packages in the right order, ensuring that
# no package with options is built as a dependency.
#
# Here, gst-plugins-base and gst-plugins-bad have options, so they have
# their own build formula that is called before anything that depends on them
# is built.

mac-gstreamer:
  pkg.installed:
    - pkgs:
      - gstreamer

mac-gst-plugins-base:
  pkg.installed:
    - require:
      - pkg: mac-gstreamer
    - pkgs:
      - gst-plugins-base
    - options:
      - --with-libogg
      - --with-libvorbis
      - --with-opus
      - --with-theora
      - --with-orc
      - --with-pango

mac-gst-others:
  pkg.installed:
    - require:
      - pkg: mac-gst-plugins-base
    - pkgs:
      - gst-plugins-good
      - gst-libav
      - gst-rtsp-server

mac-gst-plugins-bad:
  pkg.installed:
    - require:
      - pkg: mac-gst-plugins-base
    - pkgs:
      - gst-plugins-bad
    - options:
      - --with-opus

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
    - require:
      - file: /etc/apt/sources.list.d
    - require_in:
      - pkg: ttf-mscorefonts-installer

/etc/apt/sources.list.d/multiverse.list:
  file.exists:
    - require:
      - pkgrepo: multiverse

ttf-mscorefonts-installer:
  debconf.set:
    - data: { 'msttcorefonts/accepted-mscorefonts-eula': { 'type': 'boolean', 'value': True } }
  pkg.installed:
    - pkgs:
      - ttf-mscorefonts-installer
    - require:
      - debconf: ttf-mscorefonts-installer
{% endif %}
