b2g-download:
  file.managed:
    - name: /home/servo/B2G.tgz
    - source: https://servo-rust.s3.amazonaws.com/B2G/B2G.tgz
    - source_hash: sha1=2f871c23ddff795938cf9f4764f926bcf91b5938
    - user: servo
    - group: servo
  cmd.wait:
    - name: tar xzf /home/servo/B2G.tgz
    - user: servo
    - watch:
      - file: b2g-download
