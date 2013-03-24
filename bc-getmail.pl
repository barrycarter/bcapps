#!/bin/perl

# Trivial script that runs constantly and downloads mail

require "/usr/local/lib/bclib.pl";

# forever
for (;;) {
  # globbing each time semi-inefficient but means no restart when I add more
  $stime = time();
  for $i (glob "/home/barrycarter/.getmail/getmail-*") {
    # emacs droppings
    if ($i=~/\~$/) {next;}
    debug("I: $i");
    system("timed-run 300 getmail --rcfile $i 1> /dev/null");
  }
  $etime = time();
  $lapse = $etime-$stime;

  debug("LAPSE: $lapse");

  # not more than once every 30s
  if ($lapse<30) {sleep(30-$lapse);}
}





