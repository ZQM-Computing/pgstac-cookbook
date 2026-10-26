#!/usr/bin/env bash
set -Eeuo pipefail

# Install pgSTAC into a disposable or explicitly selected database, then verify
# the resulting schema. The database account must have the privileges required
# by pgstac-migrate (including extension and role creation on a fresh database).
: "${DATABASE_URL:?Set DATABASE_URL to the target PostgreSQL database}"
PGSTAC_VERSION="${PGSTAC_VERSION:-0.9.11}"

if ! command -v pgstac-migrate >/dev/null 2>&1; then
  printf '%s\n' "ERROR: pgstac-migrate is not installed. See the example README." >&2
  exit 127
fi
if ! command -v psql >/dev/null 2>&1; then
  printf '%s\n' "ERROR: psql is required for post-migration verification." >&2
  exit 127
fi

case "$PGSTAC_VERSION" in
  *[!0-9.]*|""|.*|*..*|*.) printf '%s\n' "ERROR: invalid PGSTAC_VERSION: $PGSTAC_VERSION" >&2; exit 2 ;;
esac

printf 'Migrating database to pgSTAC %s...\n' "$PGSTAC_VERSION"
pgstac-migrate migrate --dsn "$DATABASE_URL" --to "$PGSTAC_VERSION"

printf 'Verifying pgSTAC schema and core objects...\n'
psql "$DATABASE_URL" -X -v ON_ERROR_STOP=1 <<'SQL'
DO $verify$
DECLARE
    relation_count integer;
    function_count integer;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'pgstac') THEN
        RAISE EXCEPTION 'pgstac schema was not created';
    END IF;

    IF to_regclass('pgstac.collections') IS NULL THEN
        RAISE EXCEPTION 'pgstac.collections is missing';
    END IF;

    IF to_regclass('pgstac.items') IS NULL THEN
        RAISE EXCEPTION 'pgstac.items is missing';
    END IF;

    SELECT count(*) INTO relation_count
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'pgstac' AND c.relkind IN ('r', 'p', 'v', 'm');

    SELECT count(*) INTO function_count
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'pgstac';

    IF relation_count < 2 THEN
        RAISE EXCEPTION 'pgstac schema has unexpectedly few tables/views: %', relation_count;
    END IF;

    IF function_count < 1 THEN
        RAISE EXCEPTION 'pgstac schema has no functions';
    END IF;

    RAISE NOTICE 'pgstac schema verified: % relations/views, % functions', relation_count, function_count;
END
$verify$;
SQL

printf '%s\n' "Install and structural verification succeeded."
printf '%s\n' "This check does not validate HTTP API behavior, item ingest/search semantics, backups, or production security."
