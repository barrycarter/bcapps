-- goal for madis.db which may replace metarnew.db

-- most observations DO include relative humidity, but that's
-- redundant (can be calculated from temperature and dewpoint), so I
-- don't include it below

CREATE TABLE madis (
 type TEXT, -- type, as defined by MADIS
 id TEXT, -- id, as defined by MADIS
 name TEXT, -- descriptive name of station
 latitude DOUBLE PRECISION, -- in decimal degrees -90..+90
 longitude DOUBLE PRECISION, -- in decimal degrees -180..+180
 elevation DOUBLE PRECISION, -- in feet above sealevel
 temperature DOUBLE PRECISION, -- in degrees F
 dewpoint DOUBLE PRECISION, -- in degrees F
 pressure DOUBLE PRECISION, -- in inches of Hg (~30.00 is "normal")
 time TEXT, -- time of observation as "YYYY-MM-DD HH:MM:SS" UTC
 winddir DOUBLE PRECISION, -- wind direction, in degrees, 0..360
 windspeed DOUBLE PRECISION, -- in miles per hour
 gust DOUBLE PRECISION, -- gust speed in miles per hour
 cloudcover TEXT,
 events TEXT,
 observation TEXT, -- the full text of the observation
 source TEXT, -- the data source
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 comments TEXT
);

-- SQLite3 won't let you add comments to added columns, but these are:
-- parser = program that parsed this data
-- autocomment = comments made by programs
ALTER TABLE madis ADD parser TEXT;
ALTER TABLE madis ADD autocomment TEXT;

-- for madis, only one report from a given station at a given time
CREATE UNIQUE INDEX i1 ON madis(type, id, time);

-- for mysql only:
-- CREATE UNIQUE INDEX i1 ON madis(type(50), id(50), time(50));

-- below helps with sorting
CREATE INDEX i4 ON madis(id);

-- covering index for nagios query
CREATE INDEX i5 ON madis(source,timestamp);

CREATE VIEW madis_now AS
SELECT * FROM madis m WHERE time = 
 (SELECT MAX(time) FROM madis WHERE id=m.id AND type=m.type)
AND type NOT IN ('MOS') AND time > DATETIME(CURRENT_TIMESTAMP, '-3 hour');

-- below is in stations.db, but also in madis for joins
CREATE TABLE stations ( 
 metar TEXT,
 wmobs INT, 
 city TEXT, 
 state TEXT, 
 country TEXT, 
 latitude DOUBLE PRECISION, 
 longitude DOUBLE PRECISION, 
 elevation DOUBLE PRECISION,
 source TEXT 
);

CREATE INDEX i_metar ON stations(metar);

-- if unique index i1 breaks, this helps restore it
SELECT m1.rowid FROM madis m1 JOIN madis m2 ON (m1.type = m2.type AND
m1.id = m2.id AND m1.time = m2.time AND m1.rowid < m2.rowid);

