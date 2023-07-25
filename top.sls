# NOTE: Ensure all node types are covered in .travis.yml

base:
  'not G@os:Windows':
    - match: compound
    - admin
    - common
    - python
    - salt.common

  'os:Ubuntu':
    - match: grain
    - ubuntu

  'servo-master\d+':
    - match: pcre
    - git
    - intermittent-tracker
    - intermittent-failure-tracker
    - upstream-wpt-webhook
    - nginx
    - salt.master
