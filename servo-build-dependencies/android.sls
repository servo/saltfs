{% from 'common/map.jinja' import common %}

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
      - libc6-dev-i386
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

java-8-alternative:
  cmd.run:
    - name: update-java-alternatives -s java-1.8.0-openjdk-amd64
    - require:
      - pkg: android-dependencies
