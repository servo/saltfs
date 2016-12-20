import collections
import copy
import re

from buildbot.plugins import steps, util
from buildbot.process import buildstep
from buildbot.status.results import SUCCESS
from twisted.internet import defer
import yaml

import environments as envs


SERVO_REPO = "https://github.com/servo/servo"


class CheckRevisionStep(buildstep.BuildStep):
    """\
    Step which checks to ensure the revision that triggered the build
    is the same revision that we actually checked out,
    and fails the build if this is not the case.
    """

    haltOnFailure = True
    flunkOnFailure = True

    def __init__(self, **kwargs):
        buildstep.BuildStep.__init__(self, **kwargs)

    @defer.inlineCallbacks
    def run(self):
        rev = self.getProperty('revision')
        got_rev = self.getProperty('got_revision')

        # `revision` can be None if the build is not tied to a single commit,
        # e.g. if "force build" is requested on the status page
        if rev is not None and rev != got_rev:
            raise Exception(
                "Actual commit ({}) differs from requested commit ({})".format(
                    got_rev, rev
                )
            )

        yield defer.returnValue(SUCCESS)


class ServoFactory(util.BuildFactory):
    """\
    Build factory which checks out the servo repo as the first build step.
    """

    def __init__(self, build_steps):
        """\
        Takes a list of Buildbot steps.
        Prefer using DynamicServoFactory to using this class directly.
        """
        all_steps = [
            steps.Git(
                repourl=SERVO_REPO,
                mode="full", method="fresh", retryFetch=True
            ),
            CheckRevisionStep(),
        ] + build_steps
        # util.BuildFactory is an old-style class so we cannot use super()
        # but must hardcode the superclass here
        util.BuildFactory.__init__(self, all_steps)


class StepsYAMLParsingStep(buildstep.ShellMixin, buildstep.BuildStep):
    """\
    Step which reads the YAML steps configuration in the main servo repo
    and dynamically adds test steps.
    """

    haltOnFailure = True
    flunkOnFailure = True
    workdir = None

    def __init__(self, builder_name, environment, yaml_path, **kwargs):
        kwargs = self.setupShellMixin(kwargs)
        buildstep.BuildStep.__init__(self, **kwargs)
        self.builder_name = builder_name
        self.environment = environment
        self.yaml_path = yaml_path

    def setDefaultWorkdir(self, workdir):
        buildstep.BuildStep.setDefaultWorkdir(self, workdir)
        self.workdir = workdir

    @defer.inlineCallbacks
    def run(self):
        self.is_windows = re.match('windows.*', self.builder_name) is not None
        self.is_win_gnu = re.match('windows.*gnu', builder_name) is not None
        try:
            show_cmd = "cat" if not self.is_windows else "type"
            native_yaml_path = self.yaml_path
            if self.is_windows:
                native_yaml_path = native_yaml_path.replace('/', '\\')
            cmd = yield self.makeRemoteShellCommand(
                command=[show_cmd, native_yaml_path],
                collectStdout=True
            )
            yield self.runCommand(cmd)

            result = cmd.results()
            if result != util.SUCCESS:
                raise Exception("Command failed with return code: {}" .format(
                    str(cmd.rc)
                ))
            else:
                builder_steps = yaml.safe_load(cmd.stdout)
                commands = builder_steps[self.builder_name]
                dynamic_steps = [
                    self.make_step(command) for command in commands
                ]
        except Exception as e:  # Bad step configuration, fail build
            # Capture the exception and re-raise with a friendly message
            raise Exception("Bad step configuration for {}: {}".format(
                self.builder_name,
                str(e)
            ))

        pkill_step = [self.make_pkill_step("servo")]
        self.add_steps(pkill_step + dynamic_steps)

        defer.returnValue(result)

    def add_steps(self, steps):
        """\
        Adds new steps to this build, making sure to avoid name collisions
        by adding counts to disambiguate multiple steps of the same type,
        and respecting internal Buildbot invariants.
        Semi-polyfill for addStepsAfterLastStep from Buildbot 9.
        """

        def step_type(step):
            return step.name.split('__')[0]

        name_counts = collections.Counter()

        # Check for existing max step counts for each type of step
        # in the existing steps on the build.
        # Adding multiple steps at the same time makes it more efficient
        # to check for collisions since this is amortized over all
        # steps added together.
        for step in self.build.steps:
            name_counts[step_type(step)] += 1

        # Add new steps, updating `name_counts` along the way
        for step in steps:
            existing_count = name_counts[step_type(step)]
            if existing_count > 0:
                # First step has count = 0 but no suffix,
                # so second step will have `__1` as suffix, etc.
                step.name += '__{}'.format(existing_count)
            name_counts[step_type(step)] += 1
            self._add_step(step)

    def _add_step(self, step):
        """\
        Adds a new step to this build, making sure to maintain internal
        Buildbot invariants.
        Do not call this method directly, but go through add_steps
        to prevent `name` collisions.
        """
        step.setBuild(self.build)
        step.setBuildSlave(self.build.slavebuilder.slave)
        step.setDefaultWorkdir(self.workdir)
        self.build.steps.append(step)

        step_status = self.build.build_status.addStepWithName(step.name)
        step.setStepStatus(step_status)

    def make_step(self, command):
        step_kwargs = {}
        step_env = copy.deepcopy(self.environment)

        command = command.split(' ')

        # Add `bash -l` before every command on Windows builders
        bash_args = ["bash", "-l"] if self.is_win_gnu else []
        step_kwargs['command'] = bash_args + command
        if self.is_windows:
            step_env += envs.Environment({
                # Set home directory, to avoid adding `cd` command every time
                'HOME': r'C:\buildbot\slave\{}\build'.format(
                    self.builder_name
                ),
            })

        step_desc = []
        step_class = steps.ShellCommand
        args = iter(command)
        for arg in args:
            # Change Step class to capture warnings as needed
            # (steps.Compile and steps.Test catch warnings)
            if arg == './mach' or arg == 'mach.bat':
                mach_arg = next(args)
                step_desc = [mach_arg]
                if re.match('build(-.*)?', mach_arg):
                    step_class = steps.Compile
                elif re.match('package', mach_arg):
                    step_class = steps.Compile
                elif re.match('test-.*', mach_arg):
                    step_class = steps.Test

            # Capture any logfiles
            elif re.match('--log-.*', arg):
                logfile = next(args)
                if 'logfiles' not in step_kwargs:
                    step_kwargs['logfiles'] = {}
                step_kwargs['logfiles'][logfile] = logfile

            # Provide environment variables for s3cmd
            elif arg == './etc/ci/upload_nightly.sh' or
                 next(args) == r'.\etc\ci\upload_nightly.sh':
                step_kwargs['logEnviron'] = False
                step_env += envs.upload_nightly
                if self.is_win_gnu:
                    # s3cmd on Windows only works within msys
                    step_env['MSYSTEM'] = 'MSYS'
                    step_env['PATH'] = ';'.join([
                        r'C:\msys64\usr\bin',
                        r'C:\Windows\system32',
                        r'C:\Windows',
                        r'C:\Windows\System32\Wbem',
                        r'C:\Windows\System32\WindowsPowerShell\v1.0',
                        r'C:\Program Files\Amazon\cfn-bootstrap',
                    ])

            # Set token for homebrew repository
            elif arg == './etc/ci/update_brew.sh':
                step_kwargs['logEnviron'] = False
                step_env += envs.update_brew

            else:
                step_desc += [arg]

        if step_class != steps.ShellCommand:
            step_kwargs['description'] = "running"
            step_kwargs['descriptionDone'] = "ran"
            step_kwargs['descriptionSuffix'] = " ".join(step_desc)

        step_kwargs['env'] = step_env
        return step_class(**step_kwargs)

    def make_pkill_step(self, target):
        if self.is_windows:
            pkill_command = ["powershell", "kill", "-n", target]
        else:
            pkill_command = ["pkill", "-x", target]

        return steps.ShellCommand(
            command=pkill_command,
            decodeRC={0: SUCCESS, 1: SUCCESS}
        )


class DynamicServoFactory(ServoFactory):
    """\
    Smart factory which takes a list of shell commands
    from a YAML file located in the main servo/servo repository
    and creates the appropriate Buildbot Steps.
    Uses heuristics to infer Step type, if there are any logfiles, etc.
    """

    def __init__(self, builder_name, environment):

        # util.BuildFactory is an old-style class so we cannot use super()
        # but must hardcode the superclass here
        ServoFactory.__init__(self, [
            StepsYAMLParsingStep(builder_name, environment,
                                 "etc/ci/buildbot_steps.yml")
        ])


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
