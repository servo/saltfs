import urllib.request
import urllib.error

from tests.util import Failure, Success


def run():
    try:
        urllib.request.urlopen('http://localhost/')
    except urllib.error.URLError as e:
        # Can call e.read() if there was a response but the HTTP status code
        # indicated error; the method is unavailable if a connection could not
        # be made. Nginx is reverse proxying Homu and Buildbot, which will be
        # dead on Travis because the test pillar credentials are not valid.

        # Also, we're 'expecting' a string for e.reason (for the connection
        # refused error case), but it may be another exception instance.
        if not hasattr(e, 'read'):
            return Failure("Nginx is not serving requests:", str(e.reason))

    # No need to catch HTTPError or ContentTooShortError specially here

    return Success("Nginx is serving requests")
