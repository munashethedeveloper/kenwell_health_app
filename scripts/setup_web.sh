#!/usr/bin/env bash
# setup_web.sh — Run this once after `flutter pub get` to install the SQLite
# WebAssembly assets required by the Drift local database on Flutter Web.
#
# What it does:
#   1. Copies `sqlite3.wasm` from the sqlite3 Dart package into `web/`
#   2. Generates `drift_worker.js` in `web/` via drift_dev
#
# These two files must be present in `web/` before `flutter build web` so that
# the browser can load the SQLite WASM module at runtime.
# Without them every local-database operation fails with:
#   "TypeError: Failed to execute 'compile' on 'WebAssembly':
#    Incorrect response MIME type. Expected 'application/wasm'."
#
# Usage:
#   chmod +x scripts/setup_web.sh
#   ./scripts/setup_web.sh

set -euo pipefail

echo "Running drift_dev web-utils to copy sqlite3.wasm and generate drift_worker.js..."
dart run drift_dev web-utils

echo ""
echo "Done! The following files have been created/updated in web/:"
echo "  web/sqlite3.wasm"
echo "  web/drift_worker.js"
echo ""
echo "Commit both files to version control so that CI and all team members have"
echo "them without needing to re-run this script."
