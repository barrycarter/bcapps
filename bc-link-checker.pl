#!/bin/perl

# created to test links on traceroute.org (after confirming it's
# maintained), but can be used as generalized linkchecker one day?

require "/usr/local/lib/bclib.pl";

($url) = @ARGV;

# doing test work in perm dir
dodie('chdir("/var/tmp/test")');

# we assume pages (including linked-to pages) won't change soon
($out) = cache_command("curl $url", "age=86400");

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

  # http only
  unless ($url=~/http:/) {next;}

  # keep track (using hash not list to avoid dupes)
  # storing in sha1 file for convenience, and storing reverse
  $sha = sha1_hex($url);
  $url{$url}=$sha;
  $sha2url{$sha} = $url;

  # if we already have the output of this URL (or err), don't run again
  if (-f $url{$url} || -f "$url{$url}.err") {delete $url{$url};}
}

open(B,">runme");

for $i (sort keys %url) {
  print B "curl -D $url{$i}.headers -L -o $url{$i} '$i' 2> $url{$i}.err\n";
}

close(B);

# and run
system("parallel -j 20 < runme");
