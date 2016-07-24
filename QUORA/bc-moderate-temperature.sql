-- the SQL to import station data and metadata

-- the below imports ghcnd-stations.txt

-- I will drop this table later, since I don't need data for most stations

-- work below must be done in untarred ghcnd_all directory after
-- running ../WEATHER/bc-get-hilo.pl output to extremes.txt

CREATE TABLE statns (
 cc TEXT, code TEXT, latitude DOUBLE, longitude DOUBLE, elevation DOUBLE,
 state TEXT, name TEXT, wmo INT
);

.separator "\t"
.import ghcnd-stations.tsv statns

CREATE TABLE states (code TEXT, name TEXT);
.separator "\t"
.import ghcnd-states.tsv states

-- perl -pnle 's/ /\t/;s/\s*$//' ghcnd-countries.txt > ! ghcnd-countries.csv
CREATE TABLE countries (code TEXT, name TEXT);
.separator "\t"
.import ghcnd-countries.csv countries

CREATE TABLE extemp (
 code TEXT,
 min0 DOUBLE, min1 DOUBLE, min2 DOUBLE, min5 DOUBLE,
 max95 DOUBLE, max98 DOBULE, max99 DOUBLE, max100 DOUBLE,
 lowvals INT, highvals INT
);

.separator ","
.import extremes.txt extemp

-- with those preliminaries out of the way, we now create the table we
-- actually need

-- SELECT * FROM extemp e 
-- LEFT JOIN statns s ON (e.code = s.code) 
-- LEFT JOIN states st ON (s.state = st.code)
-- LEFT JOIN countries c ON (s.cc = c.code)
-- LIMIT 20;

CREATE TABLE extremes AS
SELECT e.code,
 min0/10 AS min0,
 min1/10 AS min1,
 min2/10 AS min2, 
 min5/10 AS min5,
 max95/10 AS max95, 
 max98/10 AS max98,
 max99/10 AS max99,
 max100/10 AS max100,
 lowvals, highvals, latitude, longitude, elevation, s.name, st.name AS state,
 c.name AS country, wmo
 FROM extemp e 
 LEFT JOIN statns s ON (e.code = s.code) 
 LEFT JOIN states st ON (s.state = st.code)
 LEFT JOIN countries c ON (s.cc = c.code)
;

CREATE VIEW extremesf AS
 SELECT code, 
ROUND(min0*1.8+32,1) AS min0, ROUND(min1*1.8+32,1) AS min1,
ROUND(min2*1.8+32,1) AS min2, ROUND(min5*1.8+32,1) AS min5,
ROUND(max95*1.8+32,1) AS max95, ROUND(max98*1.8+32,1) AS max98,
ROUND(max99*1.8+32,1) AS max99, ROUND(max100*1.8+32,1) AS max100,
latitude, longitude, elevation, 
name||COALESCE(", "||state,"")||", "||country AS Location
FROM extremes;

DROP TABLE statns;
DROP TABLE countries;
DROP TABLE states;
DROP TABLE extemp;
VACUUM;

