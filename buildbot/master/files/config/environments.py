from passwords import GITHUB_DOC_TOKEN, GITHUB_HOMEBREW_TOKEN
from passwords import S3_UPLOAD_ACCESS_KEY_ID, S3_UPLOAD_SECRET_ACCESS_KEY


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


doc = Environment({
    'CARGO_HOME': '{{ common.servo_home }}/.cargo',
    'SERVO_CACHE_DIR': '{{ common.servo_home }}/.servo',
    'SHELL': '/bin/bash',
    'TOKEN': GITHUB_DOC_TOKEN,
})

build_common = Environment({
    'RUST_BACKTRACE': '1',
})

build_windows_msvc = build_common + Environment({
    'CARGO_HOME': r'C:\Users\Administrator\.cargo',
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
    ]),
    'SERVO_CACHE_DIR': r'C:\Users\Administrator\.servo',
})

build_mac = build_common + Environment({
    'CARGO_HOME': '/Users/servo/.cargo',
    'CCACHE': '/usr/local/bin/ccache',
    'SERVO_CACHE_DIR': '/Users/servo/.servo',
    'OPENSSL_INCLUDE_DIR': '/usr/local/opt/openssl/include',
    'OPENSSL_LIB_DIR': '/usr/local/opt/openssl/lib',
})


build_linux = build_common + Environment({
    'CARGO_HOME': '{{ common.servo_home }}/.cargo',
    'CCACHE': '/usr/bin/ccache',
    'DISPLAY': ':0',
    'SERVO_CACHE_DIR': '{{ common.servo_home }}/.servo',
    'SHELL': '/bin/bash',
})

build_android = build_linux + Environment({
    'ANDROID_NDK': '{{ common.servo_home }}/android/ndk/current/',
    'ANDROID_SDK': '{{ common.servo_home }}/android/sdk/current/',
    # TODO(aneeshusa): Template this value for e.g. macOS builds
    'JAVA_HOME': '/usr/lib/jvm/java-8-openjdk-amd64',
    'PATH': ':'.join([
        '/usr/local/sbin',
        '/usr/local/bin',
        '/usr/bin',
        '/usr/sbin',
        '/sbin',
        '/bin',
        '{{ common.servo_home }}/android/sdk/current/platform-tools',
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
    'CC': 'arm-linux-gnueabihf-gcc',
    'CXX': 'arm-linux-gnueabihf-g++',
    'PATH': ':'.join([
        '{{ common.servo_home }}/bin',
        '/usr/local/sbin',
        '/usr/local/bin',
        '/usr/bin',
        '/usr/sbin',
        '/sbin',
        '/bin',
    ]),
    'PKG_CONFIG_PATH': '/usr/lib/arm-linux-gnueabihf/pkgconfig',
})

build_arm64 = build_arm + Environment({
    'BUILD_TARGET': 'aarch64-unknown-linux-gnu',
    'CC': 'aarch64-linux-gnu-gcc',
    'CXX': 'aarch64-linux-gnu-g++',
    'PATH': ':'.join([
        '{{ common.servo_home }}/bin',
        '/usr/local/sbin',
        '/usr/local/bin',
        '/usr/bin',
        '/usr/sbin',
        '/sbin',
        '/bin',
    ]),
    'PKG_CONFIG_PATH': '/usr/lib/aarch64-linux-gnu/pkgconfig',
    'SERVO_RUSTC_WITH_GOLD': 'False',
})

upload_nightly = Environment({
    'AWS_ACCESS_KEY_ID': S3_UPLOAD_ACCESS_KEY_ID,
    'AWS_SECRET_ACCESS_KEY': S3_UPLOAD_SECRET_ACCESS_KEY,
    'GITHUB_HOMEBREW_TOKEN': GITHUB_HOMEBREW_TOKEN,
})
