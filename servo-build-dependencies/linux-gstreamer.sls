{% from 'common/map.jinja' import common %}

include:
  - common

libs-gstreamer:
  archive.extracted:
    - name: {{ common.servo_home }}
    - source: http://servo-deps.s3.amazonaws.com/gstreamer/gstreamer-1.14.4-x86_64-linux-gnu.20190513.tar.gz
    - source_hash: sha512=332c8d03be6a2a2f5d21de03f2f4877f17084b41cecf0a25a4d1fcf736c492ec40ccffe9ff5613b458c0fe207a81d1cc97e93f7efd23480c760ede41984979b9
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
