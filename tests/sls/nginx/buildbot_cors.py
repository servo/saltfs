import urllib.request
import urllib.error

from tests.util import Failure, Success, format_nested_failure


def format_header(response, header):
    """
    Precondition: header exists in response.headers
    """
    return "{}: Access-Control-{}".format(header, response.headers[header])


def make_cors_request(url, **kwargs):
    try:
        cors_request = urllib.request.Request(url, headers={
            'Origin': 'http://example.com',
        }, **kwargs)
        return urllib.request.urlopen(cors_request)
    except urllib.error.URLError as e:
        # Can read e.headers() if there was a response but the HTTP status code
        # indicated error; the method is unavailable if a connection could not
        # be made. Nginx is reverse proxying Homu and Buildbot, which will be
        # dead on Travis because the test pillar credentials are not valid.
        return e

    # No need to catch HTTPError or ContentTooShortError specially here


def run():
    url = 'http://localhost/'
    get = make_cors_request(url)
    post = make_cors_request(url, method='POST')

    if 'Access-Control-Allow-Origin' not in get.headers:
        return Failure("Nginx is not serving CORS headers:", str(get.headers))

    failures = []

    if 'Access-Control-Allow-Origin' in post.headers:
        failures += [Failure("CORS headers are served on non-GET requests",
                             "")]

    if get.headers['Access-Control-Allow-Origin'] != '*':
        failures += [Failure("All origins are not whitelisted:",
                             format_header(get, 'Allow-Origin'))]

    if 'Access-Control-Allow-Credentials' in get.headers:
        failures += [Failure("Cookies are allowed for CORS requests:",
                             format_header(get, 'Allow-Credentials'))]

    if 'Access-Control-Expose-Headers' in get.headers:
        failures += [Failure("Headers are exposed on CORS requests:",
                             format_header(get, 'Expose-Headers'))]

    if len(failures) > 0:
        return Failure("Nginx is serving incorrect CORS headers:",
                       '\n'.join([format_nested_failure(f) for f in failures]))

    return Success("Nginx is serving CORS headers properly")
