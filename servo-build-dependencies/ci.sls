{% from 'common/map.jinja' import root %}
{% from tpldir ~ '/ci-map.jinja' import sccache %}

sccache:
  file.managed:
    - name: {{ sccache.destination }}
    - source: https://servo-deps.s3.amazonaws.com/sccache/{{ sccache.version }}-sccache-{{ sccache.platform }}
    - source_hash: sha384={{ sccache.sha384 }}
    - user: {{ root.user }}
    {% if grains['os'] != 'Windows' %}
    - group: {{ root.group }}
    - mode: 755
    {% endif %}
    - makedirs: True
