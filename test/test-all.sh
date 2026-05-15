#!/bin/bash
set -e

HOST=${1:?Usage: $0 <hostname> [from@domain] [to@domain]}
FROM=${2:-test@example.com}
TO=${3:-test@example.com}

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

echo "=============================================="
echo "  Mail Server Test Suite"
echo "  Host: $HOST"
echo "=============================================="
echo

"$SCRIPT_DIR/test-smtp.sh" "$HOST" "$FROM" "$TO"
echo
echo "=============================================="
echo

"$SCRIPT_DIR/test-imap.sh" "$HOST"
echo
echo "=============================================="
echo

"$SCRIPT_DIR/test-open-relay.sh" "$HOST"
echo
echo "=============================================="
echo

"$SCRIPT_DIR/test-security.sh" "$HOST"
