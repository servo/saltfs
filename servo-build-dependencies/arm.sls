{% from 'common/map.jinja' import common %}

arm-dependencies:
  pkg.installed:
    - pkgs:
      - g++-aarch64-linux-gnu
      - g++-arm-linux-gnueabihf

{% set rootfs_repo = 'https://servo-rust.s3.amazonaws.com/ARM' %}
{% set targets = [{
                    'name': 'arm-linux-gnueabihf',
                    'symlink_name': 'arm-unknown-linux-gnueabihf',
                    'version': 'v1',
                    'local_name': 'armhf-trusty-libs.tgz',
                    'hash': 'd9a31ed488e4f848efcd07f71aa167fc73252da2a2c3b53ba8216100e2b4302b5ccd273b27c434ad189650652a1877607d328ff6b8e1edb5aa68a8927c617b49',
                  },
                  {
                    'name': 'aarch64-linux-gnu',
                    'symlink_name': 'aarch64-unknown-linux-gnu',
                    'version': 'v1',
                    'local_name': 'arm64-trusty-libs.tgz',
                    'hash': '6c86097188b70940835b2fc936fe70f01890fae45ba4ef79dcccc6a552ad319dcba23e21d6c849fd9d396e0c2f4476a21c93f9b3d4abb4f34d69f22d18017b1b',
                  }] %}

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

{% for target in targets %}

libs-{{ target.name }}:
  archive.extracted:
    - name: {{ common.servo_home }}/rootfs-trusty-{{ target.name }}/{{ target.version }} # Directory to extract into
    - source: {{ rootfs_repo }}/{{ target.version }}/{{ target.local_name }}
    - source_hash: sha512={{ target.hash }}
    - archive_format: tar
    - archive_user: servo # 2015.8 moves these to the standard user and group parameters

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
      {% for target in targets %}
      {% for binary in binaries %}
      - file: {{ common.servo_home }}/bin/{{ target.symlink_name }}-{{ binary }}
      {% endfor %}
      {% endfor %}
