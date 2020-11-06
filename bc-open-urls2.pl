#!/bin/perl

# Open URLs specified on STDIN/file, waiting 1s between each. Trivial
# wrapper around: egrep -v '^#' /home/barrycarter/se-sites.txt | xargs
# -n 1 -i /root/build/firefox/firefox -remote 'openURL({})'

# --profile: connect to this profile

# --sleep: sleep this many seconds between URLS (default 2)

# --stdin: wait for newline on stdin instead of sleeping (actually pops up an xmessage)

require "/usr/local/lib/bclib.pl";

# add string to connect to specific profile if requested

my($profile);

if ($globopts{profile}) {$profile="-P $globopts{profile}";}

defaults("sleep=2");

while (<>) {
  chomp;

  # ignore comments and blank lines
  if (/^\#/ || /^\s*$/) {next;}

  # TODO: make this path to firefox canonical
  my($out,$err,$res) = cache_command2("/bin/firefox $profile --new-tab '$_'");

  if ($globopts{stdin}) {

    system("xmessage -geometry +0+0 NEXT");

    # TODO: can't use xmessage function here, too side
    #xmessage("NEXT?");
  } else {
    sleep($globopts{sleep});
  }
}

