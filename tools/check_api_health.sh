#!/usr/bin/env bash
set -euo pipefail

API_BASE_URL="${1:-https://greentill-api.apps.openxcell.dev}"

echo "Checking API base: $API_BASE_URL"

status_code="$(curl -s -o /tmp/greentill_api_health.out -w "%{http_code}" "$API_BASE_URL/api/user/login" || true)"
echo "GET /api/user/login -> HTTP $status_code"

if [ -s /tmp/greentill_api_health.out ]; then
  echo "Body preview:"
  head -c 240 /tmp/greentill_api_health.out
  echo
fi

if [ "$status_code" = "405" ] || [ "$status_code" = "401" ] || [ "$status_code" = "400" ]; then
  echo "API host is reachable."
  exit 0
fi

if [ "$status_code" = "000" ]; then
  echo "API host is not reachable from this machine."
  exit 1
fi

echo "Unexpected status code: $status_code"
