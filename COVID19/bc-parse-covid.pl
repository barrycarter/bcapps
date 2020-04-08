#!/bin/perl

require "/usr/local/lib/bclib.pl";

# fields: Province/State,Country/Region,Last Update,Confirmed,Deaths,Recovered

# should be run with list of files such as:
# /home/user/COVID-19/csse_covid_19_data/csse_covid_19_daily_reports/*.csv

while (<>) {

    s/\r\n//g;

    my($adm, $cc, $lu, $cases, $deaths, $rec) = csv($_);

    if ($cases eq "Confirmed") {next;}

    if ($adm eq "New Mexico" || $adm eq "NM") {
	debug($_);
    }
}
