#!/bin/perl

require "/usr/local/lib/bclib.pl";

# fields: Province/State,Country/Region,Last Update,Confirmed,Deaths,Recovered

# fields for 04-07-2020: FIPS,Admin2,Province_State,Country_Region,Last_Update,Lat,Long_,Confirmed,Deaths,Recovered,Active,Combined_Key

# fields for 01-22-2020: <EF><BB><BF>Province/State,Country/Region,Last Update,Confirmed,Deaths,Recovered

# should be run with list of files such as:
# /home/user/COVID-19/csse_covid_19_data/csse_covid_19_daily_reports/*.csv

while (<>) {

    s/\r\n//g;

    my($adm, $cc, $lu, $cases, $deaths, $rec) = csv($_);

    if ($cases eq "Confirmed") {next;}

    debug

    if ($adm eq "New Mexico" || $adm eq "NM") {
#	debug($_);
    }
}
