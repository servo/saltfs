python2:
  pkg.installed:
    - pkgs:
      - python

python3:
  pkg.installed:
    - pkgs:
      - python3
      - python3-pip
      {% if grains['os'] == 'Ubuntu' %}
      {% if grains['osrelease'] == '14.04' %}
      - python3.4-venv
      {% elif grains['osrelease'] == '18.04' %}
      - python3.7-venv
      {% else %}
      - python3-venv
      {% endif %}
      {% endif %}

{% if grains['os'] == 'Ubuntu' %}
python-dev:
  pkg.latest:
    - pkgs:
      - python-dev
      - python3-dev
{% endif %}

pip:
  pkg.installed:
    - pkgs:
      {% if grains['os'] in ['CentOS', 'Fedora', 'Ubuntu'] %}
      - python-pip
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
