# Install and verify pgSTAC

This example applies a pinned pgSTAC migration target to a PostgreSQL database and checks that the expected schema, core tables, and database functions exist. It deliberately does not install or configure an HTTP API; pgSTAC is the database schema/function layer, while an API such as stac-fastapi-pgstac is a separate service.

## Requirements

- PostgreSQL 13 or newer
- PostGIS 3 or newer and support for required extensions (the migration installs what it can; the database host must provide the extension packages)
- Python 3.11+ and `pypgstac[migrations]==0.10.0`
- PostgreSQL client tools (`psql`)
- A database URL and a database role with privileges required to install extensions, roles, and pgSTAC objects on a fresh database

For a local disposable test database, use the CI workflow's PostGIS service or an isolated container. Do not point this example at production until backup/restore and privilege boundaries have been reviewed.

## Install the migration tool

Use a virtual environment so the pinned dependency does not change the host Python environment:

```bash
python -m venv .venv
. .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install 'pypgstac[migrations]==0.10.0' 'psycopg[binary]==3.2.9'
```

On Windows, activate the virtual environment with `.venv\\Scripts\\Activate.ps1` in PowerShell. The example script itself requires Bash and `psql`.

## Run

Set the connection URL for the verification query and the standard PostgreSQL environment variables used by the legacy `pypgstac migrate` command. Use shell quoting and a secret manager where appropriate; avoid putting credentials into committed files or shell history.

```bash
export DATABASE_URL='postgresql://postgres:local-only-password@localhost:5432/postgres'
export PGHOST=localhost PGPORT=5432 PGUSER=postgres PGDATABASE=postgres PGPASSWORD='local-only-password'
export PGSTAC_VERSION=0.10.0
bash examples/01-install/install-and-verify.sh
```

The migration command applies the requested version using `pypgstac`. The follow-up SQL check fails if the `pgstac` schema, `collections`, `items`, or database functions are missing. It reports structural presence only.

## What this does not prove

A successful run is not proof of a functioning STAC API, valid Collection/Item ingest, search correctness, query performance, restore readiness, network isolation, or production security. Those need separate executable patterns and tests. API deployment is planned as a later pattern.
