-- these queries are run after every madis update

-- delete entries wo temperatures
DELETE FROM madis WHERE temperature='NULL';

-- delete entries older than 24h
DELETE FROM madis WHERE time < DATETIME(CURRENT_TIMESTAMP, '-24 hour');

-- delete entries in the future (except MOS)
DELETE FROM madis WHERE time > timestamp AND type NOT IN ('MOS');

-- this is probably overkill (http://mesowest.utah.edu/cgi-bin/droman/variable_select.cgi?order=id for more details)

DELETE FROM madis WHERE (pressure<24 OR pressure>34) AND pressure!='NULL';
-- we don't allow null temps so no need to check
DELETE FROM madis WHERE temperature<-75 OR temperature>135;
DELETE FROM madis WHERE (dewpoint<-75.00 OR dewpoint>135.00) AND dewpoint!='NULL';
-- converting from knots to mph (next 2 entries)
DELETE FROM madis WHERE (windspeed<0 OR windspeed>144) AND windspeed!='NULL';
DELETE FROM madis WHERE (gust<0 OR gust>173) AND gust!='NULL';
DELETE FROM madis WHERE (winddir<0 OR winddir>360) AND winddir!='NULL';

-- probably unnecessary...
DELETE FROM madis WHERE ABS(latitude)>90 OR ABS(longitude)>180;

-- METAR-PARSED trumps many things...
-- TODO: this still allows for 2+ non-metars.cache-parsed reports

DELETE FROM madis WHERE rowid IN (SELECT m1.rowid FROM madis m1 JOIN
madis m2 ON (m1.id = m2.id AND m1.time = m2.time AND m1.source IN
('http://wdssii.nssl.noaa.gov/realtime/metar/recent/METAR.kmz',
 'http://mesowest.utah.edu/data/mesowest.out.gz',
 'http://www.srh.noaa.gov/gis/kml/metar/tf.kmz') AND
m2.source='http://weather.aero/dataserver_current/cache/metars.cache.csv.gz'));

-- Mesonet trumps /tf.kmz
DELETE FROM madis WHERE rowid IN (SELECT m1.rowid FROM madis m1 JOIN
madis m2 ON (m1.id = m2.id AND m1.time = m2.time AND m1.source IN
('http://www.srh.noaa.gov/gis/kml/metar/tf.kmz') AND
m2.source='http://mesowest.utah.edu/data/mesowest.out.gz'));

-- after all these deletes, vacuum and analyze
VACUUM;
ANALYZE madis;
