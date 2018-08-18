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




