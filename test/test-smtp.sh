#!/bin/bash
set -e

HOST=${1:?Usage: $0 <hostname> [from@domain] [to@domain]}
FROM=${2:-test@example.com}
TO=${3:-test@example.com}

echo "=== SMTP Tests for $HOST ==="
echo

echo "--- Port 25 (SMTP, STARTTLS) ---"
echo "EHLO test" | timeout 10 openssl s_client -connect "$HOST:25" -starttls smtp -quiet 2>/dev/null | head -20 || echo "FAILED or not available"
echo

echo "--- Port 465 (SMTPS, implicit TLS) ---"
echo "EHLO test" | timeout 10 openssl s_client -connect "$HOST:465" -quiet 2>/dev/null | head -20 || echo "FAILED or not available"
echo

echo "--- Port 587 (Submission, STARTTLS) ---"
echo "EHLO test" | timeout 10 openssl s_client -connect "$HOST:587" -starttls smtp -quiet 2>/dev/null | head -20 || echo "FAILED or not available"
echo

echo "--- TLS Certificate Info (port 465) ---"
echo | timeout 10 openssl s_client -connect "$HOST:465" 2>/dev/null | openssl x509 -noout -subject -dates -issuer 2>/dev/null || echo "Could not retrieve certificate"
echo

echo "--- Testing with swaks (if available) ---"
if command -v swaks &>/dev/null; then
    echo "Testing port 587 with STARTTLS..."
    swaks --to "$TO" --from "$FROM" --server "$HOST" --port 587 --tls --quit-after RCPT 2>&1 | grep -E '(->|<-|===)' || true
else
    echo "swaks not installed. Install with: dnf install swaks"
fi
