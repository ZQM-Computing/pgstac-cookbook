#!/usr/bin/env bash
# 06-full-workflow: install -> ingest -> search -> serve, chained.
# Design-only: aborts on the first failed step (set -euo pipefail).
# Requires the sibling pattern scripts in this repo's examples/
# directory and the placeholders from patterns 02-05.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLES_DIR="${EXAMPLES_DIR:-$HERE/..}"

: "${PGSTAC_DSN:?Set PGSTAC_DSN (pattern 02).}"
: "${STAC_API_URL:?Set STAC_API_URL (patterns 03-04).}"
: "${TITILER_URL:?Set TITILER_URL (pattern 05).}"
: "${COG_URL:?Set COG_URL (pattern 05).}"
export PGSTAC_DSN STAC_API_URL TITILER_URL COG_URL

echo "=== step 1: ingest (pattern 02) ==="
bash "$EXAMPLES_DIR/02-ingest/run.sh"

echo "=== step 2: search (pattern 03) ==="
bash "$EXAMPLES_DIR/03-search/search.sh"

echo "=== step 3: serve health (pattern 04 checks) ==="
curl -fsS "$STAC_API_URL/collections" > /dev/null
curl -fsS "$STAC_API_URL/openapi.json" > /dev/null
echo "API healthy: /collections 200, /openapi.json 200"

echo "=== step 4: TiTiler pairing (pattern 05) ==="
bash "$EXAMPLES_DIR/05-titiler-pairing/pair.sh"

echo "=== full workflow: all steps passed (design expectation) ==="
