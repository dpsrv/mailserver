#!/bin/bash
set -e

HOST=${1:?Usage: $0 <hostname>}

echo "=== Open Relay Tests for $HOST ==="
echo "Testing if server accepts mail from external sender to external recipient (should be REJECTED)"
echo

EXTERNAL_FROM="attacker@evil.example.com"
EXTERNAL_TO="victim@other.example.com"

test_relay() {
    local port=$1
    local tls_opt=$2
    local desc=$3

    echo "--- $desc ---"

    if command -v swaks &>/dev/null; then
        result=$(swaks --to "$EXTERNAL_TO" --from "$EXTERNAL_FROM" --server "$HOST" --port "$port" $tls_opt --helo test.local --quit-after RCPT 2>&1)
        if echo "$result" | grep -qE '(550|554|553|521|relay|denied|rejected)'; then
            echo "PASS: Relay denied"
            echo "$result" | grep -E '(<-|->)' | tail -5
        elif echo "$result" | grep -qE '(250|Ok|ok|queued)'; then
            echo "FAIL: SERVER MAY BE AN OPEN RELAY!"
            echo "$result"
        else
            echo "INCONCLUSIVE:"
            echo "$result" | tail -10
        fi
    else
        echo "swaks not installed. Install with: dnf install swaks"
        return 1
    fi
    echo
}

test_relay 25 "--tls" "Port 25 (STARTTLS)"
test_relay 465 "-tlsc" "Port 465 (implicit TLS)"
test_relay 587 "--tls" "Port 587 (STARTTLS)"

echo "=== Summary ==="
echo "If all tests show 'Relay denied', the server is properly configured."
echo "If any test shows 'OPEN RELAY', the server needs immediate attention!"
