{% from 'common/map.jinja' import common %}
{% from tpldir ~ '/map.jinja' import android %}

include:
  - python

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

openjdk:
  pkgrepo.managed:
    - ppa: openjdk-r/ppa
    # Note: file arg is not accepted here, so have to use the path Salt/apt use
    # in the file.exists state

/etc/apt/sources.list.d/openjdk-r-ppa-trusty.list:
  file.exists:
    - require:
      - pkgrepo: openjdk
    - require_in:
      - file: /etc/apt/sources.list.d

android-dependencies:
  pkg.installed:
    - pkgs:
      {% if '64' in grains['cpuarch'] %}
      - libc6:i386
      - libstdc++6:i386
      {% endif %}
      - openjdk-8-jdk
      - ant
      - expect
      - gcc
      - g++
      - lib32z1
      - libstdc++6
      - libgl1-mesa-dev
      - unzip
    - refresh: True
    - require:
      - pkgrepo: openjdk
  pip.installed:
    - pkgs:
      - s3cmd
    - require:
      - pkg: pip


android-sdk:
  archive.extracted:
    - name: {{ common.servo_home }}/android/sdk/{{ android.sdk.version }}
    - source: https://dl.google.com/android/repository/tools_{{ android.sdk.version }}-linux.zip
    - source_hash: sha512={{ android.sdk.sha512 }}
    - archive_format: zip
      # Workaround for https://github.com/saltstack/salt/pull/36552
    - archive_user: servo
    - user: servo
    - group: servo
    - if_missing: {{ common.servo_home }}/android/sdk/{{ android.sdk.version }}/android-sdk-linux
    - require:
      - user: servo
  cmd.run:
    - name: |
        expect -c '
        set timeout -1;
        spawn {{ common.servo_home }}/android/sdk/{{ android.sdk.version }}/android-sdk-linux/tools/android - update sdk --no-ui --all --filter platform-tools,android-{{ android.platform }},build-tools-{{ android.build_tools }};
        expect {
         "Do you accept the license" { exp_send "y\r" ; exp_continue }
         eof
        }
        '
    - runas: servo
    - creates:
      - {{ common.servo_home }}/android/sdk/{{ android.sdk.version }}/android-sdk-linux/platform-tools
      - {{ common.servo_home }}/android/sdk/{{ android.sdk.version }}/android-sdk-linux/platforms/android-{{ android.platform }}
      - {{ common.servo_home }}/android/sdk/{{ android.sdk.version }}/android-sdk-linux/build-tools/{{ android.build_tools }}
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
  archive.extracted:
    - name: {{ common.servo_home }}/android/ndk/{{ android.ndk.version }}
    - source: https://dl.google.com/android/repository/android-ndk-{{ android.ndk.version }}-linux-x86_64.zip
    - source_hash: sha512={{ android.ndk.sha512 }}
    - archive_format: zip
      # Workaround for https://github.com/saltstack/salt/pull/36552
    - archive_user: servo
    - user: servo
    - group: servo
    - if_missing: {{ common.servo_home }}/android/ndk/{{ android.ndk.version }}/android-ndk-{{ android.ndk.version }}
    - require:
      - user: servo

android-ndk-current:
  file.symlink:
    - name: {{ common.servo_home }}/android/ndk/current
    - target: {{ common.servo_home }}/android/ndk/{{ android.ndk.version }}/android-ndk-{{ android.ndk.version }}
    - user: servo
    - group: servo
    - require:
      - android-ndk
