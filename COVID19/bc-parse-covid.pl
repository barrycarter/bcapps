#!/bin/perl

require "/usr/local/lib/bclib.pl";

my(@conf) = split(/\n/, read_file("/home/user/COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"));

my($hashlist) = arraywheaders2hashlist([map(s/\r\n//g; $_=[csv($_)], @conf)]);

for $i (@$hashlist) {
    for $j (sort keys %$i) {
	debug("$j $i->{$j}");
    }
}

