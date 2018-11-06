{% from 'common/map.jinja' import common %}

include:
  - common

# The magic Leap SDK is not publicly distributed, so on test deployments
# the download will fail, but we ignore the failures. To do this,
# we use curl and tar directly rather using salt's downloader,
# which fails if the download fails.

{{ common.servo_home }}/magicleap:
  file.directory:
    - user: servo
    - group: staff
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

{{ common.servo_home }}/magicleap/v0.17.0:
magicleap:
  cmd.run:
    - name: |
        curl https://servo-deps.s3.amazonaws.com/magicleap/macos-sdk-v0.17.0.tar.gz -sSf |
        tar x -C {{ common.servo_home }}/magicleap ||
	echo "Download of Magic Leap SDK failed, to be expected on test deployments."
    - runas: servo
    - require:
        - file: {{ common.servo_home }}/magicleap
