#!/bin/perl

# splinters from bc-get-weather.pl to provide astronomical information
# for X window background (bc-bg.pl) for next minute (to avoid 1m
# lag), and schedules <h>(pron. say-joules)</h> at job to call itself
# again when needed; unlike bc-get-weather.pl, uses Astro::Nova and
# does better job with moon rise/set

require "/usr/local/lib/bclib.pl";

# my approximate latitude/longitude (if you type this into google
# maps, you get an address; to emphasize, I do NOT live at that
# address!)

# TODO: let this be an option to the program?
my($lng,$lat) = (-106.55, 35.1);

# determine next minute
my($nm) = 60*floor(time()/60)+60;

debug("NM: $nm");


