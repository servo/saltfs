# Upstream web-platform-tests sync service

This service runs a flask server that acts as a Github webhook target.
It watches for changes to pull requests, and if a pull request contains
changes to the vendored web-platform-tests directory, it transplants
those changes to a local clone of the w3c/web-platform-tests
repository and makes a new pull request upstream.

This service ensures that when changes to the upstream tests are merged
in servo/servo, they are also replicated in the upstream test repository
as soon as possible to avoid the two repositories getting out of sync.
See [the project's README](https://github.com/servo-automation/upstream-wpt-sync-webhook/blob/master/README.md) for more details.