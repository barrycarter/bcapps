-- for MySQL version of madis db

CREATE TABLE madis (
 oid INT UNSIGNED NOT NULL AUTO_INCREMENT,
 INDEX(oid),
 type TEXT, -- type, as defined by MADIS
 id TEXT, -- id, as defined by MADIS
 name TEXT, -- descriptive name of station
 latitude DOUBLE, -- in decimal degrees -90..+90
 longitude DOUBLE, -- in decimal degrees -180..+180
 elevation DOUBLE, -- in feet above sealevel
 temperature DOUBLE, -- in degrees F
 dewpoint DOUBLE, -- in degrees F
 pressure DOUBLE, -- in inches of Hg (~30.00 is "normal")
 time DATETIME, -- time of observation as "YYYY-MM-DD HH:MM:SS" UTC
 winddir DOUBLE, -- wind direction, in degrees, 0..360
 windspeed DOUBLE, -- in miles per hour
 gust DOUBLE, -- gust speed in miles per hour
 cloudcover TEXT,
 events TEXT,
 observation TEXT, -- the full text of the observation
 source TEXT, -- the data source
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 parser TEXT, -- program that parsed this data
 autocomment TEXT, -- comments made by programs
 comments TEXT
);

-- for madis, only one report from a given station at a given time
-- this max length +1 from when I queried sqlite3 db
CREATE UNIQUE INDEX i1 ON madis(type(12), id(8), time);

-- below helps with sorting
CREATE INDEX i4 ON madis(id(8));

-- covering index for nagios query
CREATE INDEX i5 ON madis(source(60),timestamp);

-- below is in stations.db, but also in madis for joins
CREATE TABLE stations ( 
 metar TEXT,
 wmobs INT, 
 city TEXT, 
 state TEXT, 
 country TEXT, 
 latitude DOUBLE, 
 longitude DOUBLE, 
 elevation DOUBLE,
 source TEXT 
);

CREATE INDEX i_metar ON stations(metar(6));
