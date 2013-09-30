-- creates the geonames sqlite3 tables after running bc-geonames2sqlite.pl

CREATE TABLE geonames (
 geonameid INTEGER PRIMARY KEY,
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

-- many indexes (creating these before import = good/bad/indifferent?)
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

CREATE INDEX i8 ON altnames(name);
CREATE INDEX i9 ON altnames(geonameid);
CREATE INDEX i10 ON altnames(isolanguage);

.import geonames.tsv geonames
.import altnames0.tsv altnames
.import altnames1.tsv altnames
