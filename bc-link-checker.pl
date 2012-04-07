#!/bin/perl

# created to test links on traceroute.org (after confirming it's
# maintained), but can be used as generalized linkchecker one day?

require "bclib.pl";

# doing test work in perm dir
dodie('chdir("/var/tmp/run")');

# we assume pages (including linked-to pages) won't change soon
($out) = cache_command("curl http://www.traceroute.org/", "age=86400");

# find all angle brackets, keep 'a ... href' ones
while ($out=~s/<(.*?)>//) {
  $tag = $1;

  # ignore non-a tags
  unless ($tag=~/^a/i) {next;}

  # find the href in this tag (assumes well-behaved hyperlinks; eg, quoted)
  unless ($tag=~/href="(.*?)"/) {next;}

  $url = $1;

  # strip hash tags and ignore if now empty
  $url=~s/\#.*$//;
  unless ($url) {next;}

  debug("TAG: $url");
}

# debug("OUT: $out");
