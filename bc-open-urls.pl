#!/bin/perl

# Open URLs specified on STDIN/file, waiting 1s between each. Trivial
# wrapper around: egrep -v '^#' /home/barrycarter/se-sites.txt | xargs
# -n 1 -i /root/build/firefox/firefox -remote 'openURL({})'

require "/usr/local/lib/bclib.pl";

while (<>) {
  chomp;
  # TODO: make this path to firefox canonical
  my($out,$err,$res) = cache_command2("/root/build/firefox/firefox -remote 'openURL($_)'");
  # TODO: make sleep time an option
  sleep(2);
}
