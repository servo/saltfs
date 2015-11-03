{% if '64' in grains['cpuarch'] %}
enable-i386-architecture:
  cmd.run:
    - name: 'dpkg --add-architecture i386'
    - require_in:
      - pkg: android-dependencies
{% endif %}

android-dependencies:
  pkg.installed:
    - pkgs:
      {% if '64' in grains['cpuarch'] %}
      - libc6:i386
      - libstdc++6:i386
      {% endif %}
      - default-jdk
      - ant
      - expect
      - gcc
      - g++
      - lib32z1
      - libstdc++6
      - libgl1-mesa-dev
    - refresh: True
  pip.installed:
    - name: s3cmd

android-sdk:
  archive.extracted:
    - name: /home/servo # Directory to extract into
    - source: http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
    - source_hash: sha512=96fb71d78a8c2833afeba6df617edcd6cc4e37ecd0c3bec38c39e78204ed3c2bd54b138a56086bf5ccd95e372e3c36e72c1550c13df8232ec19537da93049284
    - archive_format: tar
    - archive_user: servo # 2015.8 moves these to the standard user and group parameters
    - if_missing: /home/servo/android-sdk_r24.4.1-linux.tgz
  cmd.wait:
    # The arguments to --filter are from running 'android list sdk'
    # Currently these are:
    #   platform-tool: Android SDK Platform-tools, revision 23.0.1
    #   9: SDK Platform Android 4.3.1, API 18, revision 3
    - name: |
        expect -c '
        set timeout -1;
        spawn /home/servo/android-sdk-linux/tools/android - update sdk --no-ui --filter platform-tool,9;
        expect {
         "Do you accept the license" { exp_send "y\r" ; exp_continue }
         eof
        }
        '
    - user: servo
    - require:
      - pkg: android-dependencies
    - watch:
      - archive: android-sdk

android-ndk:
  file.managed:
    - name: /home/servo/android-ndk-r10e-linux-x86_64.bin
    - source: http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin
    - source_hash: sha512=8948c7bd1621e32dce554d5cd1268ffda2e9c5e6b2dda5b8cf0266ea60aa2dd6fddf8d290683fc1ef0b69d66c898226c7f52cc567dbb14352b4191ac19dfb371
    - user: servo
    - group: servo
    - mode: 777
  cmd.wait:
      # Need to filter log output to avoid hitting log limits on Travis CI
    - name: /home/servo/android-ndk-r10e-linux-x86_64.bin | grep -v Extracting
    - user: servo
    - watch:
      - file: android-ndk

android-ndk-toolset-configuration:
  cmd.wait:
    - name: bash /home/servo/android-ndk-r10e/build/tools/make-standalone-toolchain.sh --platform=android-18 --toolchain=arm-linux-androideabi-4.8 --install-dir='/home/servo/ndk-toolchain' --ndk-dir='/home/servo/android-ndk-r10e'
    - user: servo
    - require:
      - cmd: android-sdk
    - watch:
      - cmd: android-ndk

/home/servo/.bash_profile:
  file.managed:
    - source: salt://bash/dot.bash_profile
    - user: servo
    - group: servo
    - mode: 0644
