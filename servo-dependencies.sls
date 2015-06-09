cmake:
  pkg.installed

git:
  pkg.installed

virtualenv:
  pip.installed

ghp-import:
  pip.installed

{% if grains["kernel"] != "Darwin" %}
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
