-- using MySQL spatial relation functions, testing first

CREATE TABLE nyc_neighbourhoods (name TEXT, boroname TEXT, geom
geometry);

INSERT INTO nyc_neighbourhoods VALUES ('Carroll Hills', 'Brooklyn',
'POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))');

-- https://mysqlserverteam.com/mysql-5-7-and-gis-an-example/

SET @g = 'POLYGON(50.866753 5.686455, 50.859819 5.708942, 50.851475
5.722675, 50.841611 5.720615, 50.834023 5.708427, 50.840744 5.689373,
50.858735 5.673923, 50.866753 5.686455)';

INSERT INTO zone SET zoneShape = PolygonFromText(@g)


SET @g = 'POLYGON((50.866753 5.686455, 50.859819 5.708942, 50.851475
5.722675, 50.841611 5.720615, 50.834023 5.708427, 50.840744 5.689373,
50.858735 5.673923, 50.866753 5.686455))';

SET @a = 'POINT(-106.5 35)';

SELECT PointFromText(@a);

SELECT ST_Distance(PointFromText(@a), PolygonFromText(@g));

above works!!!

SELECT ST_Distance(
 PointFromText('POINT(-106 35)'),
 PointFromText('POINT(-105 35)')
);

SELECT ST_Distance(
 PointFromText('POINT(-106 90)'),
 PointFromText('POINT(-105 90)')
);

both above are 1, hmmmmm, suggesting 2D

SELECT ST_Distance(
 ST_TRANSFORM(PointFromText('POINT(-106 35)'), 4269),
 ST_TRANSFORM(PointFromText('POINT(-105 35)'), 4269)
);



So far the SRID property is just a dummy in MySQL, it is stored as part of a geometries meta data but all actual calculations ignore it and calculations are done assuming Euclidean (planar) geometry.

So ST_Transform would not really do anything at this point anyway.

I think the same is still true for MariaDB, at least the knowldege base page for the SRID() function still says so:

https://mariadb.com/kb/en/mariadb/documentation/gis-functionality/geometry-properties/srid/

    # Geographic Functions #

(* and now... postgresql/postgis *)







