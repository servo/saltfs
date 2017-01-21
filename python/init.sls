python2:
  pkg.installed:
    - pkgs:
      - python
    {% if grains['os'] == 'MacOS' %}
    - refresh: True
    {% endif %}

python3:
  pkg.installed:
    - pkgs:
      - python3

{% if grains['os'] == 'Ubuntu' %}
python2-dev:
  pkg.installed:
    - pkgs:
      - python-dev
{% endif %}

pip:
  pkg.installed:
    - pkgs:
      {% if grains['os'] == 'Ubuntu' %}
      - python-pip
      {% elif grains['os'] == 'MacOS' %}
      - python # pip is included with python in homebrew
      {% endif %}
    - reload_modules: True

{% if not salt['pillar.get']('is_bootstrap') %}
# virtualenv == 14.0.6 package creates virtualenv and virtualenv-3.5 executables
# note that the version of the second may change between virtualenv versions
virtualenv:
  pip.installed:
    - pkgs:
      - virtualenv == 14.0.6
    - require:
      - pkg: pip
{% endif %}
