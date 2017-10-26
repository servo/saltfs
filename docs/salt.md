# Notes on Salt

## Salt overview

We use [SaltStack](https://saltstack.com/) (Salt for short)
to configure our infrastructure machines.

We're currently on the Salt 2016.3 release branch, so make sure to look at the
[right version of the docs](https://docs.saltstack.com/en/2016.3/contents.html).

Salt configurations are meant to be idempotent and can be applied as many times
as you like; a single deploy is termed a `highstate`, which
runs code to make minion(s) match the requested configuration.

Salt has a number of different modes of operation, including masterless and SSH;
we are using the default mode, which is a single master and many minions.
Note that the `servo-master1` machine runs both a `salt-master` process
and a `salt-minion` process, so we can Salt that machine itself.
Deploys should be run from the master machine, `servo-master1`.

Also, note that we may occasionally run multiple masters in a Salt multi-master
setup, e.g. this occurred when we migrated from a master on Linode to a master
on EC2. See [this issue](https://github.com/servo/saltfs/issues/281) for more.

## Salt workflow

This (the servo/saltfs) repository holds all of our Salt code, which describes
how we want to configure our machines.
We are using a feature of Salt called gitfs, which means that the Salt master
will automatically use the latest version of this repo on the master branch
at all times, which makes it hard to get out of sync and makes deploys easier.

For this reason, the recommended workflow for making changes is to make PRs
to this repository; however, note that there is a
[manual override]([Discouraged: Testing in production])
that can be used if necessary.

### Getting started

The best way to make changes is to try them out locally,
shepherd them through the review and pull request process,
then apply them in production.

Clone the [servo/saltfs](https://github.com/servo/saltfs/) repo locally,
and create a new feature branch:

```console
$ git clone git@github.com:servo/saltfs.git servo-saltfs
$ cd servo-saltfs
$ git checkout -b new-feature
```

Make changes as needed on your branch.

### Testing with Vagrant

You can test your changes using [Vagrant](https://vagrantup.com);
a Vagrantfile is included in the repo.
Vagrant's Salt provisioner tends to make backwards-incompatible changes often,
so only a few versions of Vagrant will work at any time;
the Vagrantfile has information about which ones.
Currently, any version >= 2.0.0 should work;
note that many OSs like Ubuntu may still have older versions like 1.7.x,
so you may need to
[download a different version](https://releases.hashicorp.com/vagrant/).
Note that we are using the [VirtualBox](https://www.virtualbox.org/) backend
for the actual VMs; the Vagrant installer should automatically install it for
you on Windows and macOS.

Each node type has a corresponding Vagrant target,
and Vagrant will run the Salt states when provisioning.
For example, you might run these commands from within
your checkout of the saltfs repo (same directory as the Vagrantfile):

* `$ vagrant up`: Start + provision all VMs configured in Vagrantfile,
  alternately `$ vagrant up servo-master1` to start just one
* `$ vagrant ssh servo-master1`: Connect to a running VM

Note that your prompt will change once you're inside a VM.

* `vagrant@vagrant-ubuntu-trusty-64$ sudo apt-get -y install cowsay; cowsay 'servo-saltfs ❤  Vagrant'`:
  Run commands in the VM
* `vagrant@vagrant-ubuntu-trusty-64$ exit`: Leave the VM

Back outside the VM:

* `$ vagrant provision servo-master1`: (Re-)apply the Salt states
  on the servo-master1 VM
* `$ vagrant halt`: Halt all running VMs

Note that Salt states are (should be) idempotent,
so you can run the provisioning as many times as you want.
Remember to re-run the `vagrant provision` command to apply your changes
to your VMs after you edit their config files.
If you're making changes, please run `vagrant provision` at least twice
to ensure this invariant of idempotency.

:warning: The Vagrantfile gives each VM 1 GB of memory,
which is enough to apply the Salt states but not enough to build Servo.
If you need to build Servo, edit the Vagrantfile locally to allot 4 GB
(remember not to commit this change!):

```ruby
vbox.memory = 4096
```

:dash: [vagrant-cachier](http://fgrehm.viewdocs.io/vagrant-cachier/) is
recommended to make running `vagrant provision` faster
by caching downloaded packages.
The Vagrantfile will automatically take advantage of it:
run ```vagrant plugin install vagrant-cachier``` to install it.

There's also a test script that currently has a few lints;
it requires Python 3.5 (currently must be installed manually)
and can be run as follows (must be inside the VM):

```console
vagrant@vagrant-ubuntu-trusty-64$ ./test.py
```

### PR + Review process

Once you're happy, `git commit` your changes,
`git push` them up to your fork of the saltfs repo on Github,
and [open a pull request](https://github.com/servo/saltfs/compare).

A Servo reviewer should review your changes,
roughly along [these lines](https://github.com/servo/servo/wiki/Code-review).

:memo: Take a look at the STYLE_GUIDE.md in the repository root
for some helpful hints.

### Deploying changes

Once your PR has been approved and merged by Travis,
it will be available on the master branch and Salt will automatically
use that code for deploys.

Highfive will automatically add the `S-needs-deploy` label to merged PRs.
Before running a deploy, please check what's open for deploy:
https://github.com/servo/saltfs/issues?utf8=%E2%9C%93&q=label%3AS-needs-deploy.
This helps prevent surprises at deploy time.
Make sure to remove these labels from the relevant PRs after deploying!

Examples of highstates, which should be run as root from the Salt master:

* `$ salt '*' state.highstate`: Apply all configs to all hosts
* `$ salt 'servo-linux*' state.highstate test=True`: See what would happen
  if we applied all configs to all servo-linux hosts

The '*' is a glob which means to apply the Salt states on all of the minions;
you can specify just one minion ID instead to only run the Salt states there.
[More complicated targeting is also available.]
(https://docs.saltstack.com/en/2016.3/ref/cli/index.html#using-the-salt-command)

:warning: Make sure to run with `test=True` mode first to see what effect your
changes will make before actually deploying! Read through the results carefully
and investigate anything that looks strange.

Steps to take:

```console
$ ssh root@servo-master1.servo.org
root@servo-master1$ sudo salt '*' state.highstate test=True 2>&1 --force-color | less -R
root@servo-master1$ sudo salt '*' state.highstate 2>&1 --force-color | tee salt_highstate_pr_number.log | less -R
```

Please make sure to log all Salt actions which perform changes to files,
e.g. by using `tee` as in the last command line!
Occasionally things go wrong, and having logs really helps debug,
particularly when we have to hand off between administrators.

Some deploys will require additionally manual steps, such as restarting
Buildbot or another service; these should be recorded in a checklist on the PR,
and checked off when completed to keep track of things and if a PR is deployed.

See [the wiki](https://github.com/servo/servo/wiki/Buildbot-administration)
for more information on how to restart Buildbot, Homu, etc. cleanly.

### Reverting changes

Since the Salt master will pull from the latest git master,
the easiest way to revert a change is to `git revert` the change
and shepard the revert through a PR + review into master.

### Discouraged: Testing in production

To avoid configuration drift, it's highly recommended to always use gitfs.
However, sometimes it's necessary to test or run deploys directly on the master,
without going through the saltfs master.

You can clone the saltfs repo to `/tmp/salt-testing-root/saltfs` on the master,
which acts as an override directory.
See the `salt/files/master/ADMIN_README` in this repo for more information.

:warning: Make sure to clean out the directory when you are done using it!


You can also run Salt locally on a minion.
It's easier to do this with Vagrant (use `vagrant provision` from outside
the VM) on a local VM,
but it's also possible to do on our actual infrastructure if needed.

:memo: Make sure you're logged in as root or use sudo when doing this!
`salt-call` needs to run as root.

As always, use `test=True` mode first to verify any changes.
This is especially helpful for debugging,
as you can see what changes Salt will apply without actually performing them.
Remove the `test=True` to actually run the highstate.

```console
$ salt-call state.highstate test=True 2>&1 --force-color | less -R
$ salt-call state.highstate 2>&1 --force-color | tee salt_call_highstate_pr_number.log | less -R
```

This has the same effect as running Salt from the master,
but Salt will additionally print out debug information as it runs each state,
which can be helpful when debugging.

The above will reach out and pull down the state tree and relevant pillar info
from the Salt master.
You can also use a local state and pillar tree, i.e. for testing changes.
First, create local copies of the state tree and pillar tree.
The location doesn't matter,
but let's say you put them in `/tmp/salt/states` and `/tmp/salt/pillars`.
You can make any changes you'd like to test.
Then, to run Salt completely locally, run:

```console
$ salt-call --local --file-root=/tmp/salt/states --pillar-root=/tmp/salt/pillars state.highstate test=True 2>&1 --force-color | less -R
```
Change the folder paths as necessary.

:warning: This is great for one-off testing because you have local versions of
the Salt states and pillars that you can tweak without affecting other machines,
but it can be easy to get out of sync with other machines.
If you make any kind of permanent change,
make sure it finds it way into the saltfs repo to make it repeatable!


## Salt administration

### Setting up a new Salt minion

Installation differs from OS to OS; see each specific section for details.
After installation, new minions must be enabled and accepted into the Salt PKI;
see the [instructions below](#enabling-a-new-salt-minion).

#### Linux

:warning: Setting up a master requires additional steps, these instructions only set up a minion.

Install the Salt minion:

```console
$ curl https://raw.githubusercontent.com/servo/saltfs/master/.travis/install_salt.sh | sudo sh -s linux
```

Configure and start the Salt minion:

```console
$ echo 'master:' | sudo tee /etc/salt/minion
$ echo ' - servo-master1.servo.org' | sudo tee -a /etc/salt/minion
$ echo 'servo-linuxN' | sudo tee /etc/salt/minion_id # Use the actual minion ID!
$ sudo service salt-minion start
```

#### macOS

See [the wiki](https://github.com/servo/servo/wiki/SaltStack-Administration)
for information about setting up new macOS minions.

#### Windows

Installation is not yet scripted and must currently be done manually.

1. Download [the Salt MSI](https://repo.saltstack.com/windows/Salt-Minion-2016.3.3-AMD64-Setup.exe),
   currently using version 2016.3.3.
2. Run the installer with a some options that
   configure the minion and autostart the minion.
   Make sure to provide the correct minion ID!
   `Salt-Minion-2016.3.3-AMD64-Setup.exe /S /master=servo-master1.servo.org /minion-name=servo-windowsN`

#### Enabling a new Salt minion

On the master:

```console
root@servo-master1$ salt-key -L # List pending minion keys
root@servo-master1$ salt-key -a KEY # Accept a pending minion key
root@servo-master1$ salt '*' test.ping # Verify connectivity to the new minion
```

It's also a good idea to [run a highstate](#deploying-changes)
on the new minion to set it up.

#### Setting up a new Salt master

See [the wiki](https://github.com/servo/servo/wiki/SaltStack-Administration)
for more information about setting up new masters.

### Looking up previous runs

Salt keeps track of the results of each `job` it performs,
where a single `job` may be running a single `state.highstate` on one minion,
looking up a `job` on a minion, running `test.ping` on a minion, etc.
We have configured Salt's built-in job cache to never remove entries,
so it is possible to look up the results of old jobs from the Salt master.

You can use the Salt `jobs` runner to interact with the jobs system.
To list jobs, use `list_jobs`:

```console
root@servo-master1$ salt-run jobs.list_jobs
```

Because Salt keeps track of all jobs, not just highstates, most likely
you will want to restrict to list of jobs to just highstates:

```console
root@servo-master1$ salt-run jobs.list_jobs search_function='state.highstate'
```

You can also filter by minion, start and end date; see the docs for more info.

Each job has an associated `jid`, or Job Id. Once you have a jid,
you can look up more details about that job:

```console
root@servo-master1$ salt-run jobs.print_job <jid>
```

To get just the return data for a highstate with the highstate formatting, use:

```console
root@servo-master1$ salt-run jobs.lookup_jid <jid> --out=highstate
```

See [the Salt docs](https://docs.saltstack.com/en/2016.3/ref/runners/all/salt.runners.jobs.html#module-salt.runners.jobs) for futher documentation.

### Troubleshooting

#### Refreshing the gitfs cache

Salt by default should check for gitfs updates every 60 seconds,
so highstates should always use up-to-date code from saltfs.
However, sometimes the gitfs cache can get stuck out of date.
To manually force a refresh, run on servo-master1:

```console
root@servo-master1$ salt-run fileserver.update
```

You can check to see if the gitfs cache is out of date by trying a
`test=True` highstate, and inspecting the list of states that is executed
to see if it matches what is currently in git master.

### Upgrading Salt

We're using a manual update process for now since there are so few machines:
first on the salt master, then on the minions. Things to be aware of:

* It's necessary to restart the salt-master and salt-minion services to apply
  config changes, but restarting a master or minion service will interrupt an
  ongoing highstate.
  Make sure to run the highstate more than once to fully converge on changes.
* Masters need to be updated before minions, but `salt '*' state.highstate`
  cannot enforce ordering - make sure to update just the master first with
  `salt 'servo-master1' state.highstate`.
