b2g-download:
  file.managed:
    - name: /home/servo/B2G.tgz
    - source: https://servo-rust.s3.amazonaws.com/B2G/B2G.tgz
    - source_hash: sha1=8fbf42c4db222a0eaa716a14a502ef3dc68891fc
    - user: servo
    - group: servo
  cmd.wait:
    - name: tar xzf /home/servo/B2G.tgz
    - user: servo
    - watch:
      - file: b2g-download
