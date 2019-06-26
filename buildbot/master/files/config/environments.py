from buildbot.plugins import util
from passwords import GITHUB_DOC_TOKEN, GITHUB_HOMEBREW_TOKEN
from passwords import S3_UPLOAD_ACCESS_KEY_ID, S3_UPLOAD_SECRET_ACCESS_KEY
from passwords import WPT_SYNC_PR_CREATION_TOKEN


class Environment(dict):
    """
    Wrapper that allows 'adding' environment dictionaries
    to make it easy to build up environments piece by piece.
    """

    def __init__(self, *args, **kwargs):
        super(Environment, self).__init__(*args, **kwargs)
        # Ensure keys and values are strings,
        # which are immutable in Python,
        # allowing usage of self.copy() instead of copy.deepcopy().
        for k in self:
            assert type(k) == str
            assert type(self[k]) == str

    def copy(self):
        # Return an environment, not a plain dict
        return Environment(self)

    def __add__(self, other):
        assert type(self) == type(other)
        combined = self.copy()
        combined.update(other)  # other takes precedence over self
        return combined

    def without(self, to_unset):
        """
        Return a new Environment that does not contain the environment
        variables specified in the list of strings to_unset.
        """
        modified = self.copy()
        assert type(to_unset) == list
        for env_var in to_unset:
            if env_var in modified:
                modified.pop(env_var)
        return modified


build_linux_common = Environment({
    'PATH': ':'.join([
        '{{ common.servo_home }}/.cargo/bin',
        '{{ common.servo_home }}/bin',
        '/usr/local/sbin',
        '/usr/local/bin',
        '/usr/bin',
        '/usr/sbin',
        '/sbin',
        '/bin',
        '{{ common.servo_home }}/gst/bin',
        '{{ common.servo_home }}/gst/lib/',
    ]),
    'LD_LIBRARY_PATH': ':'.join([
        '{{ common.servo_home }}/gst/lib/',
    ]),
    'SHELL': '/bin/bash',
    'PKG_CONFIG_PATH': '{{ common.servo_home }}/gst/lib/pkgconfig',  # noqa: E501
    'GST_PLUGIN_SYSTEM_PATH': '{{ common.servo_home }}/gst/lib/gstreamer-1.0',  # noqa: E501
    'GST_PLUGIN_SCANNER': '{{ common.servo_home }}/gst/libexec/gstreamer-1.0/gst-plugin-scanner',  # noqa: E501
})

doc = build_linux_common + Environment({
    'SERVO_CACHE_DIR': '{{ common.servo_home }}/.servo',
    'TOKEN': GITHUB_DOC_TOKEN,
})

build_common = Environment({
    'BUILD_MACHINE': str(util.Property('slavename')),
})

build_mac = build_common + Environment({
    'CCACHE': '/usr/local/bin/ccache',
    'SERVO_CACHE_DIR': '/Users/servo/.servo',
    'OPENSSL_INCLUDE_DIR': '/usr/local/opt/openssl/include',
    'OPENSSL_LIB_DIR': '/usr/local/opt/openssl/lib',
    'PATH': ':'.join([
        '/Users/servo/.cargo/bin',
        '/usr/local/bin',
        '/usr/bin',
        '/bin',
        '/usr/sbin',
        '/sbin',
    ]),
})


build_linux = build_common + build_linux_common + Environment({
    'CCACHE': '/usr/bin/ccache',
    'DISPLAY': ':0',
    'SERVO_CACHE_DIR': '{{ common.servo_home }}/.servo',
})

upload_nightly = Environment({
    'AWS_ACCESS_KEY_ID': S3_UPLOAD_ACCESS_KEY_ID,
    'AWS_SECRET_ACCESS_KEY': S3_UPLOAD_SECRET_ACCESS_KEY,
    'GITHUB_HOMEBREW_TOKEN': GITHUB_HOMEBREW_TOKEN,
})

sync_wpt = Environment({
    'WPT_SYNC_TOKEN': WPT_SYNC_PR_CREATION_TOKEN,
})
