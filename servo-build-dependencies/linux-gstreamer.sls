{% from 'common/map.jinja' import common %}

include:
  - common

libs-gstreamer:
  archive.extracted:
    - name: {{ common.servo_home }}
    - source: http://servo-deps.s3.amazonaws.com/gstreamer/gstreamer-1.16-x86_64-linux-gnu.20190514-webrtc.tar.gz
    - source_hash: sha512=a4faa66bc5e911d0d455d1354392cca3173f6489b9c66adce146d06d1f3afb7c31e2e15c86488d65bd8d4a879421bcc17719d7240eeefa3e055bc2a6d8547d38
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
