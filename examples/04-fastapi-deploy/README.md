# 04 — Deploy: stac-fastapi.pgstac as a Service

> Status: design-only, gate 1 target. This pattern has not run.
> Exact settings names, startup errors, and service-manager steps
> are to confirm at validation against a live deployment.

## What it demonstrates

Deploying stac-fastapi.pgstac **7.1.0** over a pgSTAC **0.10.0**
database: a Python virtual environment, the settings the app
requires, a foreground uvicorn run for smoke-testing, and a Windows
service sketch (NSSM) matching the fleet's service pattern. Health
checks are `/collections` and `/openapi.json` — the two endpoints
verified on the fleet.

## Prerequisites + versions

- Python 3.11+; `stac-fastapi.pgstac` **7.1.0** (pip).
- A pgSTAC 0.10.0 database (pattern 01's install; data from
  pattern 02 is optional for the smoke test).
- uvicorn (version: to confirm at validation).
- Fleet grounding (design context only): on Node-3 the service runs
  under NSSM on port 8001 with `DOCS_URL`/`OPENAPI_URL` set, because
  in that build `/docs` 404s without them; the app is built with
  `create_app --factory`. A Postgres password setting is required
  by the app's settings in that deployment — see `env.example`.

## Steps

1. Copy `env.example` to `.env` and fill in placeholders only
   (never commit a real credential; `.env` is not shipped here).
2. Create the venv and install:

   ```bash
   bash deploy.sh install
   ```
3. Smoke-test in the foreground:

   ```bash
   bash deploy.sh run
   ```

   Then, from another shell: `curl <STAC_API_URL>/collections`
   (expect 200 with a collections list) and
   `curl <STAC_API_URL>/openapi.json` (expect 200).
4. For a persistent service (Windows, fleet pattern): use the NSSM
   sketch in `deploy.sh` (`service` subcommand) with the same
   environment file, pointed at your own paths — the sketch uses
   placeholders, not fleet paths.

## Expected output

- `install` completes with `stac-fastapi.pgstac 7.1.0` importable
  from the venv.
- Foreground `run` serves on the configured port; `/collections`
  returns 200 and `/openapi.json` returns 200.
- `/docs` behavior depends on deployment: with `DOCS_URL` and
  `OPENAPI_URL` set as in `env.example`, docs serve; without them,
  this build 404s on `/docs` while the API itself stays healthy.
  That distinction is fleet-observed on Node-3, not a defect to
  "fix" by reinstalling.

## Failure behavior

- Missing required settings (notably the Postgres password setting):
  the app fails at startup — read the startup log, do not guess
  and re-run with different ports.
- Port already bound: uvicorn exits with a bind error; pick a free
  port in `.env` (the fleet's Node-3 choice, 8001, is design context,
  not a requirement).
- API answers but `/collections` is empty: the service is healthy
  and the catalog is empty — ingest with pattern 02; do not restart
  the service to "fix" empty data.

## To confirm at validation

- Exact settings/env names for stac-fastapi.pgstac 7.1.0 (including
  the Postgres password setting's name and the docs URL settings).
- uvicorn version and the exact `create_app` factory invocation.
- NSSM command spelling on the validation node (service name and
  paths are operator choices, not facts in this pattern).
- Whether `/docs` serves with the documented settings on the
  validation build.
