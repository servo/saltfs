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

{% for version, sdk in android.sdk.items() if version != 'current' %}
android-sdk-{{ version }}-purge:
  file.absent:
    - name: {{ common.servo_home }}/android/sdk/{{ version }}
    - prereq:
      - archive: android-sdk-{{ version }}

android-sdk-{{ version }}:
  archive.extracted:
    - name: {{ common.servo_home }}/android/sdk/{{ version }}
    - source: https://dl.google.com/android/repository/tools_{{ version }}-linux.zip
    - source_hash: sha512={{ sdk.sha512 }}
    - archive_format: zip
      # Workaround for https://github.com/saltstack/salt/pull/36552
    - archive_user: servo
    - user: servo
    - group: servo
      # Use this to ensure the SDK on disk has the correct directory layout,
      # and use the subsequent `file.directory` state to fix ownership.
    - if_missing: {{ common.servo_home }}/android/sdk/{{ version }}/tools/android
    - require:
      - user: servo
  file.directory:
    - name: {{ common.servo_home }}/android/sdk/{{ version }}
    - user: servo
    - group: servo
    - recurse:
      - user
      - group
    - require:
      - user: servo
      - archive: android-sdk-{{ version }}
  cmd.run:
    - name: |
        expect -c '
        set timeout -1;
        spawn {{ common.servo_home }}/android/sdk/{{ version }}/tools/android - update sdk --no-ui --all --filter platform-tools,android-{{ sdk.platform }},build-tools-{{ sdk.build_tools }};
        expect {
         "Do you accept the license" { exp_send "y\r" ; exp_continue }
         eof
        }
        '
    - runas: servo
    - creates:
      - {{ common.servo_home }}/android/sdk/{{ version }}/platform-tools
      - {{ common.servo_home }}/android/sdk/{{ version }}/platforms/android-{{ sdk.platform }}
      - {{ common.servo_home }}/android/sdk/{{ version }}/build-tools/{{ sdk.build_tools }}
    - require:
      - pkg: android-dependencies
      - file: android-sdk-{{ version }}
{% endfor %}

android-sdk-current-unlink:
  file.absent:
    - name: {{ common.servo_home }}/android/sdk/current
    - prereq:
      - archive: android-sdk-{{ android.sdk.current }}
    - require_in:
      - file: android-sdk-{{ android.sdk.current }}-purge

android-sdk-current:
  file.symlink:
    - name: {{ common.servo_home }}/android/sdk/current
    - target: {{ common.servo_home }}/android/sdk/{{ android.sdk.current }}
    - user: servo
    - group: servo
    - require:
      - cmd: android-sdk-{{ android.sdk.current }}


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
