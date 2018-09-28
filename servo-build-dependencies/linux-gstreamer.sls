{% from 'common/map.jinja' import common %}

include:
  - common

libs-gstreamer:
  archive.extracted:
    - name: {{ common.servo_home }}
    - source: http://servo-deps.s3.amazonaws.com/gstreamer/gstreamer-x86_64-linux-gnu.tar.gz
    - source_hash: sha512=4ca1be625985615e44d92fd6d84b2bfb7d1f492beb335ea7d04686e88c0326143b5dd1514907d356b9f57223035988407153ee295fca30c55b15f4196176097a
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
