#!/bin/perl

# Similar to bc-stream-twitter, this looks for all help requests in
# the twitter stream to see which ones I can respond too

# --justme: only look for tweets to me, don't search for help requests
# --nofirefox: do not open tweets in firefox (useful for "firehose" testing)
# --links=0: if set, don't ignore tweets with links
# --rt=0: if set, don't ignore retweets not involving me
# --mentions=0: if set, don't ignore tweets that mention someone else + not me
# --filter: if set, show only tweets matching this regex

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";
$|=1;

# Don't run two copies
# <h>This computer isn't big enough fir the two of us!</h>
system("pkill seekhelp2");
$0="seekhelp2";

# sources I can't help (TODO: this is just bad)
# %bads = list2hash("http://twitter.com/download/iphone", "http://twitter.com/download/android");

# @twitter_tags is in bc-private.pl and is a list of hashtags (not
# phrases) I used to follow; converting to one big phrase for
# streaming API

# NOTE: twitter limits to 400 track keywords of length 60, don't think
# I'm anywhere near that, so not checking

for $i (@twitter_tags) {$i=~s/\#//isg;}
$phrase = join(",",@twitter_tags);

debug("PHRASE: $phrase");

unless ($globopts{justme}) {
  $data = "lang=en&track=$phrase,\@$twitter{user}";
} else {
  $data = "track=\@$twitter{user}&lang=en";
}

# write to logfile (not root, so can't write to /var/log?)
open(B,">>/var/tmp/log/helpreq2.txt");

my($cmd) = "curl -N -s -u $twitter{user}:$twitter{pass} 'https://stream.twitter.com/1/statuses/filter.json?$data'";
open(A,"$cmd|");

while (<A>) {
  # solely to make sure curl is still running
  debug("THUNK!");
  system("touch /var/tmp/log/helpreq2.txt");

  # ignore blanks
  if (/^\s*$/s) {next;}
  # data is in JSON format
  $json = JSON::from_json($_);

  # find the URL in the source
  $json->{source}=~/<a href="(.*?)"/isg;
  $surl = $1;
  if ($bads{$surl}) {next;}

  # exclude phones (TODO: is this bad?; most twitter traffic is phones?)
  # and iPad because they can't use Flash (argh, Ive become evil!)
  # TODO: this cuts out people I could help incl people w computer qs

  # via twitter for [x] ignores
 # if ($json->{source}=~/^twitter for (android|ipad|iphone)$/i) {next;}

  # other ignores
#  if ($json->{source}=~/^txt$/i) {next;}


  # getting tired of typing out $json->{text}
  $tweet = $json->{text};

  # filter (works even if --filter not set)
  unless ($tweet=~/$globopts{filter}/i) {next;}

  # mentions someone else and not me? ignore
  if ($tweet=~/\@/i && !($tweet=~/$twitter{user}/i) && !$globopts{mentions}) {
    next;
  }

  # same w retweets
  if ($tweet=~/^rt/i && !($tweet=~/$twitter{user}/i) && !$globopts{rt}) {
    next;
  }

  # and hyperlinks
  if ($tweet=~/http/i && !($tweet=~/$twitter{user}/i && !$globopts{links})) {
    next;
  }

  # and these phrases (which I eventually need to not hardcode)
#  if ($tweet=~/inga nielsen|without my cell phone|drama queen|excuse for not having math homework|solve your own problems|when my name\'s on a math problem|stop asking me to find your x|10ReasonsWhyIHateSchool|good friend is like a computer|HowIMetMyBestfriend|mermaid wear to math class|dear 69/i) {next;}

  $time = strftime("%Y%m%d.%H%M%S", localtime(str2time($json->{created_at})));
  $str = "[$time] <$json->{user}{screen_name} ($json->{user}{name})> $json->{text} [SOURCE: $surl]";

  # remove nonprintables
  $str=~s/[^ -~]//isg;

  print "$str\n\n";
  print B "$str\n\n";

  unless ($globopts{nofirefox}) {
    system("/root/build/firefox/firefox https://twitter.com/$json->{user}{screen_name}/status/$json->{id} 1> /dev/null 2> /dev/null");
  }

}

close(B);



