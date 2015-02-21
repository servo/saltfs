b2g-download:
  file.managed:
    - name: /home/servo/B2G.tgz
    - source: https://servo-rust.s3.amazonaws.com/B2G/B2G.tgz
    - source_hash: sha1=069e6658b368b54facf30bced14a802ed3bbe69e
    - user: servo
    - group: servo
  cmd.wait:
    - name: tar xzf /home/servo/B2G.tgz
    - user: servo
    - watch:
      - file: b2g-download
