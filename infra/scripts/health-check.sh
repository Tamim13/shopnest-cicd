#!/usr/bin/env bash
set -euo pipefail

URL="${1:-http://127.0.0.1:4000/health}"
RETRIES="${2:-10}"
DELAY="${3:-2}"

for i in $(seq 1 "$RETRIES"); do
  if curl -fsS "$URL" | grep -q '"UP"'; then
    echo "Health check passed on attempt $i ($URL)"
    exit 0
  fi
  echo "Attempt $i/$RETRIES failed for $URL; retrying in ${DELAY}s..."
  sleep "$DELAY"
done

echo "Health check failed after $RETRIES attempts ($URL)"
exit 1
