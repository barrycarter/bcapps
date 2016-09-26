#!/bin/perl

# Parses https://quora.com/sitemap/questions which does NOT require a
# username/password, and further digs into log entries for each
# question

require "/usr/local/lib/bclib.pl";

# TODO: cache less in production?
# TODO: suck https://www.quora.com/sitemap/recent too?
# TODO: and https://www.quora.com/sitemap/recent?page_id=9 eg?
# TODO: grab  /sitemap/questions?page_id=10 up to page 10

my($out,$err,$res);
my(%urls);

# TODO: check write perms here?
unless (-d "/var/tmp/quora") {die "Create /var/tmp/quora";}

for $i (1..10) {
  for $j ("questions", "recent") {

    ($out,$err,$res) = cache_command2("curl -L 'https://quora.com/sitemap/$j?page_id=$i'", "age=86400");

    while ($out=~s/href="(.*?)"//s) {
      my($url) = $1;
      unless ($url=~/quora\.com/) {next;}
      $urls{$url} = 1;
    }
  }
}

# NOTE: this yielded 3833 URLs the first time I tried it, wow!

for $i (keys %urls) {

  my($fname) = $i;
  $fname=~s%^.*/%%;
  $fname = "/var/tmp/quora/$fname.log";

  # NOTE: we never download the question page itself
  # probably better to cache this way
  # TODO: worry about staleness here
  # TODO: actually, still need to parse file, so can't just next here
  if (-f $fname) {next;}

  ($out, $err, $res) = cache_command("curl -o '$fname' '$i/log'", "age=86400");

  while ($out=~s/href="(.*?)"//s) {
    debug("HREF: $1");
  }
}


# debug(sort keys %urls);

# debug("OUT: $out");
