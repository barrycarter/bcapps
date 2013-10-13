-- goal for madis.db which may replace metarnew.db

-- most observations DO include relative humidity, but that's
-- redundant (can be calculated from temperature and dewpoint), so I
-- don't include it below

CREATE TABLE madis (
 type, -- type, as defined by MADIS
 id, -- id, as defined by MADIS
 name, -- descriptive name of station
 latitude DOUBLE, -- in decimal degrees -90..+90
 longitude DOUBLE, -- in decimal degrees -180..+180
 elevation DOUBLE, -- in feet above sealevel
 temperature DOUBLE, -- in degrees F
 dewpoint DOUBLE, -- in degrees F
 pressure DOUBLE, -- in inches of Hg (~30.00 is "normal")
 time, -- time of observation as "YYYY-MM-DD HH:MM:SS" UTC
 winddir DOUBLE, -- wind direction, in degrees, 0..360
 windspeed DOUBLE, -- in miles per hour
 gust DOUBLE, -- gust speed in miles per hour
 cloudcover TEXT,
 events TEXT,
 observation TEXT, -- the full text of the observation
 source TEXT, -- the data source
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 comments TEXT
);

CREATE TABLE madis_now (
 type, -- type, as defined by MADIS
 id, -- id, as defined by MADIS
 name, -- descriptive name of station
 latitude DOUBLE, -- in decimal degrees -90..+90
 longitude DOUBLE, -- in decimal degrees -180..+180
 elevation DOUBLE, -- in feet above sealevel
 temperature DOUBLE, -- in degrees F
 dewpoint DOUBLE, -- in degrees F
 pressure DOUBLE, -- in inches of Hg (~30.00 is "normal")
 time, -- time of observation as "YYYY-MM-DD HH:MM:SS" UTC
 winddir DOUBLE, -- wind direction, in degrees, 0..360
 windspeed DOUBLE, -- in miles per hour
 gust DOUBLE, -- gust speed in miles per hour
 cloudcover TEXT,
 events TEXT,
 observation TEXT, -- the full text of the observation
 source TEXT, -- the data source
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 comments TEXT
);

-- for madis, only one report from a given station at a given time
CREATE UNIQUE INDEX i1 ON madis(type, id, time);

-- for madis_now, newer observations replace older ones
CREATE UNIQUE INDEX i2 ON madis_now(type, id);
