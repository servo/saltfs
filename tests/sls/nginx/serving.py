import urllib.request
import urllib.error
import ssl

from tests.util import Failure, Success


def check_url(url):
    # We use a self-signed certificate for automated testing.
    ssl._create_default_https_context = ssl._create_unverified_context

    try:
        urllib.request.urlopen(url)
    except urllib.error.URLError as e:
        # Can call e.read() if there was a response but the HTTP status code
        # indicated error; the method is unavailable if a connection could not
        # be made. Nginx is reverse proxying Homu and Buildbot, which will be
        # dead on Travis because the test pillar credentials are not valid.

        # Also, we're 'expecting' a string for e.reason (for the connection
        # refused error case), but it may be another exception instance.
        if not hasattr(e, 'read'):
            return False, str(e.reason)

    # No need to catch HTTPError or ContentTooShortError specially here

    return True, None


def run():
    result, err = check_url('http://localhost/')
    if not result:
        return Failure("Nginx is not serving HTTP requests:", err)

    result, err = check_url('https://localhost/')
    if not result:
        return Failure("Nginx is not serving HTTPS requests:", err)

    return Success("Nginx is serving requests")
