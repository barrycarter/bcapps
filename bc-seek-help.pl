#!/bin/perl

# Similar to bc-stream-twitter, this looks for all help requests in
# the twitter stream to see which ones I can respond too

# --justme: only look for tweets to me, don't search for help requests

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";
$|=1;

# Don't run two copies
# <h>This computer isn't big enough fir the two of us!</h>
system("pkill seekhelp2");
$0="seekhelp2";

unless ($globopts{justme}) {
  $data = "track=science,math,perl,sql,trig,algebra,calculus,physics,programming,computer,logic,statistics,database,probability,astronomy,geometry,geography,meteorlogy,\@$twitter{user}&lang=en";
} else {
  $data = "track=\@$twitter{user}&lang=en";
}

# write to logfile (not root, so can't write to /var/log?)
open(B,">>/var/tmp/log/helpreq.txt");

my($cmd) = "curl -N -s -u $twitter{user}:$twitter{pass} 'https://stream.twitter.com/1/statuses/filter.json?$data'";
open(A,"$cmd|");

while (<A>) {
  # ignore blanks
  if (/^\s*$/s) {next;}
  # data is in JSON format
  $json = JSON::from_json($_);

#  debug(unfold($json));
  debug("SOURCE: $json->{source}");

  # exclude phones (TODO: is this bad?; most twitter traffic is phones?)
  # and iPad because they can't use Flash (argh, Ive become evil!)
  # TODO: this cuts out people I could help incl people w computer qs

  # via twitter for [x] ignores
 # if ($json->{source}=~/^twitter for (android|ipad|iphone)$/i) {next;}

  # other ignores
#  if ($json->{source}=~/^txt$/i) {next;}


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

  system("/root/build/firefox/firefox https://twitter.com/$json->{user}{screen_name}/status/$json->{id} 1> /dev/null 2> /dev/null");

}

close(B);



