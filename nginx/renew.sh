sleep ${RANDOM:0:2}m
certbot renew
if [ $? -ne 0 ] ; then
    # Create a new issue reporting the failure
    curl --user "servo-wpt-sync" \
         --pass '{{ pillar["wpt-sync"]["upstream-wpt-sync-token"] }}' \
         --data '{"title": "Cert renewal cron job failed"}' \
         https://api.github.com/repos/servo/saltfs/issues
fi
