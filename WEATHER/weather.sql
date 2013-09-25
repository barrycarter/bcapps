-- this is just a raw copy of
-- http://schema.metarnew.db.bcinfo3.barrycarter.info/ to start with; not
-- sure how my weather tables got so twisted but working to improve them
-- below

CREATE TABLE buoy (  
STN, LAT, LON, YYYY, MM, DD, hh, minute, WDIR, WSPD, GST, WVHT, DPD, APD, 
MWD, PRES, PTDY, ATMP, WTMP, DEWP, VIS, TIDE 
);
CREATE TABLE buoy_now (  
STN, LAT, LON, YYYY, MM, DD, hh, minute, WDIR, WSPD, GST, WVHT, DPD, APD, 
MWD, PRES, PTDY, ATMP, WTMP, DEWP, VIS, TIDE 
);
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
CREATE TABLE ship (day, dewpoint_c, gust, latitude, longitude, maxgst, 
sea_level_pressure_mb, station_id, temp_c, wind);
CREATE TABLE ship_now (day, dewpoint_c, gust, latitude, longitude, maxgst, 
sea_level_pressure_mb, station_id, temp_c, wind);
CREATE TABLE stations (
 metar TEXT,
 wmob INT,
 wmos INT,
 city TEXT,
 state TEXT,
 country TEXT,
 latitude DOUBLE,
 longitude DOUBLE,
 elevation DOUBLE,
 x DOUBLE,
 y DOUBLE,
 z DOUBLE,
 humor TEXT,
 source TEXT
);
CREATE INDEX i_metar ON stations(metar);
CREATE INDEX i_x ON stations(x);
CREATE INDEX i_y ON stations(y);
CREATE INDEX i_z ON stations(z);
CREATE UNIQUE INDEX i1 ON metar(station_id, observation_time);
CREATE UNIQUE INDEX i2 ON metar_now(station_id);
CREATE UNIQUE INDEX i3 ON buoy(STN,YYYY,MM,DD,hh,mm);
CREATE UNIQUE INDEX i4 ON buoy_now(STN);
CREATE UNIQUE INDEX i5 ON ship_now(station_id);
CREATE UNIQUE INDEX i6 ON ship(station_id, day);

-- adding timestamps and full observations to tables that dont have them
ALTER TABLE buoy ADD timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE buoy ADD raw_text DEFAULT '';
ALTER TABLE buoy_now ADD timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE buoy_now ADD raw_text DEFAULT '';

ALTER TABLE ship ADD timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE ship ADD raw_text DEFAULT '';
ALTER TABLE ship_now ADD timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE ship_now ADD raw_text DEFAULT '';

-- TODO: create view that unifies fields

