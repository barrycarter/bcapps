#!/bin/perl

# Another program that benefits only me <h>(my goal is to create one
# that benefits no body, and then maybe one that harms people
# including myself)</h>, creates an IIM iMacros file to download my
# allybank.com information

# As of < 24 Jan 2015, Ally Bank made major changes ("we're improving
# our website to screw you over"), and the macro is now hardcoded, so
# this program does very little

require "/usr/local/lib/bclib.pl";

# run the macro
# TODO: yes, this is a terrible place to keep my firefox
($out, $err, $res) = cache_command("/root/build/firefox/firefox -remote 'openURL(http://run.imacros.net/?m=bc-create-ally.iim,new-tab)'");

# not sure how long it takes to run above command, so wait until
# transactions*.qfx shows up in download directory (and is fairly recent)

# TODO: this is hideous (-mmin -60 should be calculated not a guess)
# TODO: this loop should exit if no results for a long time

for (;;) {
  ($out, $err, $res) = cache_command("find '/home/barrycarter/Download/' -iname 'transactions*.qfx' -mmin -60");
  if ($out) {last;}
  debug("OUT: $out");
  sleep(60);
}

# send file to ofx parser
($out, $err, $res) = cache_command("/home/barrycarter/BCGIT/bc-parse-ofx.pl $out");

# useless fact: allybank.com no longer names their OFX dumps as
# trans[x], where x is the unix time to the millisecond (I think)
