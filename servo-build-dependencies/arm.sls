{% from 'common/map.jinja' import common %}
{% from tpldir ~ '/map.jinja' import arm %}

arm-dependencies:
  pkg.installed:
    - pkgs:
      - g++-aarch64-linux-gnu
      - g++-arm-linux-gnueabihf


{% set binaries = [
    'elfedit',
    'gcov',
    'nm',
    'addr2line',
    'g++',
    'objcopy',
    'ar',
    'objdump',
    'as',
    'gcc',
    'ranlib',
    'c++filt',
    'gprof',
    'readelf',
    'cpp',
    'ld',
    'size',
    'ld.bfd',
    'strings',
    'strip'
] %}

{% for target in arm.targets %}

libs-{{ target.triple }}:
  archive.extracted:
    - name: {{ common.servo_home }}/rootfs-trusty-{{ target.triple }}/{{ target.version }}
    - source: https://servo-rust.s3.amazonaws.com/ARM/{{ target.triple }}-trusty-libs/{{ target.version }}/{{ target.triple }}-trusty-libs-{{ target.version }}.tgz
    - source_hash: sha512={{ target.sha512 }}
    - archive_format: tar
    - archive_user: servo

{% for binary in binaries %}
{{ common.servo_home }}/bin/{{ target.triple }}-{{ binary }}:
  file.symlink:
    - target: /usr/bin/{{ target.ubuntu_triple }}-{{ binary }}
    - makedirs: True
    - require:
      - archive: libs-{{ target.triple }}
{% endfor %}

{{ common.servo_home }}/rootfs-trusty-{{ target.triple }}/{{ target.version }}:
  file.directory:
    - user: servo
    - group: servo
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
    - require:
      - archive: libs-{{ target.triple }}

{{ common.servo_home }}/rootfs-trusty-{{ target.triple }}:
  file.directory:
    - user: servo
    - group: servo
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
    - clean: True
    - require:
      - file: {{ common.servo_home }}/rootfs-trusty-{{ target.triple }}/{{ target.version }}

{% for root in ['usr/include', 'usr/lib', 'lib'] %}
/{{ root }}/{{ target.ubuntu_triple }}:
  file.symlink:
    - target: {{ common.servo_home }}/rootfs-trusty-{{ target.triple }}/{{ target.version }}/{{ root }}/{{ target.ubuntu_triple }}
    - require:
      - archive: libs-{{ target.triple }}
{% endfor %}

{% endfor %}

{{ common.servo_home }}/bin:
  file.directory:
    - user: servo
    - group: servo
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
    - clean: True
    - require:
      {% for target in arm.targets %}
      {% for binary in binaries %}
      - file: {{ common.servo_home }}/bin/{{ target.triple }}-{{ binary }}
      {% endfor %}
      {% endfor %}
