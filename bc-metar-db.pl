#!/bin/perl

# Populates metarnew.db using recent_weather() [thin wrapper]

require "/usr/local/lib/bclib.pl";
require "/usr/local/lib/bc-weather-lib.pl";

# in correct dir
dodie('chdir("/var/tmp")');

# renice self
system("/usr/bin/renice 19 -p $$");

@reports = recent_weather();
@breports = recent_weather_buoy();
@sreports = recent_weather_ship();
@querys = (hashlist2sqlite(\@reports, "metar"),
	   hashlist2sqlite(\@reports, "metar_now"),
	   hashlist2sqlite(\@breports, "buoy"),
	   hashlist2sqlite(\@breports, "buoy_now"),
	   hashlist2sqlite(\@sreports, "ship"),
	   hashlist2sqlite(\@sreports, "ship_now")
);

# the "stardate" 24 hours ago (so I can kill off old BUOY reports)
# <h>love was such an easy game to play</h>
$yest = stardate(time()-86400);

open(A,">/var/tmp/metar-db-queries.txt")||warn("Can't open file, $!");

# prevent stale stations from having current cached data + start
# transaction + delete old data from main dbs

print A << "MARK";
BEGIN;
DELETE FROM metar_now;
DELETE FROM buoy_now;
DELETE FROM metar WHERE strftime('%s', 'now') - strftime('%s', observation_time) > 86400;
DELETE FROM buoy WHERE YYYY*10000 + MM*100 + DD + hh/100. + minute/10000 < $yest;
MARK
;

print A join(";\n", @querys).";\n";

print A << "MARK";
COMMIT;
VACUUM;
MARK
;
close(A);

#<h>TODO: work in a buoy-yah pun somehow</h>

# run command + rsync
# 30 Jan 2012: changed back to running on local machine, so copy/change/move

system("cp /sites/DB/metarnew.db .; sqlite3 metarnew.db < /var/tmp/metar-db-queries.txt; mv /sites/DB/metarnew.db /sites/DB//metarnew.db.old; mv metarnew.db /sites/DB");

# NOTE: could also run this as cron job (and maybe should?)
sleep(60);
in_you_endo();
exec($0);

=item schema

Schema for ship tables:

CREATE TABLE ship (day, dewpoint_c, gust, latitude, longitude, maxgst,
sea_level_pressure_mb, station_id, temp_c, wind);

CREATE TABLE ship_now (day, dewpoint_c, gust, latitude, longitude, maxgst,
sea_level_pressure_mb, station_id, temp_c, wind);

CREATE UNIQUE INDEX i5 ON ship_now(station_id);
CREATE UNIQUE INDEX i6 ON ship(station_id, day);

=cut
