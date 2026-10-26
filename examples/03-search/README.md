# 03 — Search: bbox, Datetime, and Query Filters

> Status: design-only, gate 1 target. This pattern has not run.
> Exact response bodies, error codes, and filter field names are to
> confirm at validation against a live stac-fastapi.pgstac API.

## What it demonstrates

STAC search against a stac-fastapi.pgstac API holding the synthetic
collection from pattern 02: listing collections, listing one
collection's items, and POST `/search` with a bbox, a datetime range,
and a query filter (`eo:cloud_cover`). It also shows the two
non-error outcomes that surprise newcomers: an empty result set and
a rejected query.

## Prerequisites + versions

- stac-fastapi.pgstac **7.1.0** serving a pgSTAC **0.10.0** catalog
  that already holds the `synthetic-demo` collection (pattern 02).
- API addressed only as `<STAC_API_URL>` (placeholder). Fleet
  grounding (design context only): on Node-3 the service answers
  `/collections` and `/openapi.json` on port 8001; this pattern does
  not hard-code that port — set the placeholder for your deployment.
- `curl` and `jq` (jq version: to confirm at validation).

## Steps

1. Set `<STAC_API_URL>` at the top of `search.sh`.
2. Run:

   ```bash
   bash search.sh
   ```

   The script calls, in order: `GET /collections`,
   `GET /collections/synthetic-demo/items`, `POST /search` with a
   bbox + datetime window, and `POST /search` with a cloud-cover
   query filter. It prints each response's item count via `jq`.

## Expected output

- `/collections` lists `synthetic-demo` among the collections.
- `/collections/synthetic-demo/items` returns the ingested items
  (23 after pattern 02, design expectation).
- Bbox + datetime search returns the subset whose synthetic
  geometries and datetimes fall inside the window (a strict subset
  of 23 — the window in `search.sh` covers the first items only).
- Cloud-cover query (`eo:cloud_cover < 30`) returns a strict subset
  (the generated items cycle cover 0–99, so roughly a third match).
- Exact JSON field names and counts are to confirm at validation;
  the shapes above are the design expectation, not a recorded run.

## Failure behavior

- Empty result: a valid search with no matches returns a Feature
  Collection with an empty `features` array — that is a successful
  answer, not an error. Do not retry it as a failure.
- Rejected query (bad bbox order, unparseable datetime, unknown
  query field): the API returns an error response. Exact status code
  and error body are to confirm at validation (stac-fastapi returns
  validation errors in the 4xx range); the script prints the body
  rather than swallowing it.
- API unreachable: `curl` fails fast; check `<STAC_API_URL>` and
  that the service from pattern 04 is running — do not re-ingest
  data to "fix" a search failure.

## To confirm at validation

- Exact `/search` request/response field names for this
  stac-fastapi.pgstac build (query extension field spelling,
  pagination token behavior).
- Error status/body for malformed bbox, datetime, and query inputs.
- Whether `/docs` serves in the validation deployment (on Node-3's
  build it 404s unless `DOCS_URL`/`OPENAPI_URL` are set — see
  pattern 04).
