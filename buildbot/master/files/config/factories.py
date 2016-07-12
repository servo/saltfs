import copy
import os.path
import re

from buildbot.plugins import steps, util
from buildbot.process import buildstep
from buildbot.status.results import SUCCESS
from twisted.internet import defer
import yaml

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
            steps.Git(repourl=SERVO_REPO,
                      mode="full", method="fresh", retryFetch=True),
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
    Smart factory which takes a list of shell commands from a yaml file
    and creates the appropriate Buildbot Steps. Uses heuristics to infer
    Step type, if there are any logfiles, etc.
    """

    def __init__(self, builder_name, environment):
        self.environment = environment
        self.is_windows = re.match('windows.*', builder_name) is not None
        try:
            config_dir = os.path.dirname(os.path.realpath(__file__))
            yaml_path = os.path.join(config_dir, 'steps.yml')
            with open(yaml_path) as steps_file:
                builder_steps = yaml.safe_load(steps_file)
            commands = builder_steps[builder_name]
            dynamic_steps = [self.make_step(command) for command in commands]
        except Exception as e:  # Bad step configuration, fail build
            print(str(e))
            dynamic_steps = [BadConfigurationStep(e)]

        pkill_step = [self.make_pkill_step("servo")]

        # util.BuildFactory is an old-style class so we cannot use super()
        # but must hardcode the superclass here
        ServoFactory.__init__(self, pkill_step + dynamic_steps)

    def make_step(self, command):
        step_kwargs = {}
        step_env = copy.deepcopy(self.environment)

        command = command.split(' ')

        # Add `bash -l` before every command on Windows builders
        bash_args = ["bash", "-l"] if self.is_windows else []
        step_kwargs['command'] = bash_args + command

        step_desc = []
        step_class = steps.ShellCommand
        args = iter(command)
        for arg in args:
            # Change Step class to capture warnings as needed
            # (steps.Compile and steps.Test catch warnings)
            if arg == './mach':
                mach_arg = next(args)
                step_desc = [mach_arg]
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

            # Provide environment variables for s3cmd
            elif arg == './etc/ci/upload_nightly.sh':
                step_kwargs['logEnviron'] = False
                step_env += envs.upload_nightly

            else:
                step_desc = [arg]

        if step_class != steps.ShellCommand:
            step_kwargs['descriptionSuffix'] = " ".join(step_desc)

        step_kwargs['description'] = "running"
        step_kwargs['descriptionDone'] = "ran"

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


class StepsYAMLParsingStep(buildstep.ShellMixin, buildstep.BuildStep):
    """
    Step which resolves the in-tree YAML and dynamically adds test steps.
    """

    haltOnFailure = True
    flunkOnFailure = True

    def __init__(self, builder_name, environment, yaml_path, **kwargs):
        kwargs = self.setupShellMixin(kwargs)
        buildstep.BuildStep.__init__(self, **kwargs)
        self.builder_name = builder_name
        self.environment = environment
        self.yaml_path = yaml_path

    @defer.inlineCallbacks
    def run(self):
        self.is_windows = re.match('windows.*', self.builder_name) is not None
        try:
            cmd = yield self.makeRemoteShellCommand(
                command=["cat", "./{}".format(self.yaml_path)],
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
                dynamic_steps = [self.make_step(command)
                                 for command in commands]
        except Exception as e:  # Bad step configuration, fail build
            # Capture the exception and re-raise with a friendly message
            raise Exception("Bad step configuration for {}: {}".format(
                self.builder_name,
                str(e)
            ))

        pkill_step = [self.make_pkill_step("servo")]

        self.build.steps += pkill_step + dynamic_steps

        defer.returnValue(result)

    def make_step(self, command):
        step_kwargs = {}
        step_env = copy.deepcopy(self.environment)

        command = command.split(' ')

        # Add `bash -l` before every command on Windows builders
        bash_args = ["bash", "-l"] if self.is_windows else []
        step_kwargs['command'] = bash_args + command
        step_env += envs.Environment({
            # Set home directory, to avoid adding `cd` command on every command
            'HOME': r'C:\buildbot\slave\{}\build'.format(self.builder_name),
            })

        step_desc = []
        step_class = steps.ShellCommand
        args = iter(command)
        for arg in args:
            # Change Step class to capture warnings as needed
            # (steps.Compile and steps.Test catch warnings)
            if arg == './mach':
                mach_arg = next(args)
                step_desc = [mach_arg]
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

            # Provide environment variables for s3cmd
            elif arg == './etc/ci/upload_nightly.sh':
                step_kwargs['logEnviron'] = False
                step_env += envs.upload_nightly

            else:
                step_desc = [arg]

        if step_class != steps.ShellCommand:
            step_kwargs['descriptionSuffix'] = " ".join(step_desc)

        step_kwargs['description'] = "running"
        step_kwargs['descriptionDone'] = "ran"

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


class DynamicServoYAMLFactory(ServoFactory):
    """
    Smart factory which takes a list of shell commands from a YAML file
    located in the main servo/servo repository and creates the appropriate
    Buildbot Steps.
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
