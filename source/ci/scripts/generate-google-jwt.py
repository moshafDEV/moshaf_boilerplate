#!/usr/bin/env python3
# Signs a Google service-account JWT (RS256) for the OAuth2 JWT Bearer flow —
# stdlib-only, no google-auth library needed. Unlike the ES256 case (Apple's
# App Store Connect API), RSA's PKCS#1 v1.5 signature from openssl is already
# the raw JWT signature bytes, no DER-to-raw conversion needed.
# Usage: generate-google-jwt.py <service-account-json-path> <scope>
import base64
import json
import subprocess
import sys
import tempfile
import time


def b64url(data):
    return base64.urlsafe_b64encode(data).rstrip(b'=')


def main():
    key_file, scope = sys.argv[1], sys.argv[2]
    with open(key_file) as f:
        account = json.load(f)

    now = int(time.time())
    header = {'alg': 'RS256', 'typ': 'JWT'}
    claims = {
        'iss': account['client_email'],
        'scope': scope,
        'aud': 'https://oauth2.googleapis.com/token',
        'iat': now,
        'exp': now + 3600,
    }
    signing_input = (
        b64url(json.dumps(header, separators=(',', ':')).encode()) + b'.' +
        b64url(json.dumps(claims, separators=(',', ':')).encode())
    )

    with tempfile.NamedTemporaryFile(mode='w', suffix='.pem', delete=False) as pem:
        pem.write(account['private_key'])
        pem_path = pem.name

    try:
        signature = subprocess.run(
            ['openssl', 'dgst', '-sha256', '-sign', pem_path],
            input=signing_input, stdout=subprocess.PIPE, check=True
        ).stdout
    finally:
        subprocess.run(['rm', '-f', pem_path])

    print((signing_input + b'.' + b64url(signature)).decode())


if __name__ == '__main__':
    main()
