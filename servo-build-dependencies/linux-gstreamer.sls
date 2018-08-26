{% from 'common/map.jinja' import common %}

include:
  - common

libs-gstreamer:
  archive.extracted:
    - name: {{ common.servo_home }}
    - source: https://github.com/ferjm/gstreamer-1.14.1-ubuntu-trusty/raw/master/gstreamer.tar.gz
    - source_hash: sha512=59f76df0a773802d6158958e796977cfd78f0c5088b10d51ea01e9d6a9f18d94e06a9bda4b1b4c320f8a38226ec6a54651cc552dbf96eb7f7a8b1e1472f55b2f
    - archive_format: tar
    - user: servo
    - group: servo
    - ensure_ownership_on: {{ common.servo_home }}/gstreamer


{{ common.servo_home }}/gstreamer:
  file.directory:
    - user: servo
    - group: servo
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
    - require:
      - archive: libs-gstreamer

gstreamer-pc:
  cmd.run:
    - name: sed -i "s;prefix=/root/gstreamer;prefix=$PWD;g" $PWD/lib/x86_64-linux-gnu/pkgconfig/*.pc
    - runas: servo
    - cwd: {{ common.servo_home }}/gstreamer
    - require:
      - file: {{ common.servo_home }}/gstreamer
