from passwords import GITHUB_DOC_TOKEN


class Environment(dict):
    """
    Wrapper that allows 'adding' environment dictionaries
    to make it easy to build up environments piece by piece.
    """

    def __init__(self, *args, **kwargs):
        super(Environment, self).__init__(*args, **kwargs)

    def __add__(self, other):
        assert type(self) == type(other)
        combined = self.copy()
        combined.update(other)  # other takes precedence over self
        return Environment(combined)


doc = Environment({
    'CARGO_HOME': '{{ common.servo_home }}/.cargo',
    'SERVO_CACHE_DIR': '{{ common.servo_home }}/.servo',
    'SHELL': '/bin/bash',
    'TOKEN': GITHUB_DOC_TOKEN,
})

build_common = Environment({
    'RUST_BACKTRACE': '1',
})

build_windows = build_common + Environment({
    'CARGO_HOME': r'C:\msys64\home\Administrator\.cargo',
    'SERVO_CACHE_DIR': r'c:\msys64\home\Administrator\.servo',
    'MSYS': 'winsymlinks=lnk',
    'MSYSTEM': 'MINGW64',
    'PATH': ';'.join([
        r'C:\msys64\mingw64\bin',
        r'C:\msys64\usr\bin',
        r'C:\Windows\system32',
        r'C:\Windows',
        r'C:\Windows\System32\Wbem',
        r'C:\Windows\System32\WindowsPowerShell\v1.0',
        r'C:\Program Files\Amazon\cfn-bootstrap',
    ]),
})

build_mac = build_common + Environment({
    'CARGO_HOME': '/Users/servo/.cargo',
    'CCACHE': '/usr/local/bin/ccache',
    'SERVO_CACHE_DIR': '/Users/servo/.servo',
})


build_linux = build_common + Environment({
    'CARGO_HOME': '{{ common.servo_home }}/.cargo',
    'CCACHE': '/usr/bin/ccache',
    'DISPLAY': ':0',
    'SERVO_CACHE_DIR': '{{ common.servo_home }}/.servo',
    'SHELL': '/bin/bash',
})

build_linux_headless = build_linux + Environment({
    'SERVO_HEADLESS': '1',
})

build_android = build_linux + Environment({
    'ANDROID_NDK': '{{ common.servo_home }}/android/ndk/current/',
    'ANDROID_SDK': '{{ common.servo_home }}/android/sdk/current/',
    'ANDROID_TOOLCHAIN': '{{ common.servo_home }}/android/toolchain/current/',
    'PATH': ':'.join([
        '/usr/local/sbin',
        '/usr/local/bin',
        '/usr/bin',
        '/usr/sbin',
        '/sbin',
        '/bin',
        '{{ common.servo_home }}/android/sdk/current/platform-tools',
        '{{ common.servo_home }}/android/toolchain/current/bin',
    ]),
})

build_arm = build_linux + Environment({
    'EXPAT_NO_PKG_CONFIG': '1',
    'FONTCONFIG_NO_PKG_CONFIG': '1',
    'FREETYPE2_NO_PKG_CONFIG': '1',
    'PKG_CONFIG_ALLOW_CROSS': '1',
})


build_arm32 = build_arm + Environment({
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
