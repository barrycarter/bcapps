#!/bin/perl

# A rewrite of bc-twitter-follow-stream.pl that remonolithicizes
# <h>(is that even a word?)</h> the program, using what I've learned
# from writing separate programs

# PLEDGE: I will try to be clear, not clever, when writing this program

# PLEDGE: I will try to use API calls when possible, unless I run out
# (following Knuth's belief that premature optimization is the root of
# all evil)

require "/usr/local/etc/bclib.pl";
require "/home/barrycarter/bc-private.pl";
$db = "/usr/local/etc/bctfs3/db.db";
unless (-s $db) {die "$db: does not exist or is empty file";}






die "TESTING";

# neverending loop
for (;;) {
  $now = time();
  # TODO: add sleep
}






=item schema

Single database /usr/local/etc/bctfs3/db.db with these tables


=cut

# obtain tweets using twitter's HTTP search stream (since they shut
# down basic auth stream API, the fish poops [aka bass turds])
sub get_tweets {
  my(@res);
  # TODO: currently hardcoding to find followbackers, not by keyword
  my($keyword)=urlencode("#teamfollowback OR #autofollowback OR #followback OR #500aday OR #ifollowback OR #instantfollowback");
#  my($url) = "http://twitter.com/search?q=$keyword";
  my($url) = "http://twitter.com/search/realtime?q=$keyword";
  my($out,$err,$res) = cache_command2("curl-kill -NL '$url'","age=0");
  # this is just for debugging
  $out=~s/\n+/\n/isg;
  $out=~s/ +/ /isg;
  # split into tweets
  my(@tweets) = split(/<div class=\"tweet/s,$out);
  # kill off HTML header
  shift(@tweets);

  # parse each tweet and store in hash
  for $i (@tweets) {
    my(%tweet) = ();
    while ($i=~s/data-(.*?)="(.*?)"//s) {
      my($key,$val) = ($1,$2);
      $key=~s/-/_/isg;
      $tweet{$key} = $val;
    }

    # cleanup expanded footer (even though I won't use it, hmmm)
    $tweet{expanded_footer}=~s/&lt;/</isg;
    $tweet{expanded_footer}=~s/&gt;/>/isg;
    $tweet{expanded_footer}=~s/&quot;/\"/isg;
    $tweet{expanded_footer}=~s/\&\#10\;/\n/isg;

    # and the tweet itself
    $i=~s%<p class=".*?tweet-text.*?">(.*?)</p>%%;
    # <h>please resist the urge to sing "Rockin' Robin" here</h>
    $tweet{tweet} = $1;
    # remove inline HTML
    $tweet{tweet}=~s/<.*?>//isg;
    # add to results
    push(@res,{%tweet});
  }

  debug("RES",@res);
  return @res;

}
