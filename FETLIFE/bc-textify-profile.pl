#!/bin/perl

# "textifies" a given FetLife user profile so that google can index it
# does NOT preserve structured data, just "text"

# Serves a different purpose than bc-trim-fl-profile.pl which attempts
# to preserve structured data

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {

  my($all);
  if ($i=~/\.bz2$/) {
    $all = join("", `bzcat $i`);
  } else {
    $all = read_file($i);
  }

  # javascript
  $all=~s%<script type="text/javascript">.*?</script>%%sg;

  # bad sections
  $all=~s%<section id="report_user".*?</section>%%s;

  # block/friend user and footer
  $all=~s%<div id="(block|footer)".*?</div>%%s;
  # no idea why I have to do this separately
  $all=~s%<div id="friendship_request_form".*?</div>%%s;

  # (other) html tags
#  $all=~s/<.*?>//g;

  # multiple blank lines
  $all=~s/\s*\n+\s*/\n/sg;

  debug("ALL: $all");

}
