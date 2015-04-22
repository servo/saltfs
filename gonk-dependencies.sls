b2g-download:
  file.managed:
    - name: /home/servo/B2G.tgz
    - source: https://servo-rust.s3.amazonaws.com/B2G/B2G.tgz
    - source_hash: sha1=ecd3d16e5b7f67bab4a39c20b39fc6cc1f478cac
    - user: servo
    - group: servo
  cmd.wait:
    - name: tar xzf /home/servo/B2G.tgz
    - user: servo
    - watch:
      - file: b2g-download
