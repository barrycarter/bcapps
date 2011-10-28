#!/bin/perl

# Populates metarnew.db using recent_weather() [thin wrapper]

require "/usr/local/lib/bclib.pl";
require "/usr/local/lib/bc-weather-lib.pl";

@reports = recent_weather();
@querys = (hashlist2sqlite(\@reports, "metar"),
	   hashlist2sqlite(\@reports, "metar_now"));

# TODO: this is clever, but probably not best way to do this
open(A,"|sqlite3 /usr/local/etc/WEATHER/metarnew.db");
print A "BEGIN;\n";
print A join(";\n", @querys);
print A ";\nCOMMIT;\n";
close(A);

# TODO: rsync back to home base!
system("rsync /usr/local/etc/WEATHER/metarnew.db root\@data.barrycarter.info:/sites/DB/metarnew.db");

# NOTE: could also run this as cron job (and maybe should?)
sleep(60);
exec($0);


