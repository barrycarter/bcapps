#!/bin/perl

# sample app showing twitter streaming

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# what we're looking for
# note: using big locations for testing, will trim
$data = "track=math+tutor,math+help,geography+help,geography+tutor,\@barrycarter";

open(A,"curl -s -u $twitter{user}:$twitter{pass} 'https://stream.twitter.com/1/statuses/filter.json?$data'|");

while (<A>) {
  debug("RAW: $_");
  if (/^\s*$/s) {
    debug("BLANK MESSAGE");
    next;
  }

  # data is in JSON format
  $json = JSON::from_json($_);

  # filter (TODO: seriously genericize this)
  $FLAG = 0;
  # I don't know what this means, but it doesn't sound good
  if ($json->{text}=~/fuck bitches/i) {$FLAG=1;}
  # to another person and not mentioning me?
  if ($json->{text}=~/^\@/ && $json->{text}!~/barry/i) {$FLAG=1;}
  # this guy's doing what I am
  if ($json->{user}{screen_name}=~/mathtutor01/i) {$FLAG=1;}

#  # for now, just warn
#  if ($FLAG) {warn "Would normally not be shown";}

  if ($FLAG) {next;}

  # create URL specific to user
  my($out,$err,$res) = cache_command("echo http://tutor.u.94y.info/\?$json->{user}{screen_name} | surl");
  print "SURL: $out\n";

  $str = "[$json->{created_at}] ($json->{id} : $json->{in_reply_to_status_id}) <$json->{user}{screen_name}> $json->{text}";

  $time = strftime("%Y%m%d.%H%M%S", localtime(str2time($json->{created_at})));

  $str = "[$time] <$json->{user}{screen_name}> $json->{text}";
  print "$str\n";

  $str=~s/\'//isg;

  system("firefox https://twitter.com/$json->{user}{screen_name}/status/$json->{id}");

  # TODO: have firefox open to tweet directly

#  system("xmessage '$str'&");
}
