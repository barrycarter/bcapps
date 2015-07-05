#!/bin/perl

# Populates metarnew.db using recent_weather() [thin wrapper]
# --nodaemon: just run once, don't "daemonize"

require "/usr/local/lib/bclib.pl";
require "/usr/local/lib/bc-weather-lib.pl";
option_check(["nodaemon"]);

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

debug(var_dump("reports",@reports));
debug(hashlist2sqlite(\@reports, "metar"));

# the "stardate" 24 hours ago (so I can kill off old BUOY reports)
# <h>love was such an easy game to play</h>
$yest = stardate(time()-86400);

my($daten) = `date +%Y%m%d.%H%M%S.%N`;
chomp($daten);
my($qfile) = "/var/tmp/querys/$daten-metarnew-get-metar-db-$$";

open(A,">$qfile")||warn("Can't open file $qfile, $!");

# prevent stale stations from having current cached data + start
# transaction + delete old data from main dbs, including data with bad
# observation_time (using timestamp in that case)

print A << "MARK";
BEGIN;
DELETE FROM metar_now;
DELETE FROM buoy_now;
DELETE FROM ship_now;

DELETE FROM metar WHERE (strftime('%s', 'now') - strftime('%s', observation_time) > 86400) OR (strftime('%s', 'now') - strftime('%s', timestamp) > 100000);

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

# NOTE: could also run this as cron job (and maybe should?)
in_you_endo();

unless ($globopts{nodaemon}) {
  # call query gobbler and respawn
  system("bc-query-gobbler.pl metarnew");
  sleep(60);
  exec($0);
} else {
  warn("In --nodaemon mode, not running bc-query-gobbler.pl");
}

