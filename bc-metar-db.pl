#!/bin/perl

# Populates metarnew.db using recent_weather() [thin wrapper]

require "/usr/local/lib/bclib.pl";
require "/usr/local/lib/bc-weather-lib.pl";

@reports = recent_weather();
@breports = recent_weather_buoy();
@querys = (hashlist2sqlite(\@reports, "metar"),
	   hashlist2sqlite(\@reports, "metar_now"),
	   hashlist2sqlite(\@breports, "buoy"),
	   hashlist2sqlite(\@breports, "buoy_now")
);

open(A,">/var/tmp/metar-db-queries.txt")||warn("Can't open file, $!");

# prevent stale stations from having current cached data + start
# transaction + delete old data from main dbs

# TODO: add DELETE FROM buoy WHERE strftime('%s', 'now') - strftime('%s', observation_time) > 86400; [but correctly]

print A << "MARK";
BEGIN;
DELETE FROM metar_now;
DELETE FROM buoy_now;
DELETE FROM metar WHERE strftime('%s', 'now') - strftime('%s', observation_time) > 86400;
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

system("sqlite3 /usr/local/etc/WEATHER/metarnew.db < /var/tmp/metar-db-queries.txt; rsync /usr/local/etc/WEATHER/metarnew.db root\@data.barrycarter.info:/sites/DB/metarnew.db");

# NOTE: could also run this as cron job (and maybe should?)
sleep(60);
exec($0);
