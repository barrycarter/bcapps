-- yet another attempt to create geonames "quickly" wo a perl script

: in shell

CREATE TABLE geonames (
 geonameid INTEGER PRIMARY KEY,
 asciiname TEXT,
 latitude DOUBLE,
 longitude DOUBLE,
 feature_code INT,
 country_code INT,
 admin4_code INT,
 admin3_code INT,
 admin2_code INT,
 admin1_code INT,
 population INT, 
 elevation INT,
 timezone TEXT
);

: below in shell

# all-scramble is a "sort -R"'d version of allCountries.txt, better for testing
perl -F"\t" -anle 'print join("\t",@F[0,2,4,5,7,8,10..15,17])' all-scramble.txt | head -1000 > test1.txt

.separator "\t"
.import test1.txt geonames

CREATE TEMPORARY TABLE geonames (
0 geonameid,
1 name,
2 asciiname,
3 alternatenames,
4 latitude,
5 longitude,
6 featureclass,
7 featurecode,
8 countrycode,
9 cc2,
10 admin1code,
11 admin2code,
12 admin3code,
13 admin4code,
14 population,
15 elevation,
dem,
17 timezone,
modificationdate DEFAULT ''
);

.bail OFF
.separator "\t"
.import allCountries.txt geonames

