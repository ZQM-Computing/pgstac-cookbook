# 02 — Ingest: Collections, Items, and Bulk Load

> Status: design-only, gate 1 target. This pattern has not run.
> Exact SQL function behavior, error text, and timings are to
> confirm at validation against a live pgSTAC database.

## What it demonstrates

Ingesting one collection and three synthetic items into pgSTAC with
the `pgstac.create_collection` / `pgstac.create_item` SQL functions,
then bulk-loading 20 more items in a loop. The pattern also shows the
duplicate-ingest failure and the count queries that prove what landed.

## Prerequisites + versions

- Postgres with PostGIS and pgSTAC **0.10.0** installed via migration
  SQL (there is no `.control` extension file in the source; see the
  `01-install` pattern, implemented separately in this repo).
- `psql` client; database connection addressed only as
  `<PGSTAC_DSN>` (placeholder — never a real credential).
- Fleet grounding (design context only, not a validation claim):
  pgSTAC 0.10.0 on the fleet holds 26 tables and 186 functions.
  Postgres version for the validation run: to confirm at validation.

## Steps

1. Set the connection placeholder at the top of `run.sh`.
2. Ingest the collection and items:

   ```bash
   bash run.sh
   ```

   This runs `ingest.sql` (1 collection + 3 items), then `bulk.sql`
   (20 generated items), then the verification counts.
3. Confirm the counts: 1 collection, 23 items.

## Expected output

- `ingest.sql`: collection `synthetic-demo` created, 3 items created.
- `bulk.sql`: 20 items created (`synthetic-demo-004` … `-023`).
- Verification queries: `collections = 1`, `items = 23` for the
  synthetic collection (exact query output shape: to confirm at
  validation — the count statements below are the design expectation,
  not a recorded run).

## Failure behavior

- Re-running `ingest.sql` unchanged: pgSTAC rejects the duplicate
  collection/item (exact error text to confirm at validation).
  Recovery is to delete the synthetic collection and re-run, or to
  ingest under a new collection id — never to edit the production
  catalog in place to make room.
- `psql` connection failure: the script aborts before any ingest
  (`set -euo pipefail`); check `<PGSTAC_DSN>` and that the database
  has pgSTAC installed (pattern 01).
- Items reference only synthetic geometries around an arbitrary
  origin (lon 0, lat 0 area) — not a real place, not real imagery.

## To confirm at validation

- Exact `create_collection` / `create_item` return values and
  duplicate-error text for pgSTAC 0.10.0.
- Count-query results against a live pgSTAC 0.10.0 database.
- Whether `pypgstac load` (CLI) is also installed in the validation
  environment, as an alternative ingest path worth documenting.
