# Admin Tasks

## SSH

### Gaining SSH Access

If you need access, create a PR against https://github.com/servo/saltfs/,
including your account in the `admin/map.jinja` file
and SSH pubkey in the `admin/ssh` folder.

To access the machines, log in as root on Linux or macOS;
there are not yet individual accounts on slaves.

If you need to test something (e.g., a reftest failure),
make sure to su - servo to simulate the space,
and check the Buildbot config for any required environment variables.

### SSH key revocation and rotation

SSH key rotation can be performed via Salt;
our Salt configs will both rotate in new keys
and automatically remove old keys.

However, waiting for a full review cycle and full highstate
on all machines can take quite a while.
This should be preferred if possible (when optimistically rotating keys),
but in the event of key leakage,
the old key must be revoked as quickly as possible.
Hence, the following steps should be used:

- Make a PR to saltfs as normal with the new key,
  and wait for a reviewer to r+ as usual.
- Using the `/tmp/salt-testing-root` on the Salt master,
  have someone deploy the changed keys without needing to wait for Homu.
  Instructions are in [our Salt docs](./salt.md#discouraged-testing-in-production).
- Run just the `sshkeys` state instead of a full highstate:
  ```
  root@servo-master1$ salt -C 'not G@os:Windows' state.sls_id sshkeys admin
  ```
  Note that Windows machines aren't targeted, as SSH keys aren't used there,
  and the state will fail to run there.
  Additionally, make sure to use `test=True` first, and `tee` to a log file.

  :warning: Make sure to wait for the command to return and check that it runs
  successfully on all machines! In case of a timeout, you can re-run the command
  targeting just a specific builder:

  ```
  root@servo-master1$ salt 'servo-mac3' state.sls_id sshkeys admin
  ```

- Make sure to clean up the `/tmp/salt-testing-root` after you're done,
  and remove the `S-needs-deploy` label on the PR after it merges.
