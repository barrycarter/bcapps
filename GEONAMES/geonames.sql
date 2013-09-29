-- creates the geonames sqlite3 tables after running bc-geonames2sqlite.pl

CREATE TABLE geonames (
 geonameid INTEGER PRIMARY KEY,
 asciiname TEXT,
 latitude DOUBLE,
 longitude DOUBLE,
 feature_code INT,
 admin0_code INT,
 admin4_code INT,
 admin3_code INT,
 admin2_code INT,
 admin1_code INT,
 adminstring TEXT,
 population INT,
 timezone INT,
 elevation INT
);

.separator "\t"
.import geonames.tsv geonames

-- many indexes (do NOT need for asciiname, since altnames will handle that)
CREATE INDEX i1 ON geonames(feature_code);
CREATE INDEX i2 ON geonames(population);
CREATE INDEX i3 ON geonames(admin0_code);
CREATE INDEX i4 ON geonames(admin1_code);
CREATE INDEX i5 ON geonames(admin2_code);
CREATE INDEX i6 ON geonames(admin3_code);
CREATE INDEX i7 ON geonames(admin4_code);


CREATE TABLE altnames (
 alternatenameid INTEGER PRIMARY KEY,
 geonameid INT,
 isolanguage TEXT,
 name TEXT,
 isPreferredName TINYINT,
 isShortName TINYINT,
 isColloquial TINYINT,
 isHistoric TINYINT
);

CREATE INDEX i_name ON altnames(name);
-- added below later, useful
CREATE INDEX i_geonameid ON altnames(geonameid);
-- below 5 are useful for joins

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

-- TODO: probably need feature class too
-- or at least http://www.geonames.org/export/codes.html
-- TODO: full description of feature codes too
CREATE TABLE featurecodes (
 featurecodeid INTEGER PRIMARY KEY,
 abbrev TEXT
);
.separator "\t"
.import /var/tmp/featurecodes.out featurecodes

-- not sure how these get in, but lets get rid of them
DELETE FROM altnames WHERE geonameid = '';

