-- this is an attempt to create tables (not views) from the SELECT
-- statements mentioned in the project.mml file used by OSM standard tile
-- servesr to serve tiles; the idea is that the tables required to create
-- tiles will be smaller than the entire postgresql database; of course,
-- this could be very wrong

-- below is for zoom levels 5-9



CREATE TABLE test0001 AS 

        (SELECT way, way_pixels, COALESCE(wetland, landuse, "natural")
        AS feature FROM (SELECT way, ('landuse_' || (CASE WHEN landuse
        IN ('forest', 'farmland', 'residential', 'commercial',
        'retail', 'industrial', 'meadow', 'grass', 'village_green',
        'vineyard', 'orchard') THEN landuse ELSE NULL END)) AS
        landuse, ('natural_' || (CASE WHEN "natural" IN ('wood',
        'sand', 'scree', 'shingle', 'bare_rock', 'heath', 'grassland',
        'scrub') THEN "natural" ELSE NULL END)) AS "natural",
        ('wetland_' || (CASE WHEN "natural" IN ('wetland', 'mud') THEN
        (CASE WHEN "natural" IN ('mud') THEN "natural" ELSE
        tags->'wetland' END) ELSE NULL END)) AS wetland,
        way_area/NULLIF(POW(!scale_denominator!*0.001*0.28,2),0) AS
        way_pixels, way_area FROM planet_osm_polygon WHERE (landuse IN
        ('forest', 'farmland', 'residential', 'commercial', 'retail',
        'industrial', 'meadow', 'grass', 'village_green', 'vineyard',
        'orchard') OR "natural" IN ('wood', 'wetland', 'mud', 'sand',
        'scree', 'shingle', 'bare_rock', 'heath', 'grassland',
        'scrub')) AND way_area >
        0.01*!pixel_width!::real*!pixel_height!::real AND building IS
        NULL ) AS features ORDER BY way_area DESC, feature ) AS
        landcover_low_zoom

;

-- ok, these queries appear to contain parameters like
-- !scale_denominator! and !pixel_width! and !pixel_height!





