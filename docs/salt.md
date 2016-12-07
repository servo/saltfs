# Notes on Salt

## Looking up previous runs

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
