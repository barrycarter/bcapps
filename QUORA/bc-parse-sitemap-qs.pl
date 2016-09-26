#!/bin/perl

# Parses https://quora.com/sitemap/questions which does NOT require a
# username/password, and further digs into log entries for each
# question

require "/usr/local/lib/bclib.pl";

# TODO: cache less in production?
# TODO: suck https://www.quora.com/sitemap/recent too?
# TODO: and https://www.quora.com/sitemap/recent?page_id=9 eg?
# TODO: grab  /sitemap/questions?page_id=10 up to page 10
my($out,$err,$res) = cache_command2("curl -L https://quora.com/sitemap/questions", "age=86400");

my(%urls);

while ($out=~s/href="(.*?)"//s) {
  my($url) = $1;
  unless ($url=~/quora\.com/) {next;}
  $urls{$url} = 1;
}

debug(sort keys %urls);

# debug("OUT: $out");
