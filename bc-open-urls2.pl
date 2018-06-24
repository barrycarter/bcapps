#!/bin/perl

# Open URLs specified on STDIN/file, waiting 1s between each. Trivial
# wrapper around: egrep -v '^#' /home/barrycarter/se-sites.txt | xargs
# -n 1 -i /root/build/firefox/firefox -remote 'openURL({})'

# --sleep: sleep this many seconds between URLS (default 2)

require "/usr/local/lib/bclib.pl";

defaults("sleep=2");

while (<>) {
  chomp;

  # ignore comments and blank lines
  if (/^\#/ || /^\s*$/) {next;}

  # TODO: make this path to firefox canonical
  my($out,$err,$res) = cache_command2("/bin/firefox --new-tab '$_'");
  # TODO: make sleep time an option
  sleep($globopts{sleep});
}
