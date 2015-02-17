#!/bin/perl

# download reputation data from stackexchange; will merge this into
# bc-suck-stack or whatever

require "/usr/local/lib/bclib.pl";

my($out,$err,$res) = cache_command2("curl -L 'https://astronomy.stackexchange.com/users/21/barrycarter?tab=reputation'", "age=86400");

my(%urls);

# could do better filtering here
while ($out=~s/data-load-url="(.*?)"//s) {$urls{$1}=1;}

# download data, but not post-specific data(?)

for $i (sort keys %urls) {
  unless ($i=~/post$/) {next;}
  my($out,$err,$res) = cache_command2("curl -L 'https://astronomy.stackexchange.com/$i'", "age=86400");

  # tseting
  debug("I: $i");
  unless ($i=~/1420416000/) {next;}

  debug("OUT($i): $out");
}
