#!/bin/perl

# Populates metarnew.db using recent_weather() [thin wrapper]

require "bclib.pl";
require "bc-weather-lib.pl";


@reports = recent_weather();
debug(sort keys %{$reports[0]});

die "TESTING";

debug(@reports);
@queries = hashlist2sqlite(\@reports, "metar");

debug(@queries);


