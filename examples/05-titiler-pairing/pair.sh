#!/usr/bin/env bash
# 05-titiler-pairing: catalog item -> TiTiler tiles + statistics.
# Design-only: endpoint spellings and response shapes are to
# confirm at validation for TiTiler 0.25.0.
set -euo pipefail

STAC_API_URL="${STAC_API_URL:-<STAC_API_URL>}"
TITILER_URL="${TITILER_URL:-<TITILER_URL>}"
COG_URL="${COG_URL:-<COG_URL>}"
ITEM_ID="${ITEM_ID:-}"
COLLECTION_ID="${COLLECTION_ID:-synthetic-demo}"

for v in STAC_API_URL TITILER_URL; do
  if [[ "${!v}" == "<${v}>" ]]; then echo "Set $v first." >&2; exit 2; fi
done

if [[ -n "$ITEM_ID" ]]; then
  echo "--- item $ITEM_ID (following its first asset href) ---"
  COG_URL="$(curl -fsS "$STAC_API_URL/collections/$COLLECTION_ID/items/$ITEM_ID" \
    | jq -r '.assets | to_entries[0].value.href')"
  echo "asset href: $COG_URL"
fi
if [[ "$COG_URL" == "<COG_URL>" ]] || [[ -z "$COG_URL" ]] || [[ "$COG_URL" == "null" ]]; then
  echo "No COG URL: set COG_URL or ITEM_ID to an item with a COG asset." >&2
  exit 2
fi

echo "--- TiTiler /cog/info ---"
curl -fsS "$TITILER_URL/cog/info?url=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$COG_URL")" | jq .

echo "--- TiTiler one tile (z/x/y 0/0/0 placeholder; adjust from bounds) ---"
curl -fsS -o /tmp/pgstac-pair-tile.png \
  "$TITILER_URL/cog/tiles/0/0/0.png?url=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$COG_URL")"
file /tmp/pgstac-pair-tile.png

echo "--- TiTiler /cog/statistics ---"
curl -fsS "$TITILER_URL/cog/statistics?url=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$COG_URL")" | jq .

echo "--- catalog-native /stac/info variant (same raster, catalog path) ---"
if [[ -n "$ITEM_ID" ]]; then
  curl -fsS "$TITILER_URL/stac/info?url=$STAC_API_URL&collection=$COLLECTION_ID&item=$ITEM_ID" | jq . \
    || echo "(stac variant: endpoint spelling to confirm at validation)"
fi
