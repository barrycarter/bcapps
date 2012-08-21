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
use Fcntl;
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

# warn "TESTING";
# @twitter_tags = ("perl");


for $i (@twitter_tags) {
  # before removing hashtag, create regexp
  push(@regex, $i);
  $i=~s/\#//isg;
}



$phrase = join(",",@twitter_tags);
# TODO: this is absolutely horrible way to check for hashtags
$regex = join("|",@regex);

debug("REGEXP: $regex");

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

# make this nonblocking
fcntl(A,F_SETFL,O_NONBLOCK);

# forever <h>and a day</h>
for (;;) {
  $thunk = <A>;
#  debug("THUNK: $thunk");

  # if we got nothing, sleep a bit
  if ($thunk=~/^\s*$/) {
    # if we've slept too long, we've probably lost connection to curl
    sleep(1);
    if ($sleep++>60) {
      warn("Sleeping $sleep seconds, too long?");
    }
    debug("SLEEP: $sleep seconds");
    next;
  }

  # reset sleep if not sleeping
  $sleep = 0;

  # TODO: don't let non-JSON reply kill the whole program

  # data is in JSON format
  $json = JSON::from_json($thunk);

  # in theory, could do filtering (via source, etc) here

  # TODO: I feel really bad about this next bit (but these are
  # probably the only people I can help, sigh)
  unless ($json->{source}=~/web/i) {next;}

  # getting tired of typing out $json->{text}
  $tweet = $json->{text};

#  unless ($tweet=~/$regex/i) {next;}

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

  $time = strftime("%Y%m%d.%H%M%S", localtime(str2time($json->{created_at})));
  $str = "[$time] <$json->{user}{screen_name} ($json->{user}{name})> $json->{text} [SOURCE: $surl]";

  # remove nonprintables
  $str=~s/[^ -~]//isg;

  print "$str\n\n";
  debug("ALPHA");
  print B "$str\n\n";
  debug("BETA");

  unless ($globopts{nofirefox}) {
    # NOTE: you *cannot* quote the URL inside openURL
    system(qq%/root/build/firefox/firefox -remote 'openURL(https://twitter.com/$json->{user}{screen_name}/status/$json->{id})' 1> /dev/null 2> /dev/null%);
  }

}

close(B);



