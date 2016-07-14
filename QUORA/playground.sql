-- combines the temperatures.db created by bc-moderate-temperature.m
-- with the staions.db to give proper names to the stations and run some
-- checks

-- start with: sqlite3 temperatures.db

ATTACH DATABASE "stations.db" AS stations;

CREATE TABLE jointable AS
SELECT metar, city, state, country, latitude, longitude, elevation
FROM stations.stations UNION SELECT "WMO"||wmobs AS metar, city,
state, country, latitude, longitude, elevation FROM stations.stations;

-- the below works, and renames duplicate columns as latitude:1 for example
CREATE TABLE temp2 AS
SELECT * FROM temperatures t LEFT JOIN jointable j ON (t.station = j.metar);

SELECT * FROM temp2 WHERE metar IS NULL LIMIT 10;





