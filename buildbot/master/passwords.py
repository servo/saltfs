HTTP_USERNAME = "{{ pillar['buildbot']['credentials']['http-user'] }}"
HTTP_PASSWORD = "{{ pillar['buildbot']['credentials']['http-pass'] }}"
SLAVE_PASSWORD = "{{ pillar['buildbot']['credentials']['slave-pass'] }}"
CHANGE_PASSWORD = "{{ pillar['buildbot']['credentials']['change-pass'] }}"
GITHUB_DOC_TOKEN = "{{pillar['buildbot']['credentials']['gh-doc-token'] }}"
GITHUB_STATUS_TOKEN = "{{pillar['buildbot']['credentials']['gh-status-token'] }}"
HOMU_BUILDBOT_SECRET = "{{pillar['buildbot']['credentials']['homu-secret'] }}"

