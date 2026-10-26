# 05 — TiTiler Pairing: Catalog Item to Tiles and Statistics

> Status: design-only, gate 1 target. This pattern has not run.
> Exact TiTiler endpoint spellings and error bodies are to confirm
> at validation (see the titiler-cookbook 03 open questions, which
> this pattern shares).

## What it demonstrates

Pairing the pgSTAC catalog with TiTiler: take an item from the
catalog (pattern 03's search), follow its COG asset href into
TiTiler's tile and statistics endpoints, and cross-check the
catalog-native `/stac/*` path against the direct COG path. The point
of the pattern is the handoff — catalog discovery on one side,
raster serving on the other — not either service alone.

## Prerequisites + versions

- A stac-fastapi.pgstac **7.1.0** API holding at least one item
  whose assets include a COG reachable by TiTiler (patterns 02–03).
  The synthetic items in pattern 02 carry no COG asset by design,
  so this pattern takes `<COG_URL>` as an input: point it at a COG
  you own, or at an item whose asset href TiTiler can read.
- TiTiler **0.25.0** (fleet: app entry
  `titiler.application.main:app`; `/` and `/redoc` verified on
  Node-3 port 8000 — this pattern addresses TiTiler only as
  `<TITILER_URL>`).
- `curl` and `jq` (jq version: to confirm at validation).

## Steps

1. Set `<STAC_API_URL>`, `<TITILER_URL>`, and `<COG_URL>` at the top
   of `pair.sh`. (Alternatively, set `ITEM_ID` to an item whose
   asset href you want the script to follow instead of `<COG_URL>` —
   see the script's notes.)
2. Run:

   ```bash
   bash pair.sh
   ```

   The script fetches the item (or uses `<COG_URL>` directly), then
   calls TiTiler `/cog/info`, one `/cog/tiles/{z}/{x}/{y}.png` tile,
   and `/cog/statistics`, then the catalog-native `/stac/info`
   variant for the same item.

## Expected output

- `/cog/info` returns band descriptions, data type, and bounds for
  the COG.
- The tile request returns a PNG (HTTP 200) for a tile inside the
  COG's bounds.
- `/cog/statistics` returns per-band statistics (min/max/mean
  shape — exact field names to confirm at validation).
- The `/stac/*` variant returns the same COG's info through the
  catalog path, demonstrating both routes reach the same raster.
- Exact response bodies are to confirm at validation; the shapes
  above are the design expectation, not a recorded run.

## Failure behavior

- Asset href unreachable by TiTiler: TiTiler returns an error for
  the info/tile calls (exact code to confirm at validation). Fix
  the COG's reachability — do not re-ingest the catalog item.
- Item with no COG asset: the script exits with a clear message
  naming the item, rather than calling TiTiler with an empty URL.
- Tile outside the COG's bounds: expect an empty/error tile, not a
  valid image — check `/cog/bounds` first (the script prints it
  via `/cog/info`).

## To confirm at validation

- Exact `/stac/*` endpoint spellings and parameters for TiTiler
  0.25.0 (shared open question with titiler-cookbook 03).
- `/cog/statistics` response field names and windowed-statistics
  parameters.
- How a COG must be hosted so both TiTiler and the catalog can
  reach it (shared open question with titiler-cookbook 06).
- Tile coordinates: defaults here are z/x/y 0/0/0 placeholders;
  adjust from real `/cog/bounds` output at validation.
