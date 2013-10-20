-- these queries are run after every madis update

-- delete entries wo temperatures
DELETE FROM madis WHERE temperature='NULL';

-- delete entries older than 24h
DELETE FROM madis WHERE time < DATETIME(CURRENT_TIMESTAMP, '-24 hour');

-- delete entries in the future (except MOS)
DELETE FROM madis WHERE time > timestamp AND type NOT IN ('MOS');

-- METAR-PARSED trumps METAR-10M and MNET1.00
-- TODO: this still allows for 2 reports, one METAR-10M and one MNET1.00
-- METAR-10M = http://wdssii.nssl.noaa.gov/realtime/metar/recent/METAR.kmz
-- METAR-parsed = http://weather.aero/dataserver_current/cache/metars.cache.csv.gz
-- MNET1.00 = http://mesowest.utah.edu/data/mesowest.out.gz

DELETE FROM madis WHERE rowid IN (SELECT m1.rowid FROM madis m1 JOIN
madis m2 ON (m1.id = m2.id AND m1.time = m2.time AND m1.source =
'http://wdssii.nssl.noaa.gov/realtime/metar/recent/METAR.kmz' AND 
m2.source = 'http://weather.aero/dataserver_current/cache/metars.cache.csv.gz'));

DELETE FROM madis WHERE rowid IN (SELECT m1.rowid FROM madis m1 JOIN
madis m2 ON (m1.id = m2.id AND m1.time = m2.time AND m1.source =
'http://mesowest.utah.edu/data/mesowest.out.gz' AND 
m2.source = 'http://weather.aero/dataserver_current/cache/metars.cache.csv.gz'));

-- after all these deletes, vacuum and analyze
VACUUM;
ANALYZE madis;
