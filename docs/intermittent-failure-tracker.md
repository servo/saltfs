# Intermittent Failure Tracker service

This service runs a flask server that serves two purposes:

1. an API endpoint for Servo's CI builders to report
instances of intermittent failures that are encountered

2. an HTML frontend to explore trends in
intermittent failures that have been reported.

See the project's [README](https://github.com/servo/intermittent-failure-tracker/blob/master/README.md) for more details about interacting with the service,
and [this Servo pull request](https://github.com/servo/servo/pull/16946)
for more details about how failures are reported.