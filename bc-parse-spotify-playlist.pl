#!/bin/perl

# given a spotify playlist (eg, the output of:
# curl -LO https://open.spotify.com/embed/playlist/5J9Si4NGjdbyJZorMmNoH6
# ), parses it

require "/usr/local/lib/bclib.pl";

my($all, $fname) = cmdfile();

debug("ALL: $all");

unless ($all=~s%<script id="resource" type="application/json">\s*(.*?)\s*</script>%%) {
  die "COULD NOT FIND JSON RESOURCE SECTION";
}

my($json) = $1;

debug($json);
