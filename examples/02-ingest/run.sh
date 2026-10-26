#!/usr/bin/env bash
# 02-ingest runner. Set PGSTAC_DSN to a placeholder-free DSN for a
# pgSTAC 0.10.0 database you own (never commit a real credential).
# Design-only: counts below are the design expectation, not a run.
set -euo pipefail

PGSTAC_DSN="${PGSTAC_DSN:-<PGSTAC_DSN>}"
if [[ "$PGSTAC_DSN" == "<PGSTAC_DSN>" ]]; then
  echo "Set PGSTAC_DSN first (a DSN for a pgSTAC 0.10.0 database)." >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
psql "$PGSTAC_DSN" -v ON_ERROR_STOP=1 -f "$SCRIPT_DIR/ingest.sql"
psql "$PGSTAC_DSN" -v ON_ERROR_STOP=1 -f "$SCRIPT_DIR/bulk.sql"

echo "--- verification (expect: 1 collection, 23 items) ---"
psql "$PGSTAC_DSN" -v ON_ERROR_STOP=1 -At -c \
  "SELECT count(*) FROM pgstac.collections WHERE id = 'synthetic-demo';"
psql "$PGSTAC_DSN" -v ON_ERROR_STOP=1 -At -c \
  "SELECT count(*) FROM pgstac.items WHERE collection = 'synthetic-demo';"
