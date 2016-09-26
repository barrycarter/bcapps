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

dodie("chdir('/var/tmp/quora')");

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

  # TODO: below can break on long question names, ignoring for now
  my($fname) = $i;
  $fname=~s%^.*/%%;

  # hashify
  if (length($fname)>246) {
    my($hash) = sha1_hex($fname);
    $fname = substr($fname,0,200)."$hash";
  }

  # TODO: probably better to cache this way, but worry about staleness
  # TODO: using two loops here is sloppy, just being careful for now
  unless (-f "$fname.log") {
    debug("OBTAINING: $i/log -> $fname.log");
    ($out, $err, $res) = cache_command2("curl -Lo '$fname.log' '$i/log'");
    }

  unless (-f "$fname.html") {
    debug("OBTAINING: $i.html");
    ($out, $err, $res) = cache_command2("curl -Lo '$fname.html' '$i'");
  }

#  if (++$count>25) {die "TESTING";}

  # TODO: this is now misplaced, needs to occur both times
#  while ($out=~s/href="(.*?)"//s) {
#    debug("HREF: $1");
#  }
}


# debug(sort keys %urls);

# debug("OUT: $out");
