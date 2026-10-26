# pgSTAC Cookbook

<!-- ZQM-START -->
<!-- markdownlint-disable MD033 -->
<p align="center">
  <strong>ZQM Computing — Geospatial Engineering & Scientific Computing</strong><br>
  <a href="https://github.com/ZQM-Computing">ZQM Computing</a>
</p>
<!-- markdownlint-enable MD033 -->
<!-- ZQM-END -->

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

A **pgSTAC cookbook** for running a STAC catalog inside PostGIS and serving it with stac-fastapi. Patterns are drawn from the ZQM fleet's running pgSTAC 0.10.0 installs (migration-SQL install, 26 tables and 186 functions) and stac-fastapi.pgstac 7.1.0 APIs (verified `/collections` and `/openapi.json` on Node-1 and Node-3). It is intended for geospatial data engineers who catalog imagery and need a queryable API over it; validate each pattern against your own data, software versions, and operating environment before adopting it.

## Repository role and status

**Status:** Active, public — first executable install pattern implemented. CI targets pgSTAC 0.9.11 using the matching published migration tool and verifies core schema objects; the live integration result is established by the workflow run, not by documentation alone.

**What this repository is:** pgSTAC patterns — catalog installation, collection/item ingest, search, and stac-fastapi deployment.

**What it contributes:** Part of the ZQM Computing geospatial portfolio. The umbrella index for the series is [geospatial-cookbooks](https://github.com/ZQM-Computing/geospatial-cookbooks).

**Standing:** This repository is maintained independently. Automated checks cover only the paths and environments configured in its workflows; they do not establish production readiness or operational certification.

## Who this is for

Geospatial data engineers and platform builders who run a STAC API against their own Postgres instead of a hosted catalog, and who want ingest and search patterns they can rerun.

## Prerequisites

- Postgres with PostGIS (see [postgis-cookbook](https://github.com/ZQM-Computing/postgis-cookbook))
- pgSTAC 0.10.0 (installed via migration SQL — there is no `.control` extension file in the source)
- stac-fastapi.pgstac 7.1.0 (Python virtual environment, served with uvicorn)
- Python 3.11+
- Bash

## Patterns

| # | Example | Status | What it demonstrates |
|---|---------|--------|----------------------|
| 01 | [01-install](examples/01-install/README.md) | Implemented | Apply pgSTAC 0.9.11 migrations to a target database and verify the schema, core collections/items tables, and function presence. |
| 02 | `02-ingest` | Planned | Ingesting collections and items, including bulk ingest patterns |
| 03 | `03-search` | Planned | STAC search: bbox, datetime, and query filters against the API |
| 04 | `04-fastapi-deploy` | Planned | Deploying stac-fastapi.pgstac as a service, with settings and docs endpoints |
| 05 | `05-titiler-pairing` | Planned | Pairing the catalog with TiTiler tile and statistics endpoints (see titiler-cookbook) |
| 06 | `06-full-workflow` | Planned | End-to-end: install → ingest → search → serve |

## Repository layout

```text
pgstac-cookbook/
├── examples/          # pattern passes, landing in follow-up work
├── README.md
└── LICENSE
```

## Roadmap

- First pattern pass: install + ingest (01, 02)
- Second pass: search + deployment (03, 04)
- Pairing pass (05) with titiler-cookbook, once real imagery ingest is proven on the fleet

## Contributing

A contributing guide lands with the first pattern pass. Report security issues to <zqmcomputing@gmail.com> — please do not open a public issue for those.

## More from this series

- [stac-cookbook](https://github.com/ZQM-Computing/stac-cookbook) — STAC catalog creation, item validation, search API, bulk ops
- [titiler-cookbook](https://github.com/ZQM-Computing/titiler-cookbook) — Dynamic map tiles, STAC endpoints, and cloud-native raster serving from COGs
- [postgis-cookbook](https://github.com/ZQM-Computing/postgis-cookbook) — PostGIS SQL examples: spatial indexing, joins & KNN, SRID management, vector tiles, data quality, partitioning
