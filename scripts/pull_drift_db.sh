#!/usr/bin/env bash

set -euo pipefail

DB_NAME="kenwell_app.sqlite"
OUTPUT_PATH=${1:-"./$DB_NAME"}
PLATFORM=${PLATFORM:-"android"}
APP_ID=${APP_ID:-"com.example.kenwell_health_app"}

function log() {
  echo "[pull_drift_db] $1"
}

function pull_android() {
  if ! command -v adb >/dev/null 2>&1; then
    log "adb not found. Install Android platform-tools and ensure adb is on PATH."
    exit 1
  fi

  DEVICE=${DEVICE_ID:-""}
  ADB="adb"
  if [[ -n "$DEVICE" ]]; then
    ADB="adb -s $DEVICE"
  fi

  log "Pulling database from Android device/emulator (app: $APP_ID)"
  TMP_PATH="/data/data/$APP_ID/app_flutter/$DB_NAME"

  $ADB exec-out run-as "$APP_ID" cat "$TMP_PATH" > "$OUTPUT_PATH"
  log "Database copied to $OUTPUT_PATH"
}

function pull_ios() {
  if ! command -v xcrun >/dev/null 2>&1; then
    log "xcrun not found. Install Xcode command line tools."
    exit 1
  }

  BUNDLE_ID=${APP_ID}
  SIMULATOR_ID=${SIMULATOR_ID:-"booted"}
  CONTAINER_PATH=$(xcrun simctl get_app_container "$SIMULATOR_ID" "$BUNDLE_ID" data 2>/dev/null || true)

  if [[ -z "$CONTAINER_PATH" ]]; then
    log "Unable to resolve simulator container. Ensure the simulator is running and the app is installed."
    exit 1
  fi

  DB_PATH="$CONTAINER_PATH/Documents/$DB_NAME"
  if [[ ! -f "$DB_PATH" ]]; then
    log "Database file not found at $DB_PATH"
    exit 1
  fi

  cp "$DB_PATH" "$OUTPUT_PATH"
  log "Database copied to $OUTPUT_PATH"
}

case "$PLATFORM" in
  android)
    pull_android
    ;;
  ios)
    pull_ios
    ;;
  *)
    log "Unsupported platform: $PLATFORM. Use PLATFORM=android or PLATFORM=ios."
    exit 1
    ;;
esac
