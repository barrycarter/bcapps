#!/bin/perl

# parses https://www.quora.com/answer/top_questions

require "/usr/local/lib/bclib.pl";

my($all) = read_file("/home/barrycarter/20160724/top_questions.html");

# TODO: trim to "More Stories" at top and layout_3col_right at bottom

my(@items) = split(/<div class="feed_item_inner"/s, $all);

for $i (@items) {
  my(%links);
  while ($i=~s/href="(.*?)"//s) {$links{$1}=1;}
  debug("I: ",keys %links);
}


die "TESTING";

while ($all=~s/href="(.*?)"//s) {
  debug($1);
}
