longview:
  pkgrepo.managed:
    - name: 'deb http://apt-longview.linode.com/ trusty main'
    - file: /etc/apt/sources.list.d/longview.list
    - key_url: https://apt-longview.linode.com/linode.gpg
    - require:
      - file: /etc/apt/sources.list.d

