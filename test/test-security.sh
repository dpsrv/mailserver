#!/bin/bash
set -e

HOST=${1:?Usage: $0 <hostname>}

echo "=== Security Tests for $HOST ==="
echo

echo "--- Checking TLS versions (port 465) ---"
for ver in ssl3 tls1 tls1_1 tls1_2 tls1_3; do
    if echo | timeout 5 openssl s_client -connect "$HOST:465" -$ver 2>&1 | grep -q "Cipher is"; then
        echo "$ver: ENABLED"
    else
        echo "$ver: disabled"
    fi
done
echo

echo "--- Cipher suites (port 465) ---"
echo | timeout 10 openssl s_client -connect "$HOST:465" 2>/dev/null | grep -E '(Cipher|Protocol)' || true
echo

echo "--- Certificate chain (port 465) ---"
echo | timeout 10 openssl s_client -connect "$HOST:465" -showcerts 2>/dev/null | grep -E '(subject|issuer|s:|i:)' | head -20 || true
echo

echo "--- SMTP Banner (checking for info disclosure) ---"
echo "QUIT" | timeout 5 nc "$HOST" 25 2>/dev/null | head -3 || echo "Port 25 not accessible via plaintext"
echo

echo "--- testssl.sh (if available) ---"
if command -v testssl &>/dev/null || [ -x ./testssl.sh ]; then
    echo "Running testssl.sh for comprehensive TLS analysis..."
    echo "This may take a few minutes..."
    testssl --quiet --severity HIGH "$HOST:465" 2>/dev/null || ./testssl.sh --quiet --severity HIGH "$HOST:465" 2>/dev/null || true
else
    echo "testssl.sh not installed."
    echo "For comprehensive TLS testing, install from: https://github.com/drwetter/testssl.sh"
    echo "  dnf install testssl"
fi
