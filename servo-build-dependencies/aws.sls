include:
  - python

{% if grains['os'] == 'Ubuntu' %}
aws-cli:
  pkg.installed:
    - pkgs:
      - awscli
{% endif %}

unzip:
  pkg.installed:
    - name: unzip

# Proxychains is used for performance testing on archived web content
# https://github.com/servo/servo-warc-tests/
proxychains:
  pkg.installed:
    - name: proxychains
