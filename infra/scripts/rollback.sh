#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="/opt/shopnest"
CURRENT_LINK="$APP_ROOT/current"
PREVIOUS_LINK="$APP_ROOT/previous"
SERVICE_NAME="${1:-shopnest-backend}"

if [ ! -L "$PREVIOUS_LINK" ] || [ ! -d "$PREVIOUS_LINK" ]; then
  echo "No previous release found to roll back to."
  exit 1
fi

TARGET_RELEASE="$(readlink -f "$PREVIOUS_LINK")"
echo "Rolling back $SERVICE_NAME to previous release: $TARGET_RELEASE"

ln -sfn "$TARGET_RELEASE" "$CURRENT_LINK"
sudo systemctl restart "$SERVICE_NAME"
sudo nginx -t && sudo systemctl reload nginx

/opt/shopnest/current/infra/scripts/health-check.sh "http://127.0.0.1:4000/health" 10 2
echo "Rollback complete."
