-- 02-ingest: one synthetic collection + three synthetic items.
-- Run with psql against a pgSTAC 0.10.0 database (see run.sh).
-- Geometries are small squares around an arbitrary origin (lon 0,
-- lat 0 area): synthetic data, not a real place, not real imagery.

SELECT pgstac.create_collection('{
  "type": "Collection",
  "stac_version": "1.0.0",
  "id": "synthetic-demo",
  "description": "Synthetic demo collection for the pgSTAC ingest pattern.",
  "license": "proprietary",
  "extent": {
    "spatial": {"bbox": [[-1, -1, 1, 1]]},
    "temporal": {"interval": [["2026-01-01T00:00:00Z", null]]}
  },
  "links": []
}'::jsonb);

SELECT pgstac.create_item('{
  "type": "Feature",
  "stac_version": "1.0.0",
  "id": "synthetic-demo-001",
  "collection": "synthetic-demo",
  "geometry": {"type": "Polygon", "coordinates": [[[0, 0], [0.01, 0], [0.01, 0.01], [0, 0.01], [0, 0]]]},
  "bbox": [0, 0, 0.01, 0.01],
  "properties": {"datetime": "2026-01-01T00:00:00Z", "eo:cloud_cover": 5},
  "links": [],
  "assets": {}
}'::jsonb);

SELECT pgstac.create_item('{
  "type": "Feature",
  "stac_version": "1.0.0",
  "id": "synthetic-demo-002",
  "collection": "synthetic-demo",
  "geometry": {"type": "Polygon", "coordinates": [[[0.02, 0], [0.03, 0], [0.03, 0.01], [0.02, 0.01], [0.02, 0]]]},
  "bbox": [0.02, 0, 0.03, 0.01],
  "properties": {"datetime": "2026-01-02T00:00:00Z", "eo:cloud_cover": 20},
  "links": [],
  "assets": {}
}'::jsonb);

SELECT pgstac.create_item('{
  "type": "Feature",
  "stac_version": "1.0.0",
  "id": "synthetic-demo-003",
  "collection": "synthetic-demo",
  "geometry": {"type": "Polygon", "coordinates": [[[0, 0.02], [0.01, 0.02], [0.01, 0.03], [0, 0.03], [0, 0.02]]]},
  "bbox": [0, 0.02, 0.01, 0.03],
  "properties": {"datetime": "2026-01-03T00:00:00Z", "eo:cloud_cover": 45},
  "links": [],
  "assets": {}
}'::jsonb);
