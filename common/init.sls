{% from tpldir ~ '/map.jinja' import common %}

servo:
  user.present:
    - fullname: Tom Servo
    - shell: /bin/bash
    - home: {{ common.servo_home }}
