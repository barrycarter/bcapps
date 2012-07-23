#!/bin/perl

# sample app showing twitter streaming

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# what we're looking for
# note: using big locations for testing, will trim
$data = "track=math+tutor,math+help,homework+help,\@barrycarter";

# write to logfile (not root, so can't write to /var/log?)
open(B,">>/var/tmp/log/twitstream.txt");

open(A,"curl -s -u $twitter{user}:$twitter{pass} 'https://stream.twitter.com/1/statuses/filter.json?$data'|");

while (<A>) {
  debug("RAW: $_");
  if (/^\s*$/s) {
    debug("BLANK MESSAGE");
    next;
  }

  # if over a minute has passed, reload certain files (currently: none)
  if (time()-$time > 60) {
    # do stuff here
    print "Minute to win it\n";
    $time = time();
  }

  # data is in JSON format
  $json = JSON::from_json($_);

  # getting tired of typing out $json->{text}
  $tweet = $json->{text};

  # the list comes from bc-private.pl and includes ^rt to avoid retweets
  for $i (@badtwitterregex) {
    if ($tweet=~/$i/) {
      debug("MATCH: $i to $tweet, ignoring");
      next;
    }
  }

  # ignore RTs (we catch them the first time)
  if ($tweet=~/^rt/i) {next;}

  # filter (TODO: seriously genericize this)
  $FLAG = 0;
  # I don't know what this means, but it doesn't sound good
  if ($json->{text}=~/fuck bitches/i) {$FLAG=1;}
  # to another person and not mentioning me?
  if ($json->{text}=~/^\@/ && $json->{text}!~/barry/i) {$FLAG=1;}
  # sick to death of hearing about "911 kid"
  if ($json->{text}=~/calls 911/i) {$FLAG=1;}
  # and SONA2012
  if ($json->{text}=~/sona2012/i) {$FLAG=1;}
  # and hungry dolphins (seriously need to generalize this!)
  if ($json->{text}=~/hungry dolphin/i) {$FLAG=1;}
  # this guy's doing what I am
  if ($json->{user}{screen_name}=~/mathtutor01/i) {$FLAG=1;}

  # TODO: handle RTs (for both filtering and username-specification)
  if ($FLAG) {next;}

  # create URL specific to user
  my($out,$err,$res) = cache_command("echo http://tutor.u.94y.info/\?$json->{user}{screen_name} | surl");
  chomp($out);

  $str = "[$json->{created_at}] ($json->{id} : $json->{in_reply_to_status_id}) <$json->{user}{screen_name}> $json->{text}";

  $time = strftime("%Y%m%d.%H%M%S", localtime(str2time($json->{created_at})));

  $str = "[$time] <$json->{user}{screen_name}> $json->{text}";
  print "$str\n";
  print B "$str\n";

  # my signature line
  print "Free live help at $out (online whiteboard)\n";
  print B "Free live help at $out (online whiteboard)\n";

  $str=~s/\'//isg;

  system("firefox https://twitter.com/$json->{user}{screen_name}/status/$json->{id}");

}
