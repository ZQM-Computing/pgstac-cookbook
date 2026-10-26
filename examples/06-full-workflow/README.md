# 06 — Full Workflow: Install → Ingest → Search → Serve

> Status: design-only, gate 1 target. This pattern has not run.
> It chains patterns 02–05; every step's individual open questions
> apply here too, and are not re-listed in full.

## What it demonstrates

The end-to-end pgSTAC story in one script: ingest the synthetic
collection (02), prove it is searchable (03), prove the API is
healthy (04's checks), and prove a catalog item pairs to TiTiler
tiles (05). The script aborts on the first failed step, so a green
run means the whole chain held — not just the last step.

## Prerequisites + versions

- pgSTAC **0.10.0** database + stac-fastapi.pgstac **7.1.0** API +
  TiTiler **0.25.0** (patterns 02–05 prerequisites combined).
- The sibling pattern scripts present in this repo's `examples/`
  directory (02 `run.sh`, 03 `search.sh`, 05 `pair.sh`).
- Environment placeholders: `<PGSTAC_DSN>`, `<STAC_API_URL>`,
  `<TITILER_URL>`, `<COG_URL>` (see patterns 02–05 for what each
  means). No real credential is shipped or committed.

## Steps

1. Set the four placeholders (export them, or edit the top of
   `workflow.sh`).
2. Run:

   ```bash
   bash workflow.sh
   ```

## Expected output (checklist — all must pass)

- [ ] Ingest: 1 collection, 23 items (pattern 02 counts).
- [ ] Search: `/collections` lists `synthetic-demo`; bbox search
  returns a strict subset; no-match search returns 0, not an error.
- [ ] Serve: `/collections` 200 and `/openapi.json` 200 from the API.
- [ ] Pairing: TiTiler `/cog/info` 200, one tile PNG 200,
  `/cog/statistics` 200 for the paired COG.
- Exact bodies/counts are to confirm at validation; the checklist
  above is the design expectation, not a recorded run.

## Failure behavior

- The script uses `set -euo pipefail`: the first failing step stops
  the run and names the step. Fix that step's pattern (02, 03, 04,
  or 05) — do not skip ahead, because later steps depend on earlier
  state (ingested data, a healthy API, a reachable COG).
- Re-running after a partial run: pattern 02's duplicate-ingest
  failure applies (delete the synthetic collection and re-run from
  the top, or start from a fresh database).
- A green run here does not claim gate 3 for any single pattern:
  each pattern's own validation questions still need their own
  recorded runs.

## To confirm at validation

- Everything listed under patterns 02–05, especially: count-query
  table/column names (02), `/search` field names and error codes
  (03), settings names (04), and `/stac/*` spellings plus COG
  hosting (05).
- The node (or nodes) the full chain runs against, and the
  Postgres/PostGIS versions there.
