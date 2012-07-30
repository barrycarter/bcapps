#!/bin/perl

# sample app showing twitter streaming

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# what we're looking for
# note: using big locations for testing, will trim
$data = "track=math+tutor,math+help,homework+help,\@barrycarter";

# convert bad twits from priv file (ie, ones I don't want to hear from) to hash
my(%badhash) = list2hash(@badtwitterusers);

# write to logfile (not root, so can't write to /var/log?)
open(B,">>/var/tmp/log/twitstream.txt");

my($cmd) = "curl -s -u $twitter{user}:$twitter{pass} 'https://stream.twitter.com/1/statuses/filter.json?$data'";
debug("CMD: $cmd");
open(A,"$cmd|");

while (<A>) {
#  debug("RAW: $_");
  if (/^\s*$/s) {
#    debug("BLANK MESSAGE");
    next;
  }

  # if over a minute has passed, reload certain files
  if (time()-$time > 60) {
    # reload lists every minute
    # can't require the same file twice, so...
    my($tmp) = my_tmpfile();
    system("cp /home/barrycarter/bc-private.pl $tmp");
    require $tmp;
    $time = time();
  }

  # data is in JSON format
  $json = JSON::from_json($_);

  # must lc here since usernames are case-sensitive
  if ($badhash{lc($json->{user}{screen_name})}) {next;}

  # getting tired of typing out $json->{text}
  $tweet = $json->{text};

  # the list comes from bc-private.pl and includes ^rt to avoid retweets
  $FLAG=0;
  for $i (@badtwitterregex) {
    debug("Comparing $tweet to $i");
    if ($tweet=~/$i/i) {
      debug("MATCH: $i to $tweet, ignoring");
      # this next pushes to the next for $i, not the next while, so we need
      # a temp var
      $FLAG=1;
      next;
    }
  }

  if ($FLAG) {next;}

  # to another person and not mentioning me? (special case, not simple regex)
  if ($tweet=~/^\@/ && $tweet!~/barry/i) {next;}

  # create URL specific to user
  my($out,$err,$res) = cache_command("echo http://tutor.u.94y.info/\?$json->{user}{screen_name} | surl -s is.gd");
  chomp($out);

  $str = "[$json->{created_at}] ($json->{id} : $json->{in_reply_to_status_id}) <$json->{user}{screen_name}> $json->{text}";

  $time = strftime("%Y%m%d.%H%M%S", localtime(str2time($json->{created_at})));

  $str = "[$time] <$json->{user}{screen_name}> $json->{text}";

  # remove nonprintables
  $str=~s/[^ -~]//isg;

  # my signature line
  my($line) = "I might be able to help (free) at: $out (online whiteboard)";

  # "bracket" the tweet (easier when I search file using 'tac')
  print "$line\n$str\n$line\n";
  print B "$line\n$str\n$line\n";

  # must use full path to firefox to avoid rare error
  system("/root/build/firefox/firefox https://twitter.com/$json->{user}{screen_name}/status/$json->{id}");

}
