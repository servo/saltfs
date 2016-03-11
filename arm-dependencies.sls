arm-dependencies:
  pkg.installed:
    - pkgs:
      - g++-aarch64-linux-gnu
      - g++-arm-linux-gnueabihf

{% set path = 'https://servo-rust.s3.amazonaws.com/ARM/' %}
{% set targets = [{ 'name': 'arm-linux-gnueabihf', 
                    'symlink_name': 'arm-unknown-linux-gnueabihf',
                    'version': 'v1',
                    'local_name': 'armhf-trusty-libs.tgz',
                    'hash': 'd9a31ed488e4f848efcd07f71aa167fc73252da2a2c3b53ba8216100e2b4302b5ccd273b27c434ad189650652a1877607d328ff6b8e1edb5aa68a8927c617b49',
                   },
                  { 'name': 'aarch64-linux-gnu',
                    'symlink_name': 'aarch64-unknown-linux-gnu',
                    'version': 'v1',
                    'local_name': 'arm64-trusty-libs.tgz',
                    'hash': '6c86097188b70940835b2fc936fe70f01890fae45ba4ef79dcccc6a552ad319dcba23e21d6c849fd9d396e0c2f4476a21c93f9b3d4abb4f34d69f22d18017b1b',
                   }] %}

{% set binaries = ['elfedit',
                'gcov',
                'nm',
                'addr2line',
                'g++',
                'objcopy',
                'ar',
                'gcov-tool',
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
                'dwp',
                'ld.gold',
                'strip'] %}

{% for target in targets %}

{% for file in binaries %}
/home/servo/bin/{{ target.symlink_name }}-{{ file }}:
  file.symlink:
    - target: /usr/bin/{{ target.name }}-{{ file }}
    - makedirs: True
    - require:
      - archive: libs-{{ target.name }}
{% endfor %}

/home/servo/bin/{{ target.name }}:
  file.directory:
    - user: servo
    - group: servo
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
    - clean: True
    - require:
{% for file in binaries %}
      - file: /home/servo/bin/{{ target.symlink_name }}-{{ file }}
{% endfor %}

libs-{{ target.name }}:
  archive.extracted:
    - name: /home/servo/{{ target.version }}/rootfs-trusty-{{ target.name }} # Directory to extract into
    - source: {{ path }}{{ target.version }}/{{ target.local_name }}
    - source_hash: sha512={{ target.hash }}
    - archive_format: tar
    - archive_user: servo # 2015.8 moves these to the standard user and group parameters

{% for root in ['/usr/include', '/usr/lib', '/lib'] %}
{{ root }}/{{ target.name }}:
  file.symlink:
    - target: /home/servo/{{ target.version }}/rootfs-trusty-{{ target.name }}{{ root }}/{{ target.name }}
    - require:
      - archive: libs-{{ target.name }}

{% endfor %}
{% endfor %}
