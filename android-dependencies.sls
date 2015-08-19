{% if '64' in grains['cpuarch'] %}
#TODO: need to do these first on new ubuntus.
#dpkg --add-architecture i386
#apt-get update
android-dependencies-multilib:
  pkg.installed:
    - pkgs:
      - libc6:i386
      - libstdc++6:i386
{% endif %}

android-dependencies:
  pkg.installed:
    - pkgs:
      - default-jdk
      - ant
      - expect
      - gcc
      - g++
      - lib32z1
      - libstdc++6
      - libgl1-mesa-dev

android-python-dependencies:
  pip.installed:
    - s3cmd

android-sdk-download:
  file.managed:
    - name: /home/servo/android-sdk_r23.0.2-linux.tgz
    - source: http://dl.google.com/android/android-sdk_r23.0.2-linux.tgz
    - source_hash: sha1=6b79b05bc876a8126f5ba034602e01306706de75
    - user: servo
    - group: servo
  cmd.wait:
    - name: tar xzf /home/servo/android-sdk_r23.0.2-linux.tgz
    - user: servo
    - watch:
      - file: android-sdk-download

android-sdk-chown:
  cmd.wait:
    - name: chown -R servo:servo /home/servo/android-sdk-linux
    - watch:
      - cmd: android-sdk-download

android-sdk-update:
  cmd.wait:
    - name: |
        expect -c '
        set timeout -1;
        spawn /home/servo/android-sdk-linux/tools/android - update sdk --no-ui;
        expect {
         "Do you accept the license" { exp_send "y\r" ; exp_continue }
         eof
        }
        '
    - user: servo
    - watch:
      - cmd: android-sdk-download
    - require:
      - pkg: android-dependencies

android-ndk-download:
  file.managed:
    - name: /home/servo/android-ndk-r10c-linux-x86_64.bin
    - source: http://dl.google.com/android/ndk/android-ndk-r10c-linux-x86_64.bin
    - source_hash: sha1=87e159831a6759d5fb84545c445e551995185634
    - user: servo
    - group: servo
    - mode: 777

android-ndk-install:
  cmd.wait:
    - name: /home/servo/android-ndk-r10c-linux-x86_64.bin
    - user: servo
    - watch:
      - file: android-ndk-download

android-ndk-toolset-configuration:
  cmd.wait:
    - name: bash /home/servo/android-ndk-r10c/build/tools/make-standalone-toolchain.sh --platform=android-18 --toolchain=arm-linux-androideabi-4.8 --install-dir='/home/servo/ndk-toolchain' --ndk-dir='/home/servo/android-ndk-r10c'
    - user: servo
    - watch:
      - cmd: android-ndk-install

/home/servo/.bash_profile:
  file.managed:
    - source: salt://bash/dot.bash_profile
    - user: servo
    - group: servo
    - mode: 0644
