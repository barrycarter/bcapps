#!/bin/perl -0777

# TODO: I might be able to use this via xinetd or websocket proxy, see
# if I want do to that though

# The main map server

require "/usr/local/lib/bclib.pl";

# TODO: generalize these paths
require "$bclib{githome}/MAPS/bc-mapserver-lib.pl";
require "$bclib{githome}/MAPS/bc-mapserver-commands.pl";

my($ans) = process_command(str2hashref("cmd=time&foo=bar&i=hero"));

debug(var_dump("ans", $ans));




