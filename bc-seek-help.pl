#!/bin/perl

# Similar to bc-stream-twitter, this looks for all help requests in the twitter stream to see which ones I can respond too

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";
$|=1;

$data = "track=science,math,perl,sql,trig,algebra,calculus,physics,programming,computer,logic,statistics,database,probability,astronomy,geometry,geography,meteorlogy&lang=en";

# write to logfile (not root, so can't write to /var/log?)
open(B,">>/var/tmp/log/helpreq.txt");

my($cmd) = "curl -N -s -u $twitter{user}:$twitter{pass} 'https://stream.twitter.com/1/statuses/filter.json?$data'";
open(A,"$cmd|");

while (<A>) {
  # ignore blanks
  if (/^\s*$/s) {next;}
  # data is in JSON format
  $json = JSON::from_json($_);

  # getting tired of typing out $json->{text}
  $tweet = $json->{text};

  # help reqs only
  unless ($tweet=~/(help|tutor|homework|problem|study|question|assign|student|class|desparate)/i) {next;}

  # mentions someone else and not me? ignore
  if ($tweet=~/\@/i && !($tweet=~/barry/i)) {next;}

  # same w retweets
  if ($tweet=~/^rt/i && !($tweet=~/barry/i)) {next;}

  # and hyperlinks
  if ($tweet=~/http/i && !($tweet=~/barry/i)) {next;}

  $time = strftime("%Y%m%d.%H%M%S", localtime(str2time($json->{created_at})));
  $str = "[$time] <$json->{user}{screen_name} ($json->{user}{name})> $json->{text}";

  # remove nonprintables
  $str=~s/[^ -~]//isg;

  print "$str\n\n";
  print B "$str\n\n";
}

close(B);



