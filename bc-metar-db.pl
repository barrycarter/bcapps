#!/bin/perl

# Populates metarnew.db using recent_weather() [thin wrapper]

require "/usr/local/lib/bclib.pl";
require "/usr/local/lib/bc-weather-lib.pl";

@reports = recent_weather();
@querys = (hashlist2sqlite(\@reports, "metar"),
	   hashlist2sqlite(\@reports, "metar_now"));

# TODO: this is clever, but probably not best way to do this
open(A,"|sqlite3 /usr/local/etc/WEATHER/metarnew.db 1> /tmp/sql.out 2> /tmp/sql.err");
print A "BEGIN;\n";

# prevent stale stations from having cached data
print A "DELETE FROM metar_now;\n";


print A join(";\n", @querys);
print A ";\nCOMMIT;\n";

#<h>TODO: work in a buoy-yah pun somehow</h>

# and now, buoy data
@reports = recent_weather_buoy();
@querys = (hashlist2sqlite(\@reports, "buoy"),
	   hashlist2sqlite(\@reports, "buoy_now"));

# TODO: this is clever, but probably not best way to do this
print A "BEGIN;\n";
print A "DELETE FROM buoy_now;\n";
print A join(";\n", @querys);
print A ";\nCOMMIT;\n";
print A "VACUUM;\n";
close(A);

# TODO: rsync back to home base!
system("rsync /usr/local/etc/WEATHER/metarnew.db root\@data.barrycarter.info:/sites/DB/metarnew.db");

# NOTE: could also run this as cron job (and maybe should?)
sleep(60);
exec($0);
