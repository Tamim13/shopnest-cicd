#!/usr/bin/env bash
set -euo pipefail

RELEASE_DIR="${1:?Release directory path is required}"
APP_ROOT="/opt/shopnest"
RELEASES_DIR="$APP_ROOT/releases"
CURRENT_LINK="$APP_ROOT/current"
PREVIOUS_LINK="$APP_ROOT/previous"
SERVICE_NAME="${2:-shopnest-backend}"

mkdir -p "$RELEASES_DIR"

if [ -L "$CURRENT_LINK" ] && [ -e "$CURRENT_LINK" ]; then
  OLD_RELEASE="$(readlink -f "$CURRENT_LINK")"
  ln -sfn "$OLD_RELEASE" "$PREVIOUS_LINK"
fi

# Switch active symlink atomically
ln -sfn "$RELEASE_DIR" "$CURRENT_LINK"

# Install production backend dependencies inside the release
cd "$CURRENT_LINK/backend"
npm ci --omit=dev

# Restart backend service and reload Nginx without dropping connections
sudo systemctl restart "$SERVICE_NAME"
sudo nginx -t && sudo systemctl reload nginx

# Verify live health endpoint; automatically roll back if unhealthy
if ! "$CURRENT_LINK/infra/scripts/health-check.sh" "http://127.0.0.1:4000/health" 10 2; then
  echo "Deployment failed health check. Triggering automatic rollback..."
  if [ -L "$PREVIOUS_LINK" ] && [ -e "$PREVIOUS_LINK" ]; then
    "$CURRENT_LINK/infra/scripts/rollback.sh" "$SERVICE_NAME"
  fi
  exit 1
fi

# Keep only the latest 5 releases to save disk space
ls -1dt "$RELEASES_DIR"/* 2>/dev/null | tail -n +6 | xargs -r rm -rf

echo "Deployment succeeded for release: $RELEASE_DIR"
