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
    ]),
    'SHELL': '/bin/bash',
})

doc = build_linux_common + Environment({
    'SERVO_CACHE_DIR': '{{ common.servo_home }}/.servo',
    'TOKEN': GITHUB_DOC_TOKEN,
})

build_common = Environment({
    'BUILD_MACHINE': str(util.Property('slavename')),
})

build_windows_msvc = build_common + Environment({
    'PATH': ';'.join([
        r'C:\Python27',
        r'C:\Python27\Scripts',
        r'C:\Windows\system32',
        r'C:\Windows',
        r'C:\Windows\System32\Wbem',
        r'C:\Windows\System32\WindowsPowerShell\v1.0',
        r'C:\Program Files\Amazon\cfn-bootstrap',
        r'C:\Program Files\Git\cmd',
        r'C:\Program Files (x86)\WiX Toolset v3.10\bin',
        r'C:\sccache',
        r'C:\Users\Administrator\.cargo\bin',
    ]),
    'SERVO_CACHE_DIR': r'C:\Users\Administrator\.servo',
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

build_android = build_linux + Environment({
    # TODO(aneeshusa): Template this value for e.g. macOS builds
    'JAVA_HOME': '/usr/lib/jvm/java-8-openjdk-amd64',
    'PATH': ':'.join([
        '{{ common.servo_home }}/.cargo/bin',
        '/usr/local/sbin',
        '/usr/local/bin',
        '/usr/bin',
        '/usr/sbin',
        '/sbin',
        '/bin',
    ]),
})

build_arm = build_linux + Environment({
    'EXPAT_NO_PKG_CONFIG': '1',
    'FONTCONFIG_NO_PKG_CONFIG': '1',
    'FREETYPE2_NO_PKG_CONFIG': '1',
    'PKG_CONFIG_ALLOW_CROSS': '1',
})

# Unset SERVO_CACHE_DIR to test our download code for host and cross targets.
# Use arm32 because it is the fastest cross builder.
build_arm32 = build_arm.without(['SERVO_CACHE_DIR']) + Environment({
    'BUILD_TARGET': 'arm-unknown-linux-gnueabihf',
    'CC_arm-unknown-linux-gnueabihf': 'arm-linux-gnueabihf-gcc',
    'CXX_arm-unknown-linux-gnueabihf': 'arm-linux-gnueabihf-g++',
    'PKG_CONFIG_PATH': '/usr/lib/arm-linux-gnueabihf/pkgconfig',
})

build_arm64 = build_arm + Environment({
    'BUILD_TARGET': 'aarch64-unknown-linux-gnu',
    'CC_aarch64-unknown-linux-gnu': 'aarch64-linux-gnu-gcc',
    'CXX_aarch64-unknown-linux-gnu': 'aarch64-linux-gnu-g++',
    'PKG_CONFIG_PATH': '/usr/lib/aarch64-linux-gnu/pkgconfig',
    'SERVO_RUSTC_WITH_GOLD': 'False',
})

upload_nightly = Environment({
    'AWS_ACCESS_KEY_ID': S3_UPLOAD_ACCESS_KEY_ID,
    'AWS_SECRET_ACCESS_KEY': S3_UPLOAD_SECRET_ACCESS_KEY,
    'GITHUB_HOMEBREW_TOKEN': GITHUB_HOMEBREW_TOKEN,
})

sync_wpt = Environment({
    'WPT_SYNC_TOKEN': WPT_SYNC_PR_CREATION_TOKEN,
})
