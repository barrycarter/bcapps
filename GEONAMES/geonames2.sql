-- yet another attempt to create geonames "quickly" wo a perl script

CREATE TEMPORARY TABLE geonames (
geonameid,
name,
asciiname,
alternatenames,
latitude,
longitude,
featureclass,
featurecode,
countrycode,
cc2,
admin1code,
admin2code,
admin3code,
admin4code,
population,
elevation,
dem,
timezone,
modificationdate DEFAULT ''
);

.bail OFF
.separator "\t"
.import allCountries.txt geonames

