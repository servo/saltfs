HTTP_USERNAME = "{{ buildbot_credentials['http-user'] }}"
HTTP_PASSWORD = "{{ buildbot_credentials['http-pass'] }}"
SLAVE_PASSWORD = "{{ buildbot_credentials['slave-pass'] }}"
CHANGE_PASSWORD = "{{ buildbot_credentials['change-pass'] }}"
GITHUB_DOC_TOKEN = "{{ buildbot_credentials['gh-doc-token'] }}"
HOMU_BUILDBOT_SECRET = "{{ buildbot_credentials['homu-secret'] }}"
S3_UPLOAD_ACCESS_KEY_ID = \
    "{{ buildbot_credentials['s3-upload-access-key-id'] }}"
S3_UPLOAD_SECRET_ACCESS_KEY = \
    "{{ buildbot_credentials['s3-upload-secret-access-key'] }}"
GITHUB_STATUS_TOKEN = "{{ buildbot_credentials['gh-status-token'] }}"
