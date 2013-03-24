#!/bin/perl

# I have an Alpine filter that puts all my flextel "someone has
# called" emails into a FLEXTEL folder. This program extracts and
# displays relevant information on those calls

require "/usr/local/lib/bclib.pl";
open(A,"egrep -i '^flextel' /home/barrycarter/mail/FLEXTEL|");

while (<A>) {
  unless (/number (\d+) was called from (\S+) at (.{8}) on (.*?)\.$/i) {
    warn("BAD LINE: $_");
  }

  my($target,$source,$time,$date) = ($1,$2,$3,$4);

  my($timef) = strftime("%Y%m%d.%H%M%S", localtime(str2time("$date $time")));
  debug("$date $time -> $timef");

  print "$timef $target $source\n";

}

