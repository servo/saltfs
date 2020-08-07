base:
  '*':
    - travis

  'servo-master\d+':
    - match: pcre
    - homu
    - wpt-sync
    - standups
