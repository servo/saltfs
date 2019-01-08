{% from 'common/map.jinja' import common %}

include:
  - common

libs-gstreamer:
  archive.extracted:
    - name: {{ common.servo_home }}
    - source: http://servo-deps.s3.amazonaws.com/gstreamer/gstreamer-1.14.3-20190108-1652.tar.gz
    - source_hash: sha512=456f30642004bda567ae97f0c76450063528ac6b28745496785fabeb629f65c27ca1133169a2eb8e96f6952089a75bc119e7c385ac6458d09f4d3df1c72fbbf8
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
