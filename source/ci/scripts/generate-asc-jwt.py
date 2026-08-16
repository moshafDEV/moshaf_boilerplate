#!/usr/bin/env python3
"""Generate a JWT bearer token for the App Store Connect API (ES256).

Usage: generate-asc-jwt.py <p8-key-file> <key-id> <issuer-id>

Uses only the Python standard library + `openssl` (no pyjwt/cryptography —
neither is guaranteed to be installed on a Mac build agent). openssl signs
with the EC private key, which yields a DER-encoded signature; the App Store
Connect API needs the raw (r || s) fixed-width format, so that conversion is
hand-rolled here.
"""
import sys
import json
import base64
import subprocess
import time


def b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def der_ecdsa_to_raw(der_sig: bytes, component_size: int = 32) -> bytes:
    # SEQUENCE { INTEGER r, INTEGER s } — minimal DER parsing, no library.
    if der_sig[0] != 0x30:
        raise ValueError("not a DER SEQUENCE")
    idx = 2 if der_sig[1] < 0x80 else 2 + (der_sig[1] & 0x7F)

    def read_integer(buf, i):
        if buf[i] != 0x02:
            raise ValueError("expected INTEGER")
        i += 1
        length = buf[i]
        i += 1
        value = buf[i:i + length]
        i += length
        return value, i

    r, idx = read_integer(der_sig, idx)
    s, idx = read_integer(der_sig, idx)

    def fixed_width(component: bytes) -> bytes:
        component = component.lstrip(b"\x00")
        if len(component) > component_size:
            raise ValueError("component longer than expected")
        return component.rjust(component_size, b"\x00")

    return fixed_width(r) + fixed_width(s)


def main() -> None:
    key_file, key_id, issuer_id = sys.argv[1], sys.argv[2], sys.argv[3]
    now = int(time.time())

    header = {"alg": "ES256", "kid": key_id, "typ": "JWT"}
    payload = {"iss": issuer_id, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"}

    h64 = b64url(json.dumps(header, separators=(",", ":")).encode())
    p64 = b64url(json.dumps(payload, separators=(",", ":")).encode())
    signing_input = f"{h64}.{p64}".encode()

    result = subprocess.run(
        ["openssl", "dgst", "-sha256", "-sign", key_file],
        input=signing_input,
        capture_output=True,
        check=True,
    )
    raw_sig = der_ecdsa_to_raw(result.stdout)
    print(f"{h64}.{p64}.{b64url(raw_sig)}")


if __name__ == "__main__":
    main()
