#!/bin/perl

# Another program that benefits only me <h>(my goal is to create one
# that benefits no body, and then maybe one that harms people
# including myself)</h>, creates an IIM iMacros file to download my
# Capital One credit card information

# --norun: create the macro, but don't run it in Firefox

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# run the macro
# TODO: yes, this is a terrible place to keep my firefox
($out, $err, $res) = cache_command("/root/build/firefox/firefox -remote 'openURL(http://run.imacros.net/?m=bc-create-capone.iim,new-tab)'");

# not sure how long it takes to run above command, so wait until
# transactions*.ofx shows up in download directory (and is fairly recent)

# TODO: this is hideous (-mmin -60 should be calculated not a guess)

for (;;) {
  ($out, $err, $res) = cache_command("find '/home/barrycarter/Download/' -iname 'transactions*.ofx' -mmin -60");
  if ($out) {last;}
  debug("OUT: $out");
  sleep(1);
}

my($fname) = $out;
chomp($fname);

# send file to ofx parser
($out, $err, $res) = cache_command("/home/barrycarter/BCGIT/bc-parse-ofx2.pl '$fname' | mysql test");

$globopts{debug} = 1;
debug("OUT: $out","ERR: $err","RES: $res");
