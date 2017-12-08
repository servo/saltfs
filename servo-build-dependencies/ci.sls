{% from 'common/map.jinja' import root, common %}
{% from tpldir ~ '/ci-map.jinja' import sccache, rustup %}

sccache:
  file.managed:
    - name: {{ sccache.destination }}
    - source: https://s3.amazonaws.com/rust-lang-ci/rust-ci-mirror/{{ sccache.version }}-sccache-{{ sccache.platform }}
    - source_hash: sha384={{ sccache.sha384 }}
    - user: {{ root.user }}
    {% if grains['os'] != 'Windows' %}
    - group: {{ root.group }}
    - mode: 755
    {% endif %}
    - makedirs: True

rustup-update:
  cmd.run:
    - name: rustup self update
    - runas: servo
    - unless: rustup --version | grep '{{ rustup.version }}'
    - require:
      - rustup-install

rustup-install:
  cmd.run:
    - name: |
        curl https://sh.rustup.rs -sSf |
        sh -s -- --default-toolchain none -y
    - runas: servo
    - creates:
      - {{ common.servo_home }}/.rustup
      - {{ common.servo_home }}/.cargo
