import json

# Jinja will replace the inside with double-quote-using JSON,
# so use single quotes to delimit the string.
# Use double quotes inside to keep the expression as a single string.
credentials = json.loads('{{ pillar["buildbot"]["credentials"]|json }}')
# json.loads creates unicode strings but Buildbot requires bytestrings.
# Python 2's Unicode situation makes me sad.
credentials = {k: v.encode('utf-8') for k, v in credentials.items()}

HTTP_USERNAME = credentials['http-user']
HTTP_PASSWORD = credentials['http-pass']
SLAVE_PASSWORD = credentials['slave-pass']
CHANGE_PASSWORD = credentials['change-pass']
GITHUB_DOC_TOKEN = credentials['gh-doc-token']
HOMU_BUILDBOT_SECRET = credentials['homu-secret']
S3_UPLOAD_ACCESS_KEY_ID = credentials['s3-upload-access-key-id']
S3_UPLOAD_SECRET_ACCESS_KEY = credentials['s3-upload-secret-access-key']
