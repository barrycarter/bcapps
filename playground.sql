-- queries to extract various quantities from both METAR and BUOY observations

SELECT stn AS id, atmp*1.8+32 AS value, lat AS y, lon AS x FROM
buoy_now WHERE atmp != 'MM' UNION SELECT station_id AS id,
temp_c*1.8+32 AS value, latitude AS y, longitude AS x FROM metar_now
WHERE temp_c != ''















.quit

-- SQLite3 (thus untyped) table to hold "all" weather observations

CREATE TABLE weather (
 type, -- one of METAR, SHIP, BUOY, (may add SYNOP later)
 id, -- METAR/SHIP code or BUOY id
 latitude, -- in decimal degrees -90..+90
 longitude, -- in decimal degrees -180..+180
 cloudcover, -- in 1/8ths, so 1..8
 temperature, -- in degrees F
 dewpoint, -- in degrees F
 events, -- signifigant weather like "light rain"
 pressure, -- in inches of Hg (~30.00 is "normal")
 time, -- "YYYY-MM-DD HH:MM:SS" UTC
 winddir, -- wind direction, in degrees, 0..360
 windspeed, -- in miles per hour
 gust, -- gust speed in miles per hour
 observation, -- the full text of the observation
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 comment
);
