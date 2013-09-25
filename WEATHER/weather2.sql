-- goal for weather.db which may replace metarnew.db

CREATE TABLE weather (
 type, -- one of METAR, SHIP, BUOY, (may add SYNOP/RAWS later)
 id, -- METAR/SHIP code or BUOY id
 name, -- descriptive name of station
 latitude, -- in decimal degrees -90..+90
 longitude, -- in decimal degrees -180..+180
 cloudcover, -- in 1/8ths, so 1..8
 temperature, -- in degrees F
 dewpoint, -- in degrees F
 events, -- signifigant weather like "light rain"
 pressure, -- in inches of Hg (~30.00 is "normal")
 time, -- time of observation as "YYYY-MM-DD HH:MM:SS" UTC
 winddir, -- wind direction, in degrees, 0..360
 windspeed, -- in miles per hour
 gust, -- gust speed in miles per hour
 observation, -- the full text of the observation
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 comment
);

CREATE TABLE weather_now (
 type, -- one of METAR, SHIP, BUOY, (may add SYNOP/RAWS later)
 id, -- METAR/SHIP code or BUOY id
 name, -- descriptive name of station
 latitude, -- in decimal degrees -90..+90
 longitude, -- in decimal degrees -180..+180
 cloudcover, -- in 1/8ths, so 1..8
 temperature, -- in degrees F
 dewpoint, -- in degrees F
 events, -- signifigant weather like "light rain"
 pressure, -- in inches of Hg (~30.00 is "normal")
 time, -- time of observation as "YYYY-MM-DD HH:MM:SS" UTC
 winddir, -- wind direction, in degrees, 0..360
 windspeed, -- in miles per hour
 gust, -- gust speed in miles per hour
 observation, -- the full text of the observation
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 comment
);

-- for weather, only one report from a given station at a given time
CREATE UNIQUE INDEX i1 ON weather(type, id, time);

-- for weather_now, newer observations replace older ones
CREATE UNIQUE INDEX i2 ON weather_now(type, id);


