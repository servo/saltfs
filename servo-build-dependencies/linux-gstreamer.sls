{% from 'common/map.jinja' import common %}

include:
  - common

libs-gstreamer:
  archive.extracted:
    - name: {{ common.servo_home }}
    - source: https://servo-deps.s3.amazonaws.com/gstreamer/gstreamer-1.16-x86_64-linux-gnu.20190515.tar.gz
    - source_hash: sha512=1a003f8fdf8fcb3a80b871600da2b7db34267b7e587820ce6442e85eb6aab3b956de7e5aaf08221e65bcb301df48c9d5ce75bb11b7f20ef77b5be5901f2a6e27
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
