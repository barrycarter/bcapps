-- buoy tables added 29 Oct 2011

CREATE TABLE buoy ( 
STN, LAT, LON, YYYY, MM, DD, hh, minute, WDIR, WSPD, GST, WVHT, DPD, APD,
MWD, PRES, PTDY, ATMP, WTMP, DEWP, VIS, TIDE
);

-- no duplicate reports
CREATE UNIQUE INDEX i3 ON buoy(STN,YYYY,MM,DD,hh,mm);

-- same thing, but only latest observation per buoy
CREATE TABLE buoy_now ( 
STN, LAT, LON, YYYY, MM, DD, hh, minute, WDIR, WSPD, GST, WVHT, DPD, APD,
MWD, PRES, PTDY, ATMP, WTMP, DEWP, VIS, TIDE
);
CREATE UNIQUE INDEX i4 ON buoy_now(STN);

-- revision below 27 Oct 2011 based on
-- http://weather.aero/dataserver_current/cache/metars.cache.csv

-- sky_cover and cloud_base_ft_agl appear 3 times in CSV, reducing to
-- one below; will store greatest sky_cover and lowest cloud base

CREATE TABLE metar (
raw_text, station_id, observation_time, latitude, longitude, temp_c,
dewpoint_c, wind_dir_degrees, wind_speed_kt, wind_gust_kt,
visibility_statute_mi, altim_in_hg, sea_level_pressure_mb, corrected,
auto, auto_station, maintenance_indicator_on, no_signal,
lightning_sensor_off, freezing_rain_sensor_off,
present_weather_sensor_off, wx_string, sky_cover, cloud_base_ft_agl,
flight_category, three_hr_pressure_tendency_mb,
maxT_c, minT_c, maxT24hr_c, minT24hr_c, precip_in, pcp3hr_in,
pcp6hr_in, pcp24hr_in, snow_in, vert_vis_ft, metar_type, elevation_m,
timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- duplicate station_id and time? replace existing results!
CREATE UNIQUE INDEX i1 ON metar(station_id, observation_time);

-- same thing, but only keep latest observation for each station

CREATE TABLE metar_now (
raw_text, station_id, observation_time, latitude, longitude, temp_c,
dewpoint_c, wind_dir_degrees, wind_speed_kt, wind_gust_kt,
visibility_statute_mi, altim_in_hg, sea_level_pressure_mb, corrected,
auto, auto_station, maintenance_indicator_on, no_signal,
lightning_sensor_off, freezing_rain_sensor_off,
present_weather_sensor_off, wx_string, sky_cover, cloud_base_ft_agl,
flight_category, three_hr_pressure_tendency_mb,
maxT_c, minT_c, maxT24hr_c, minT24hr_c, precip_in, pcp3hr_in,
pcp6hr_in, pcp24hr_in, snow_in, vert_vis_ft, metar_type, elevation_m,
timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX i2 ON metar_now(station_id);

-- SQLite3 (thus untyped) table to hold "all" weather observations

CREATE TABLE weather (
 type, -- one of METAR, SHIP, BUOY, SYNOP (are there others?)
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
 type, -- one of METAR, SHIP, BUOY, SYNOP
 id, -- METAR/SHIP code or BUOY id
 latitude, -- in decimal degrees -90..+90
 longitude, -- in decimal degrees -180..+180
 cloudcover, -- in 1/8ths, so 1..8
 temperature, -- in degrees F
 dewpoint, -- in degrees F
 pressure, -- in inches of Hg (~30.00 is "normal")
 winddir, -- wind direction, in degrees, 0..360
 windspeed, -- in miles per hour
 gust, -- gust speed in miles per hour
 time, -- "YYYY-MM-DD HH:MM:SS"
 observation, -- the entire raw observation
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 comment
);

CREATE UNIQUE INDEX i2 ON nowweather(type, id);
