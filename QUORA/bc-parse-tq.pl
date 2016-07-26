#!/bin/perl

# parses https://www.quora.com/answer/top_questions

require "/usr/local/lib/bclib.pl";

my($all) = read_file("/home/barrycarter/20160724/top_questions.html");

# trim to "More Stories" at top and "layout_3col_right" at bottom

$all=~s/^.*More Stories//s;
$all=~s/layout_3col_right.*$//s;

my(%links);
while($all=~s/href="(.*?)"//s) {
  my($link) = $1;
  # find all quora.com links to non-profiles and non-topics (ie, questions)
  if ($link=~m%/(profile|topic)/% || $link!~m%/www\.quora\.com/%) {next;}
  $links{$link} = 1;
}

# obtain logs for all questions but cache; use tor to avoid IP
# blockage; note that you do NOT need to be logged in to see a
# question's log entries (or even the question itself, hmmm)

my($out, $err, $res);

for $i (sort keys %links) {

  debug("LOGS/Q FOR: $i");

  # TODO: 86400s is possibly excessive here
  ($out, $err, $res) = cache_command2("curl --socks4a 127.0.0.1:9050 '$i/log'", "age=86400");
  ($out, $err, $res) = cache_command2("curl --socks4a 127.0.0.1:9050 '$i'", "age=86400");
}



# debug(keys %links);

die "TESTING";

my(@items) = split(/<div class="feed_item_inner"/s, $all);

for $i (@items) {
  while ($i=~s/href="(.*?)"//s) {$links{$1}=1;}
  debug("I: ",keys %links);
}


die "TESTING";

while ($all=~s/href="(.*?)"//s) {
  debug($1);
}
