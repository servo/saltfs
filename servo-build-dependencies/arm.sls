{% from 'common/map.jinja' import common %}
{% from tpldir ~ '/map.jinja' import arm %}

include:
  - common

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

libs-{{ target.name }}:
  archive.extracted:
    - name: {{ common.servo_home }}/rootfs-trusty-{{ target.name }}/{{ target.version }}
    - source: https://servo-rust.s3.amazonaws.com/ARM/{{ target.download_name }}/{{ target.version }}/{{ target.download_name }}-{{ target.version }}.tgz
    - source_hash: sha512={{ target.sha512 }}
    - archive_format: tar
    - user: servo
    - group: servo
    - enforce_toplevel: False

{% for binary in binaries %}
{{ common.servo_home }}/bin/{{ target.symlink_name }}-{{ binary }}:
  file.symlink:
    - target: /usr/bin/{{ target.name }}-{{ binary }}
    - makedirs: True
    - require:
      - archive: libs-{{ target.name }}
{% endfor %}

{{ common.servo_home }}/rootfs-trusty-{{ target.name }}/{{ target.version }}:
  file.directory:
    - user: servo
    - group: servo
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
    - require:
      - archive: libs-{{ target.name }}

{{ common.servo_home }}/rootfs-trusty-{{ target.name }}:
  file.directory:
    - user: servo
    - group: servo
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
    - clean: True
    - require:
      - file: {{ common.servo_home }}/rootfs-trusty-{{ target.name }}/{{ target.version }}

{% for root in ['usr/include', 'usr/lib', 'lib'] %}
/{{ root }}/{{ target.name }}:
  file.symlink:
    - target: {{ common.servo_home }}/rootfs-trusty-{{ target.name }}/{{ target.version }}/{{ root }}/{{ target.name }}
    - require:
      - archive: libs-{{ target.name }}
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
      - file: {{ common.servo_home }}/bin/{{ target.symlink_name }}-{{ binary }}
      {% endfor %}
      {% endfor %}
