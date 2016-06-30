# Salt will replace the nominally undefined 'pillar' variable
credentials = {{pillar['buildbot']['credentials']}}  # noqa

HTTP_USERNAME = credentials['http-user']
HTTP_PASSWORD = credentials['http-pass']
SLAVE_PASSWORD = credentials['slave-pass']
CHANGE_PASSWORD = credentials['change-pass']
GITHUB_DOC_TOKEN = credentials['gh-doc-token']
HOMU_BUILDBOT_SECRET = credentials['homu-secret']
S3_UPLOAD_ACCESS_KEY_ID = credentials['s3-upload-access-key-id']
S3_UPLOAD_SECRET_ACCESS_KEY = credentials['s3-upload-secret-access-key']
