{% if grains['os'] == 'MacOS' %}

python2:
  pkg.installed:
    - pkgs:
      - python@2
    - refresh: True
    - reload_modules: True

python3:
  pkg.installed:
    - pkgs:
      - python

{% else %}

python2:
  pkg.installed:
    - pkgs:
      - python

python3:
  pkg.installed:
    - pkgs:
      - python3
      {% if grains['os'] == 'Ubuntu' %}
      {% if grains['osrelease'] == '14.04' %}
      - python3.4-venv
      {% else %}
      - python3-venv
      {% endif %}
      {% endif %}

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
      - python@2 # pip is included with python in homebrew
      {% endif %}
    - reload_modules: True
    {% if grains['os'] == 'MacOS' %}
    - ignore_installed: True
    {% endif %}

# virtualenv == 14.0.6 package creates virtualenv and virtualenv-3.5 executables
# note that the version of the second may change between virtualenv versions
virtualenv:
  pip.installed:
    - pkgs:
      - virtualenv == 14.0.6
    - require:
      - pkg: pip
    {% if grains['os'] == 'MacOS' %}
    - ignore_installed: True
    {% endif %}
