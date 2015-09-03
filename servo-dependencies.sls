cmake:
  pkg.installed

git:
  pkg.installed

virtualenv:
  pip.installed

ghp-import:
  pip.installed

{% if grains["kernel"] != "Darwin" %}
FIX enable multiverse:
  pkgrepo.absent:
    - name: deb http://archive.ubuntu.com/ubuntu trusty multiverse

enable multiverse:
  pkgrepo.managed:
    - name: deb http://archive.ubuntu.com/ubuntu trusty multiverse

agree to eula:
  cmd.run:
    - name: echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

libglib2.0-dev:
  pkg.installed

libgl1-mesa-dri:
  pkg.installed

freeglut3-dev:
  pkg.installed

libfreetype6-dev:
  pkg.installed

xorg-dev:
  pkg.installed

libssl-dev:
  pkg.installed

libbz2-dev:
  pkg.installed

msttcorefonts:
  pkg.installed

xserver-xorg-input-void:
  pkg.installed

xserver-xorg-video-dummy:
  pkg.installed

xpra:
  pkg.installed

libosmesa6-dev:
  pkg.installed

gperf:
  pkg.installed

{% else %}

pkg-config:
  pkg.installed

{% endif %}
