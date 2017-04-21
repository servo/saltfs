python3:
  pkg.installed:
    {% if grains['os'] == 'Windows' %}
    - name: python3_x64
    - version: 3.5.2150.0  # Need to pin version to set $PATH
    {% else %}
    - pkgs:
      - python3
    {% endif %}

{% if grains['os'] != 'Windows' %}
python2:
  pkg.installed:
    - pkgs:
      - python
    {% if grains['os'] == 'MacOS' %}
    - refresh: True
    {% endif %}

{% if grains['os'] == 'Ubuntu' %}
python2-dev:
  pkg.installed:
    - pkgs:
      - python-dev
{% endif %}

pip:
  pkg.installed:
    - pkgs:
      {% if grains['os'] in ['CentOS', 'Fedora', 'Ubuntu'] %}
      - python-pip
      {% elif grains['os'] == 'MacOS' %}
      - python # pip is included with python in homebrew
      {% endif %}
    - reload_modules: True

# virtualenv == 14.0.6 package creates virtualenv and virtualenv-3.5 executables
# note that the version of the second may change between virtualenv versions
virtualenv:
  pip.installed:
    - pkgs:
      - virtualenv == 14.0.6
    - require:
      - pkg: pip
{% endif %}
