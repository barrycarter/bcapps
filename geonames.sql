-- creates the geonames sqlite3 tables, assuming the output of bc-geonames2sqlite.pl is in /var/tmp/

CREATE TABLE geonames (
 geonameid INTEGER PRIMARY KEY,
 asciiname TEXT,
 latitude INT,
 longitude INT,
 feature_code INT,
 country_code INT,
 admin4_code INT,
 admin3_code INT,
 admin2_code INT,
 admin1_code INT,
 population INT,
 timezone INT,
 elevation INT
);

CREATE INDEX i_feature_code ON geonames(feature_code);

-- added below later, it is useful
CREATE INDEX i_population ON geonames(population);

.separator "\t"
.import /var/tmp/geonames.out geonames

CREATE TABLE altnames (
 geonameid INT,
 name TEXT
);

CREATE INDEX i_name ON altnames(name);
-- added below later, useful
CREATE INDEX i_geonameid ON altnames(geonameid);
-- below 5 are useful for joins
CREATE INDEX i_country_code ON geonames(country_code);
CREATE INDEX i_admin1_code ON geonames(admin1_code);
CREATE INDEX i_admin2_code ON geonames(admin2_code);
CREATE INDEX i_admin3_code ON geonames(admin3_code);
CREATE INDEX i_admin4_code ON geonames(admin4_code);

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

