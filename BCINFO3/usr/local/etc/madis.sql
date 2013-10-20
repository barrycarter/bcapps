-- these queries are run after every madis update

-- delete entries wo temperatures
DELETE FROM madis WHERE temperature='NULL';

-- delete entries older than 24h
DELETE FROM madis WHERE time < DATETIME(CURRENT_TIMESTAMP, '-24 hour');

-- delete entries in the future (except MOS)
DELETE FROM madis WHERE time > timestamp AND type NOT IN ('MOS');

-- METAR-PARSED trumps METAR-10M and MNET1.00
-- TODO: this still allows for 2 reports, one METAR-10M and one MNET1.00

DELETE FROM madis WHERE rowid IN (SELECT m1.rowid FROM madis m1 JOIN
madis m2 ON (m1.id = m2.id AND m1.time = m2.time AND m1.type =
'METAR-10M' AND m2.type = 'METAR-parsed'));

DELETE FROM madis WHERE rowid IN (SELECT m1.rowid FROM madis m1 JOIN
madis m2 ON (m1.id = m2.id AND m1.time = m2.time AND m1.type =
'MNET1.00' AND m2.type = 'METAR-parsed'));

-- after all these deletes, vacuum and analyze
VACUUM;
ANALYZE madis;
