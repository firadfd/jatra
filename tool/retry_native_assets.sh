#!/usr/bin/env bash
# Runs a Flutter command, repeating it only when a download fails. The sqlite3
# build hook and Gradle both fetch files during the build, some of them through
# GitHub, so one bad response would otherwise fail a whole release. Any other
# failure stops immediately.
#
#   bash tool/retry_native_assets.sh flutter build apk --release
set -uo pipefail

attempts="${RETRY_ATTEMPTS:-5}"
delay="${RETRY_DELAY:-30}"
download_failure='Hash of downloaded file|Building native assets failed|Could not download |Could not GET |Could not HEAD |Read timed out|Connect timed out|Connection reset|Premature end of Content-Length'
output="$(mktemp)"
trap 'rm -f "$output"' EXIT

for ((attempt = 1; attempt <= attempts; attempt++)); do
  "$@" 2>&1 | tee "$output"
  status=${PIPESTATUS[0]}
  [ "$status" -eq 0 ] && exit 0

  if ! grep -qE "$download_failure" "$output"; then
    exit "$status"
  fi
  [ "$attempt" -eq "$attempts" ] && break

  echo "::warning::Download failed (attempt $attempt of $attempts). Retrying."
  sleep $((delay * attempt))
done

echo "::error::Download still failing after $attempts attempts."
exit "$status"
