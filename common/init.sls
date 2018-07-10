{% from tpldir ~ '/map.jinja' import common %}

kvm:
  group.present:
    - system: True

servo:
  user.present:
    - fullname: Tom Servo
    - shell: /bin/bash
    - home: {{ common.servo_home }}
    - groups:
      - kvm
