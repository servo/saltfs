{% from 'common/map.jinja' import common %}

include:
  - common

libs-gstreamer:
  archive.extracted:
    - name: {{ common.servo_home }}
    - source: http://servo-deps.s3.amazonaws.com/gstreamer/gstreamer-1.14-x86_64-linux-gnu.20190213.tar.gz
    - source_hash: sha512=8c6e365003d370c6fbefb0844f3ea74fd758efde6706ce65de86e965b1c3cd1fd22ac9fa544656d4bdb9451702fc4ad635aad3737b92f527170184c4fd6c133a
    - archive_format: tar
    - user: servo
    - group: servo
    - ensure_ownership_on: {{ common.servo_home }}/gst


{{ common.servo_home }}/gst:
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
    - name: sed -i "s;prefix=/opt/gst;prefix=$PWD;g" $PWD/lib/pkgconfig/*.pc
    - runas: servo
    - cwd: {{ common.servo_home }}/gst
    - require:
      - file: {{ common.servo_home }}/gst

gstreamer-rebuild-registry:
  cmd.run:
    - name: touch lib/gstreamer-1.0/libgstlibav.so
    - runas: servo
    - cwd: {{ common.servo_home }}/gst
    - require:
      - file: {{ common.servo_home }}/gst
