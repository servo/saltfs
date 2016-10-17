"""
Test nginx's security related headers

Test the headers very naively - their existence and value. Only check the
top-most '/' domain.
"""
import urllib.request

from tests.util import Failure, Success


def run():
    expected_headers = [
        ('Content-Security-Policy',
            "default-src 'self'; frame-ancestors 'none'"),
        ('X-Frame-Options', 'DENY'),
        ('X-XSS-Protection', '1; mode=block'),
        ('X-Content-Type-Options', 'nosniff')]
    with urllib.request.urlopen('http://localhost/') as local_open:
        actual_headers = local_open.getheaders()
        failures = []
        for header in expected_headers:
            if header not in actual_headers:
                failures.append('Missing or changed header - {}:{}'.format(*header))

    if len(failures) > 0:
        return Failure('nginx is serving wrong securirty headers',
                       '\n'.join(failures))
    else:
        return Success('nginx is serving the correct security headers')
