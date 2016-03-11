arm-dependencies:
  pkg.installed:
    - pkgs:
      - g++-aarch64-linux-gnu
      - g++-arm-linux-gnueabihf

{% set targets = [{ 'name': 'arm-linux-gnueabihf', 
                    'file': 'https://servo-rust.s3.amazonaws.com/ARM/v1/armhf-trusty-libs.tgz',
                    'local_name': 'armhf-trusty-libs.tgz',
                    'hash': 'd9a31ed488e4f848efcd07f71aa167fc73252da2a2c3b53ba8216100e2b4302b5ccd273b27c434ad189650652a1877607d328ff6b8e1edb5aa68a8927c617b49',
                   },
                  { 'name': 'aarch64-linux-gnu',
                    'file': 'https://servo-rust.s3.amazonaws.com/ARM/v1/arm64-trusty-libs.tgz',
                    'local_name': 'arm64-trusty-libs.tgz',
                    'hash': '6c86097188b70940835b2fc936fe70f01890fae45ba4ef79dcccc6a552ad319dcba23e21d6c849fd9d396e0c2f4476a21c93f9b3d4abb4f34d69f22d18017b1b',
                   }] %}

{% for target in targets %}
/home/servo/bin/{{ target.name }}:
  file.directory:
    - user: servo
    - group: servo
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True

links-{{ target.name }}:
  cmd.run:
    - name: 'for f in /usr/bin/{{ target.name }}*; do f2=$(basename $f); ln -s $f /home/servo/bin/{{ target.name }}/${f2/-linux/-unknown-linux}; done'
    - user: servo
    - group: servo
    - require:
      - pkg: arm-dependencies
      - file: /home/servo/bin/{{ target.name }}

libs-{{ target.name }}:
  archive.extracted:
    - name: /home/servo/v1/rootfs-trusty-{{ target.name }} # Directory to extract into
    - source: {{ target.file }}
    - source_hash: sha512={{ target.hash }}
    - archive_format: tar
    - archive_user: servo # 2015.8 moves these to the standard user and group parameters

{% for root in ['/usr/include', '/usr/lib', '/lib'] %}
{{ root }}{{ target.name }}:
  file.symlink:
    - target: /home/servo/v1/rootfs-trusty-{{ target.name }}{{ root }}{{ target.name }}
    - require:
      - archive: libs-{{ root }}-{{ target.name }}

{% endfor %}
{% endfor %}
