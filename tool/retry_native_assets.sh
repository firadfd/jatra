#!/usr/bin/env bash
# Runs a Flutter command, repeating it only when a native library download
# fails. The sqlite3 build hook fetches its binaries from GitHub releases and
# rejects anything failing its hash check, so one bad response would otherwise
# fail a whole release. Any other failure stops immediately.
#
#   bash tool/retry_native_assets.sh flutter build apk --release
set -uo pipefail

attempts="${RETRY_ATTEMPTS:-5}"
delay="${RETRY_DELAY:-30}"
output="$(mktemp)"
trap 'rm -f "$output"' EXIT

for ((attempt = 1; attempt <= attempts; attempt++)); do
  "$@" 2>&1 | tee "$output"
  status=${PIPESTATUS[0]}
  [ "$status" -eq 0 ] && exit 0

  if ! grep -qE 'Hash of downloaded file|Building native assets failed' "$output"; then
    exit "$status"
  fi
  [ "$attempt" -eq "$attempts" ] && break

  echo "::warning::Native library download failed (attempt $attempt of $attempts). Retrying."
  sleep $((delay * attempt))
done

echo "::error::Native library download still failing after $attempts attempts."
exit "$status"
