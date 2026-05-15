#!/bin/bash
set -e

HOST=${1:?Usage: $0 <hostname>}

echo "=== IMAP Tests for $HOST ==="
echo

echo "--- Port 143 (IMAP, STARTTLS) ---"
echo "A001 CAPABILITY" | timeout 10 openssl s_client -connect "$HOST:143" -starttls imap -quiet 2>/dev/null | head -10 || echo "FAILED or not available"
echo

echo "--- Port 993 (IMAPS, implicit TLS) ---"
echo "A001 CAPABILITY" | timeout 10 openssl s_client -connect "$HOST:993" -quiet 2>/dev/null | head -10 || echo "FAILED or not available"
echo

echo "--- TLS Certificate Info (port 993) ---"
echo | timeout 10 openssl s_client -connect "$HOST:993" 2>/dev/null | openssl x509 -noout -subject -dates -issuer 2>/dev/null || echo "Could not retrieve certificate"
