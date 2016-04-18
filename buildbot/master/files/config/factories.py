import re

from buildbot.plugins import steps, util
from buildbot.process import buildstep
from buildbot.status.results import SUCCESS

import environments as envs


SERVO_REPO = "https://github.com/servo/servo"


class ServoFactory(util.BuildFactory):
    """
    Build factory which checks out the servo repo as the first build step.
    """

    def __init__(self, build_steps):
        """
        Takes a list of Buildbot steps.
        Prefer using DynamicServoFactory to using this class directly.
        """
        all_steps = [
            steps.Git(repourl=SERVO_REPO, mode="full", method="clobber"),
        ] + build_steps
        # util.BuildFactory is an old-style class so we cannot use super()
        # but must hardcode the superclass here
        util.BuildFactory.__init__(self, all_steps)


class BadConfigurationStep(buildstep.BuildStep):
    """
    Step which immediately fails the build due to a bad configuration.
    """

    haltOnFailure = True
    flunkOnFailure = True

    def __init__(self, exception):
        self.exception = exception

    def run(self):
        raise Exception("Bad configuration, unable to convert to steps" +
                        str(self.exception))


class DynamicServoFactory(ServoFactory):
    """
    Smart factory which takes a list of shell commands and creates the
    appropriate Buildbot Steps. Uses heuristics to infer Step type, if
    there are any logfiles, etc.
    """

    def __init__(self, environment, commands):
        self.environment = environment
        try:
            steps = [self.make_step(command) for command in commands]
        except Exception as e:  # Bad step configuration, fail build
            print(str(e))
            steps = [BadConfigurationStep(e)]

        # TODO: windows compatibility (use a custom script for this?)
        pkill_step = [steps.ShellCommand(command=["pkill", "-x", "servo"],
                                        decodeRC={0: SUCCESS, 1: SUCCESS})]

        # util.BuildFactory is an old-style class so we cannot use super()
        # but must hardcode the superclass here
        ServoFactory.__init__(self, pkill_step + steps)

    def make_step(self, command):
        step_kwargs = {}
        step_kwargs['env'] = self.environment

        command = command.split(' ')
        step_kwargs['command'] = command

        step_class = steps.ShellCommand
        args = iter(command)
        for arg in args:
            # Change Step class to capture warnings as needed
            # (steps.Compile and steps.Test catch warnings)
            if arg == './mach':
                mach_arg = next(args)
                if re.match('build(-.*)?', mach_arg):
                    step_class = steps.Compile
                elif re.match('test-.*', mach_arg):
                    step_class = steps.Test

            # Capture any logfiles
            elif re.match('--log-.*', arg):
                logfile = next(args)
                if 'logfiles' not in step_kwargs:
                    step_kwargs['logfiles'] = {}
                step_kwargs['logfiles'][logfile] = logfile

        return step_class(**step_kwargs)


doc = ServoFactory([
    # This is not dynamic because a) we need to pass the logEnviron kwarg
    # and b) changes to the documentation build are already encapsulated
    # in the upload_docs.sh script; any further changes should go through
    # the saltfs repo to avoid leaking the token.
    steps.ShellCommand(command=["etc/ci/upload_docs.sh"],
                       env=envs.doc,
                       # important not to leak token
                       logEnviron=False),
])

windows = ServoFactory([
    # TODO: convert this to use DynamicServoFactory
    # We need to run each command in a bash login shell, which breaks the
    # heuristics used by DynamicServoFactory.make_step
    steps.Compile(command=["bash", "-l", "-c", "./mach build -d -v"],
                  env=envs.build_windows),
    steps.Compile(command=["bash", "-l", "-c", "./mach test-unit"],
                  env=envs.build_windows),
])

mac_rel_wpt = DynamicServoFactory(envs.build_mac, [
    "./mach test-tidy --no-progress",
    "./mach build --release",
    "./mach test-wpt-failure",
    "./mach test-wpt --release --processes 4 --log-raw test-wpt.log",
    "./mach build-cef --release",
    "bash ./etc/ci/lockfile_changed.sh",
    "bash ./etc/ci/manifest_changed.sh",
])

mac_dev_unit = DynamicServoFactory(envs.build_mac, [
    "./mach build --dev",
    "./mach test-unit",
    "./mach build-cef",
    "./mach build-geckolib",
    "bash ./etc/ci/lockfile_changed.sh",
    "bash ./etc/ci/manifest_changed.sh",
])

mac_rel_css = DynamicServoFactory(envs.build_mac, [
    "./mach build --release",
    "./mach test-css --release --processes 4 --log-raw test-css.log",
    "./mach build-geckolib --release",
    "bash ./etc/ci/lockfile_changed.sh",
    "bash ./etc/ci/manifest_changed.sh",
])

linux_dev = DynamicServoFactory(envs.build_linux_headless, [
    "./mach test-tidy --no-progress",
    "./mach test-tidy --no-progress --self-test",
    "./mach build --dev",
    "./mach test-compiletest",
    "./mach test-unit",
    "./mach build-cef",
    "./mach build-geckolib",
    "bash ./etc/ci/lockfile_changed.sh",
    "bash ./etc/ci/manifest_changed.sh",
])

linux_rel = DynamicServoFactory(envs.build_linux_headless, [
    "./mach build --release",
    "./mach test-wpt-failure",
    "./mach test-wpt --release --processes 24 --log-raw test-wpt.log",
    "./mach test-css --release --processes 16 --log-raw test-css.log",
    "./mach build-cef --release",
    "./mach build-geckolib --release",
    "bash ./etc/ci/lockfile_changed.sh",
    "bash ./etc/ci/manifest_changed.sh",
    "bash ./etc/ci/check_no_unwrap.sh",
])

android = DynamicServoFactory(envs.build_android, [
    "./mach build --android --dev",
    "bash ./etc/ci/lockfile_changed.sh",
    "bash ./etc/ci/manifest_changed.sh",
    "python ./etc/ci/check_dynamic_symbols.py",
])

android_nightly = DynamicServoFactory(envs.build_android, [
    "./mach build --android --release",
    "./mach package -r",
    ("s3cmd put "
     "./target/arm-linux-androideabi/release/servo.apk "
     "s3://servo-rust/nightly/servo.apk"),
])

arm32 = DynamicServoFactory(envs.build_arm32, [
    "./mach build --rel --target=arm-unknown-linux-gnueabihf",
])

arm64 = DynamicServoFactory(envs.build_arm64, [
    "./mach build --rel --target=aarch64-unknown-linux-gnu",
])
