-- creates the geonames sqlite3 tables, assuming the output of bc-geonames2sqlite.pl is in /var/tmp/

CREATE TABLE geonames (
 geonameid INTEGER PRIMARY KEY,
 asciiname TEXT,
 latitude INT,
 longitude INT,
 feature_code INT,
 parent INT,
 population INT,
 timezone INT,
 elevation INT
);

CREATE INDEX i_feature_code ON geonames(feature_code);
CREATE INDEX i_parent ON geonames(parent);
.separator "\t"
.import /var/tmp/geonames.out geonames

CREATE TABLE altnames (
 geonameid INT,
 name TEXT
);

CREATE INDEX i_name ON altnames(name);
.import /var/tmp/altnames2.out altnames
DELETE FROM altnames WHERE name = '';
INSERT INTO altnames VALUES (0,'');
INSERT INTO geonames (geonameid) VALUES (0);
VACUUM;

CREATE TABLE tzones (
 timezoneid INTEGER PRIMARY KEY,
 name TEXT
);
.separator "\t"
.import /var/tmp/tzones.out tzones

