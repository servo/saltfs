{% from 'common/map.jinja' import common %}
{% from tpldir ~ '/map.jinja' import android %}

{% if '64' in grains['cpuarch'] %}
enable-i386-architecture:
  file.managed:
    - name: /var/lib/dpkg/arch
    - source: salt://{{ tpldir }}/files/arch
    - user: root
    - group: root
    - mode: 644
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
    - pkgs:
      - s3cmd
    - require:
      - pkg: pip


android-sdk:
  archive.extracted:
    - name: {{ common.servo_home }}/android/sdk/{{ android.sdk.version }}
    - source: https://dl.google.com/android/android-sdk_{{ android.sdk.version }}-linux.tgz
    - source_hash: sha512={{ android.sdk.sha512 }}
    - archive_format: tar
    - archive_user: servo
    - if_missing: {{ common.servo_home }}/android/sdk/{{ android.sdk.version }}/android-sdk-linux
    - require:
      - user: servo
  cmd.run:
    - name: |
        expect -c '
        set timeout -1;
        spawn {{ common.servo_home }}/android/sdk/{{ android.sdk.version }}/android-sdk-linux/tools/android - update sdk --no-ui --filter platform-tool,android-{{ android.platform }};
        expect {
         "Do you accept the license" { exp_send "y\r" ; exp_continue }
         eof
        }
        '
    - user: servo
    - creates:
      - {{ common.servo_home }}/android/sdk/{{ android.sdk.version }}/android-sdk-linux/platform-tools
      - {{ common.servo_home }}/android/sdk/{{ android.sdk.version }}/android-sdk-linux/platforms/android-{{ android.platform }}
    - require:
      - pkg: android-dependencies
      - archive: android-sdk

android-sdk-current:
  file.symlink:
    - name: {{ common.servo_home }}/android/sdk/current
    - target: {{ common.servo_home }}/android/sdk/{{ android.sdk.version }}/android-sdk-linux
    - user: servo
    - group: servo
    - require:
      - cmd: android-sdk


android-ndk:
  file.managed:
    - name: {{ common.servo_home }}/android/ndk/{{ android.ndk.version }}/android-ndk-{{ android.ndk.version }}-linux-x86_64.bin
    - source: https://dl.google.com/android/ndk/android-ndk-{{ android.ndk.version }}-linux-x86_64.bin
    - source_hash: sha512={{ android.ndk.sha512 }}
    - user: servo
    - group: servo
    - mode: 744
    - dir_mode: 755
    - makedirs: True
    - require:
      - user: servo
  cmd.run:
      # Need to filter log output to avoid hitting log limits on Travis CI
    - name: '{{ common.servo_home }}/android/ndk/{{ android.ndk.version }}/android-ndk-{{ android.ndk.version }}-linux-x86_64.bin | grep -v Extracting'
    - user: servo
    - cwd: {{ common.servo_home }}/android/ndk/{{ android.ndk.version }}
    - creates: {{ common.servo_home }}/android/ndk/{{ android.ndk.version }}/android-ndk-{{ android.ndk.version }}
    - require:
      - file: android-ndk

android-toolchain:
  cmd.run:
    - name: bash {{ common.servo_home }}/android/ndk/{{ android.ndk.version }}/android-ndk-{{ android.ndk.version }}/build/tools/make-standalone-toolchain.sh --platform=android-{{ android.platform }} --toolchain=arm-linux-androideabi-4.8 --install-dir='{{ common.servo_home }}/android/toolchain/{{ android.ndk.version }}/android-toolchain' --ndk-dir='{{ common.servo_home }}/android/ndk/{{ android.ndk.version }}/android-ndk-{{ android.ndk.version }}'
    - user: servo
    - creates: {{ common.servo_home }}/android/toolchain/{{ android.ndk.version }}/android-toolchain
    - require:
      - cmd: android-ndk

# Toolchain depends on NDK so update the symlinks together
android-ndk-current:
  file.symlink:
    - name: {{ common.servo_home }}/android/ndk/current
    - target: {{ common.servo_home }}/android/ndk/{{ android.ndk.version }}/android-ndk-{{ android.ndk.version }}
    - user: servo
    - group: servo
    - require:
      - cmd: android-ndk
      - cmd: android-toolchain

android-toolchain-current:
  file.symlink:
    - name: {{ common.servo_home }}/android/toolchain/current
    - target: {{ common.servo_home }}/android/toolchain/{{ android.ndk.version }}/android-toolchain
    - user: servo
    - group: servo
    - require:
      - cmd: android-ndk
      - cmd: android-toolchain
