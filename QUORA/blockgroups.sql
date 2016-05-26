-- trivially creates blockgroups table from blockgroups.txt

CREATE TABLE blockgroups ( 
 geoid text, statefp INT, aland DOUBLE, awater DOUBLE, 
 intptlat DOUBLE, intptlon DOUBLE, population INT 
);

.separator ,
.import blockgroups.txt blockgroups

-- lower 48 + DC https://www.epa.gov/enviro/state-fips-code-listing



 
