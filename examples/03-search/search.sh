#!/usr/bin/env bash
# 03-search: STAC search examples against stac-fastapi.pgstac 7.1.0.
# Design-only: expected counts are design expectations, not a run.
# Set STAC_API_URL to the API base (no trailing slash), e.g. the
# Node-3 service (port 8001 on that node) or your own deployment.
set -euo pipefail

STAC_API_URL="${STAC_API_URL:-<STAC_API_URL>}"
if [[ "$STAC_API_URL" == "<STAC_API_URL>" ]]; then
  echo "Set STAC_API_URL first." >&2
  exit 2
fi

echo "--- GET /collections (expect synthetic-demo listed) ---"
curl -fsS "$STAC_API_URL/collections" | jq -r '.collections[].id'

echo "--- GET /collections/synthetic-demo/items (expect 23) ---"
curl -fsS "$STAC_API_URL/collections/synthetic-demo/items" \
  | jq '.features | length'

echo "--- POST /search: bbox + datetime (expect a strict subset) ---"
curl -fsS -X POST "$STAC_API_URL/search" \
  -H 'Content-Type: application/json' -d '{
    "collections": ["synthetic-demo"],
    "bbox": [0, 0, 0.05, 0.05],
    "datetime": "2026-01-01T00:00:00Z/2026-01-10T00:00:00Z"
  }' | jq '.features | length'

echo "--- POST /search: cloud-cover query (expect a strict subset) ---"
curl -fsS -X POST "$STAC_API_URL/search" \
  -H 'Content-Type: application/json' -d '{
    "collections": ["synthetic-demo"],
    "query": {"eo:cloud_cover": {"lt": 30}}
  }' | jq '.features | length'

echo "--- POST /search: no-match window (expect 0, not an error) ---"
curl -fsS -X POST "$STAC_API_URL/search" \
  -H 'Content-Type: application/json' -d '{
    "collections": ["synthetic-demo"],
    "bbox": [50, 50, 51, 51]
  }' | jq '.features | length'
