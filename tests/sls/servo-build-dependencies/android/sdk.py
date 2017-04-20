import os.path

from jinja2 import Template

from tests.util import Failure, Success, project_path

BASE_DIR = '/home/servo/android/sdk'
CHECKS = {
    '{}/android-sdk-linux': {'type': 'absent'},
    '{}/tools/android': {'type': 'file', 'executable': True},
    '{}/platform-tools': {'type': 'directory'},
    '{}/platforms/android-{platform}': {'type': 'directory'},
    '{}/build-tools/{build_tools}': {'type': 'directory'},
}


def has_perms(perms, stat_info):
    return perms == stat_info & perms


def run():
    with open(os.path.join(
        project_path(),
        'servo-build-dependencies',
        'map.jinja'
    )) as jinja_file:
        template = Template(jinja_file.read())

    sdk_vars = template.module.android['sdk']
    failures = []
    checks = {}
    for version, sdk in sdk_vars.items():
        if version == 'current':
            if sdk not in sdk_vars:
                failures.append(
                    'The current SDK is not pointed at any installed SDK'
                )
                continue
            checks[os.path.join(BASE_DIR, 'current')] = {
                'type': 'link',
                'target': os.path.join(BASE_DIR, sdk)
            }
            sdk = sdk_vars[sdk]
        for path_template, spec in CHECKS.items():
            path = path_template.format(os.path.join(BASE_DIR, version), **sdk)
            checks[path] = spec

    for path, spec in sorted(checks.items(), key=lambda kv: kv[0]):
        exists = os.path.lexists(path)
        if spec['type'] == 'absent':
            if exists:
                failures.append('{} should not exist'.format(path))
            continue
        if not exists:
            failures.append('{} does not exist but should'.format(path))
            continue
        info = os.stat(path).st_mode
        if spec['type'] == 'directory':
            if not (os.path.isdir(path) and not os.path.islink(path)):
                failures.append('{} should be a directory'.format(path))
            if not has_perms(0o700, info):
                failures.append(
                    '{} should have at least perms 700'.format(path)
                )
        elif spec['type'] == 'file':
            if not (os.path.isfile(path) and not os.path.islink(path)):
                failures.append('{} should be a file'.format(path))
            perms = 0o700 if spec['executable'] else 0o600
            if not has_perms(perms, info):
                failures.append(
                    '{} should have at least perms {:o}'.format(path, perms)
                )
        elif spec['type'] == 'link':
            if not os.path.islink(path):
                failures.append('{} should be a symlink'.format(path))
            if not os.path.realpath(path) == spec['target']:
                failures.append(
                    '{} should be a link to {}'.format(path, spec['target'])
                )

        else:
            failures.append('Unknown spec for path {}'.format(path))

    if failures:
        output = '\n'.join(('- {}'.format(f) for f in failures))
        return Failure('Android SDK(s) not installed properly:', output)

    return Success('Android SDK(s) are properly installed')
