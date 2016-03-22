{% from 'common/map.jinja' import common %}
{% from tpldir ~ '/map.jinja' import b2g %}

b2g:
  archive.extracted:
    - name: {{ common.servo_home }}
    - source: https://servo-rust.s3.amazonaws.com/B2G/B2G.tgz
    - source_hash: sha512={{ b2g.sha512 }}
    - archive_format: tar
    - archive_user: servo
    - if_missing: {{ common.servo_home }}/B2G
