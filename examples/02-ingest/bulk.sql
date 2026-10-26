-- 02-ingest (bulk): 20 generated items in the synthetic collection.
-- Each item gets a small synthetic square; cloud cover cycles so the
-- search pattern (03) can filter on it. IDs: synthetic-demo-004..023.
DO $$
DECLARE
  i int;
  lon float;
  lat float;
  item jsonb;
BEGIN
  FOR i IN 4..23 LOOP
    lon := (i % 5) * 0.02;
    lat := (i / 5) * 0.02;
    item := jsonb_build_object(
      'type', 'Feature',
      'stac_version', '1.0.0',
      'id', format('synthetic-demo-%s', lpad(i::text, 3, '0')),
      'collection', 'synthetic-demo',
      'geometry', jsonb_build_object(
        'type', 'Polygon',
        'coordinates', jsonb_build_array(jsonb_build_array(
          jsonb_build_array(lon, lat),
          jsonb_build_array(lon + 0.01, lat),
          jsonb_build_array(lon + 0.01, lat + 0.01),
          jsonb_build_array(lon, lat + 0.01),
          jsonb_build_array(lon, lat)
        ))
      ),
      'bbox', jsonb_build_array(lon, lat, lon + 0.01, lat + 0.01),
      'properties', jsonb_build_object(
        'datetime', format('2026-01-%sT00:00:00Z', lpad(((i % 28) + 1)::text, 2, '0')),
        'eo:cloud_cover', (i * 7) % 100
      ),
      'links', '[]'::jsonb,
      'assets', '{}'::jsonb
    );
    PERFORM pgstac.create_item(item);
  END LOOP;
END $$;
