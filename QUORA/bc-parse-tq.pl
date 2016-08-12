#!/bin/perl

# parses https://www.quora.com/answer/top_questions

require "/usr/local/lib/bclib.pl";

my($all, $fname) = cmdfile();

# trim to "More Stories" at top and "layout_3col_right" at bottom

$all=~s/^.*More Stories//s;
$all=~s/layout_3col_right.*$//s;

my(%links);

my(@items) = split(/<div class="feed_item_inner".*?>/, $all);

for $i (@items) {

  my($print) = $i;
  $print=~s/>/>\n/sg;
  debug("GOT: $print");

  my(%hash) = ();

  # a hash
  while ($i=~s%<(span|p) class="([^<>]*?)">(.*?)</\1>%%s) {
    debug("SETTING $2 -> $3");
    $hash{$2} = $3;
  }

#  debug(dump_var("HASH",\%hash));

  next; # TODO: TESTING!!!


  # get topics
  my(@topics) = ($i=~m%"https://www.quora.com/topic/(.*?)"%);
  debug("TOIPCS", @topics);

  # timestamp
  # TODO: include time of file itself so we know what these are relative to
  $i=~s%<span class="timestamp">\s*(.*?)\s*</span>%%s;
  my($ts) = $1;
  $ts=~s/<.*?>//g;
  debug("TS: $ts");

  # title of question
  


#  debug("GOT: $i");
}

die "TESTING";

# debug("ALL: $all");

while($all=~s/href="(.*?)"//s) {
  my($link) = $1;
  # find all quora.com links to non-profiles and non-topics (ie, questions)
  if ($link=~m%/(profile|topic)/% || $link!~m%/www\.quora\.com/%) {next;}
  $links{$link} = 1;
}

# obtain logs for all questions but cache; use tor to avoid IP
# blockage; note that you do NOT need to be logged in to see a
# question's log entries (or even the question itself, hmmm)

for $i (sort keys %links) {

  debug("LOGS/Q FOR: $i");

  # TODO: 86400s is possibly excessive here
  my($out, $err, $res) = cache_command2("curl --socks4a 127.0.0.1:9050 '$i/log'", "age=86400");
  my($out2, $err2, $res2) = cache_command2("curl --socks4a 127.0.0.1:9050 '$i'", "age=86400");

  if ($res == 2) {warn "ERROR: $i"; next;}

  while ($out=~s/href="(.*?)"//s) {
    debug("LINK: $1");
  }

  # look at log
#  debug("LOG IS: $out");



die "TESTING";


}

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
