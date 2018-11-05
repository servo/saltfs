{% from 'common/map.jinja' import common %}

include:
  - common

magicleap:
  archive.extracted:
    - name: {{ common.servo_home }}/magicleap
    - source: https://servo-deps.s3.amazonaws.com/magicleap/macos-sdk-v0.17.0.tar.gz
    - source_hash: sha512=040147af4f9584213285672d9dee7a582486c6ae22751da7c322185ea0aceb8f5cb141a3a266550d805be7ad31df1794d16a731bb20fd03bf2c773caa24c4afc
    - archive_format: tar
    - user: servo
    - group: staff
    - ensure_ownership_on: {{ common.servo_home }}/magicleap/v0.17.0


{{ common.servo_home }}/magicleap:
  file.directory:
    - user: servo
    - group: staff
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
    - require:
      - archive: magicleap
