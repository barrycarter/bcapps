-- the SQL to import station data and metadata

-- the below imports ghcnd-stations.txt

-- I will drop this table later, since I don't need data for most stations

-- work below must be done in untarred ghcnd_all directory after
-- running ../WEATHER/bc-get-hilo.pl output to extremes.txt

CREATE TABLE statns (code TEXT, latitude DOUBLE, longitude DOUBLE, name TEXT);
.separator "\t"
.import ghcnd-stations.txt statns

CREATE TABLE extemp (
 code TEXT,
 min0 DOUBLE, min1 DOUBLE, min2 DOUBLE, min5 DOUBLE,
 max95 DOUBLE, max98 DOBULE, max99 DOUBLE, max100 DOUBLE,
 lowvals INT, highvals INT
);

.separator ","
.import extremes.txt extemp
