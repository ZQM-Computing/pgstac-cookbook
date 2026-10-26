#!/usr/bin/env bash
# 04-fastapi-deploy: venv install + foreground run + NSSM sketch.
# Design-only: settings names and service spellings are to confirm
# at validation. Never commit a real .env.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${VENV_DIR:-$SCRIPT_DIR/venv}"
ENV_FILE="${ENV_FILE:-$SCRIPT_DIR/.env}"

cmd="${1:-help}"
case "$cmd" in
  install)
    python3 -m venv "$VENV_DIR"
    "$VENV_DIR/bin/python" -m pip install "stac-fastapi.pgstac==7.1.0"
    "$VENV_DIR/bin/python" -c "import stac_fastapi.pgstac; print('stac-fastapi.pgstac import OK')"
    ;;
  run)
    if [[ ! -f "$ENV_FILE" ]]; then
      echo "Copy env.example to .env and fill in placeholders first." >&2
      exit 2
    fi
    set -a; . "$ENV_FILE"; set +a
    exec "$VENV_DIR/bin/python" -m uvicorn \
      "stac_fastapi.pgstac.app:create_app" --factory \
      --host "${STAC_HOST:-127.0.0.1}" --port "${STAC_PORT:-8001}"
    ;;
  service)
    cat <<'EOF'
# Windows service sketch (NSSM, fleet pattern) — placeholders only,
# spelling to confirm at validation on the target node:
#   nssm install <SERVICE_NAME> <VENV>\Scripts\python.exe
#   nssm set <SERVICE_NAME> AppParameters "-m uvicorn stac_fastapi.pgstac.app:create_app --factory --host 127.0.0.1 --port 8001"
#   nssm set <SERVICE_NAME> AppEnvironmentExtra <ENV_FILE contents>
#   nssm start <SERVICE_NAME>
# Then verify: curl <STAC_API_URL>/collections (200) and
# curl <STAC_API_URL>/openapi.json (200).
EOF
    ;;
  *)
    echo "usage: bash deploy.sh {install|run|service}" >&2
    exit 2
    ;;
esac
