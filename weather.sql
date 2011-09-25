-- SQLite3 (thus untyped) table to hold "all" weather observations

CREATE TABLE weather (
 type, -- one of METAR, SHIP, BUOY, (may add SYNOP later)
 id, -- METAR/SHIP code or BUOY id
 latitude, -- in decimal degrees -90..+90
 longitude, -- in decimal degrees -180..+180
 cloudcover, -- in 1/8ths, so 1..8
 temperature, -- in degrees F
 dewpoint, -- in degrees F
 pressure, -- in inches of Hg (~30.00 is "normal")
 time, -- "YYYY-MM-DD HH:MM:SS"
 winddir, -- wind direction, in degrees, 0..360
 windspeed, -- in miles per hour
 gust, -- gust speed in miles per hour
 observation, -- the entire raw observation
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 comment
);

CREATE UNIQUE INDEX i1 ON weather(type, id, time);

-- below exactly the same, but only one obs per station (presumably
-- the most recent one)

CREATE TABLE nowweather (
 type, -- one of METAR, SHIP, BUOY, (may add SYNOP later)
 id, -- METAR/SHIP code or BUOY id
 latitude, -- in decimal degrees -90..+90
 longitude, -- in decimal degrees -180..+180
 cloudcover, -- in 1/8ths, so 1..8
 temperature, -- in degrees F
 dewpoint, -- in degrees F
 pressure, -- in inches of Hg (~30.00 is "normal")
 time, -- "YYYY-MM-DD HH:MM:SS"
 winddir, -- wind direction, in degrees, 0..360
 windspeed, -- in miles per hour
 gust, -- gust speed in miles per hour
 observation, -- the entire raw observation
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 comment
);

CREATE UNIQUE INDEX i2 ON nowweather(type, id);
