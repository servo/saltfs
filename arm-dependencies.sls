arm-dependencies:
  pkg.installed:
    - pkgs:
      - g++-aarch64-linux-gnu
      - g++-arm-linux-gnueabihf

/home/servo/bin/arm64:
  file.directory:
    - user: servo
    - group: servo
    - dir_mode: 755
    - file_mode: 644

/home/servo/bin/arm32:
  file.directory:
    - user: servo
    - group: servo
    - dir_mode: 755
    - file_mode: 644

arm64-links:
  cmd.wait:
    - name: 'for f in /usr/bin/aarch64-linux-*; do f2=$(basename $f); ln -s $f /home/servo/bin/arm64/${f2/-linux/-unknown-linux}; done'
    - require:
      - pkg: arm-dependencies
      - file: /home/servo/bin/arm64

arm32-links:
  cmd.wait:
    - name: 'for f in /usr/bin/arm-linux-*; do f2=$(basename $f); ln -s $f /home/servo/bin/arm32/${f2/-linux/-unknown-linux}; done'
    - require:
      - pkg: arm-dependencies
      - file: /home/servo/bin/arm32

arm32-libs:
  archive.extracted:
    - name: /home/servo/rootfs-trusty-armhf # Directory to extract into
    - source: https://servo-rust.s3.amazonaws.com/ARM/armhf-trusty-libs.tgz
    - source_hash: sha512=d9a31ed488e4f848efcd07f71aa167fc73252da2a2c3b53ba8216100e2b4302b5ccd273b27c434ad189650652a1877607d328ff6b8e1edb5aa68a8927c617b49
    - archive_format: tar
    - archive_user: servo # 2015.8 moves these to the standard user and group parameters
    - if_missing: /home/servo/armhf-trusty-libs.tgz

/usr/include/arm-linux-gnueabihf:
  file.symlink:
    - target: /home/servo/rootfs-trusty-armhf/usr/include/arm-linux-gnueabihf
    - require:
      - archive: arm32-libs

/usr/lib/arm-linux-gnueabihf:
  file.symlink:
    - target: /home/servo/rootfs-trusty-armhf/usr/lib/arm-linux-gnueabihf
    - require:
      - archive: arm32-libs

/lib/arm-linux-gnueabihf:
  file.symlink:
    - target: /home/servo/rootfs-trusty-armhf/lib/arm-linux-gnueabihf
    - require:
      - archive: arm32-libs
    
arm64-libs:
  archive.extracted:
    - name: /home/servo/rootfs-trusty-arm64 # Directory to extract into
    - source: https://servo-rust.s3.amazonaws.com/ARM/arm64-trusty-libs.tgz
    - source_hash: sha512=6c86097188b70940835b2fc936fe70f01890fae45ba4ef79dcccc6a552ad319dcba23e21d6c849fd9d396e0c2f4476a21c93f9b3d4abb4f34d69f22d18017b1b
    - archive_format: tar
    - archive_user: servo # 2015.8 moves these to the standard user and group parameters
    - if_missing: /home/servo/arm64-trusty-libs.tgz

/usr/include/aarch64-linux-gnu:
  file.symlink:
    - target: /home/servo/rootfs-trusty-arm64/usr/include/aarch64-linux-gnu
    - require:
      - archive: arm64-libs

/usr/lib/aarch64-linux-gnu:
  file.symlink:
    - target: /home/servo/rootfs-trusty-arm64/usr/lib/aarch64-linux-gnu
    - require:
      - archive: arm64-libs

/lib/aarch64-linux-gnu:
  file.symlink:
    - target: /home/servo/rootfs-trusty-arm64/lib/aarch64-linux-gnu
    - require:
      - archive: arm64-libs
