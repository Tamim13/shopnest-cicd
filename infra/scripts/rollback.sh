#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="${1:-shopnest-backend}"
TARGET_RELEASE="${2:-}"
BASE_DIR="/opt/shopnest"
RELEASES_DIR="${BASE_DIR}/releases"
CURRENT_LINK="${BASE_DIR}/current"
PREVIOUS_LINK="${BASE_DIR}/previous"
HEALTH_SCRIPT="${BASE_DIR}/current/infra/scripts/health-check.sh"

log() {
  echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] [ROLLBACK] $*"
}

if [ -n "$TARGET_RELEASE" ]; then
  if [ -d "$TARGET_RELEASE" ]; then
    ROLLBACK_TARGET="$TARGET_RELEASE"
  elif [ -d "${RELEASES_DIR}/${TARGET_RELEASE}" ]; then
    ROLLBACK_TARGET="${RELEASES_DIR}/${TARGET_RELEASE}"
  else
    log "ERROR: Target release '${TARGET_RELEASE}' not found in ${RELEASES_DIR}"
    exit 1
  fi
else
  if [ ! -L "$PREVIOUS_LINK" ] && [ ! -e "$PREVIOUS_LINK" ]; then
    log "ERROR: No 'previous' release symlink found at ${PREVIOUS_LINK}"
    exit 1
  fi
  ROLLBACK_TARGET="$(readlink -f "$PREVIOUS_LINK")"
  if [ ! -d "$ROLLBACK_TARGET" ]; then
    log "ERROR: Resolved previous target '${ROLLBACK_TARGET}' does not exist"
    exit 1
  fi
fi

log "Rolling back '${SERVICE_NAME}' to release: ${ROLLBACK_TARGET}"
ln -sfn "$ROLLBACK_TARGET" "$CURRENT_LINK"

if [ -d "${ROLLBACK_TARGET}/backend" ]; then
  npm --prefix "${ROLLBACK_TARGET}/backend" ci --omit=dev
fi

sudo systemctl restart "$SERVICE_NAME"
sudo nginx -t && sudo systemctl reload nginx

if [ -x "$HEALTH_SCRIPT" ]; then
  "$HEALTH_SCRIPT"
elif [ -x "${ROLLBACK_TARGET}/infra/scripts/health-check.sh" ]; then
  "${ROLLBACK_TARGET}/infra/scripts/health-check.sh"
else
  curl -fsS http://127.0.0.1:4000/health >/dev/null
fi

log "Rollback to '${ROLLBACK_TARGET}' succeeded and service is healthy."
