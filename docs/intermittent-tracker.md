# Intermittent Tracker service

This service runs a flask server that provides a Github webhook endpoint.
It receives notifications whenever the Github issue tracker is updated,
and keeps a local database of all open issues that are marked with the
`I-intermittent` label. This server also allows querying this database,
so that the `./mach filter-intermittents` command does not need to use
the Github API every time we run tests on our build machines.

See [the project source code](https://github.com/servo/intermittent-tracker/tree/master/intermittent_tracker) for more information.