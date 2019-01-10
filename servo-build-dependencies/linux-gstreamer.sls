{% from 'common/map.jinja' import common %}

include:
  - common

libs-gstreamer:
  archive.extracted:
    - name: {{ common.servo_home }}
    - source: https://servo-deps.s3.amazonaws.com/gstreamer/gstreamer-1.14.3-20190109-1740.tar.gz
    - source_hash: sha512=9ea1c8cee819482ed19ddf51750e86deb7a6596f4c9acd31307dbcfe8b5e6ae6d708719fe74aa07487f84ad1cd82a120f0fd6d4ad318ee73a7868fc50eeb22cf
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

gstreamer-rebuild-registry:
  cmd.run:
    - name: touch lib/x86_64-linux-gnu/gstreamer-1.0/libgstlibav.so
    - runas: servo
    - cwd: {{ common.servo_home }}/gstreamer
    - require:
      - file: {{ common.servo_home }}/gstreamer
