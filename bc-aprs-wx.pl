#!/bin/perl

# Obtains weather data from the APRS stream <h>and does absolutely
# nothing with it</h>

require "bclib.pl";

open(A,"echo 'user READONLY pass -1' | ncat rotate.aprs.net 23 |");

while (<A>) {
  # TODO: this is an inaccurate and improper way to find weather data
  unless (/t\d{3}\D/i) {next;}
  debug($_);
}

