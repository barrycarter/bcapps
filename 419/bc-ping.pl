#!/bin/perl

# Pings potential scammers with traceable leonard.zeptowitz addresses

require "/usr/local/lib/bclib.pl";
$dir = "/home/barrycarter/BCGIT/419";
# gmail catcher addr
$catch = "leonard.zeptowitz";

# read entries from toping.txt
@emails = `egrep -v '^#|^\$' $dir/toping.txt | sort | uniq`;

warn "TODO: remove people in pinged.txt";

for $i (@emails) {
  # use TOD for sending addr
  # TODO: bad?
  $fromaddr = strftime("$catch+%Y%m%d%H%M%S\@gmail.com", gmtime(time()));
  # not that we can really send email more than 1/s
  sleep(1);

  debug("I: $i, $fromaddr");
}

