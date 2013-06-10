#!/bin/perl

# allows multiple people (not just me) to follow others based on
# individualized interests from the live twitter stream

# NOTE: I use *my* (not clients) *twitter* (not supertweet) id to
# connect to the stream. In other words, I could run this program for
# other people using my twitter username/password, even if I didn't
# want to follow anyone myself

# This file contains lines like:
# user1:pass1:list,of,interests,for,user,1
# user2:pass2:list,of,interests,for,user,2
# NOTE: these are supertweet passwords and I use them to let users
# follow others, NOT to connect to the stream

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# for logging purposes
$|=1;

# program tends to die so I am lazily crontabbing this... however,
# this means I must lock against double run
unless (mylock("bctfs", "lock")) {
  logmsg("LOCKED");
  exit(0);
}

$db = "/usr/local/etc/bc-multi-follow.db";
unless (-s $db) {die "$db: does not exist or empty";}

logmsg("START");

# TODO: if silent too long, check connection

# TODO: unfollow!!!

# TODO: lower this in prod
$cachetime = 30;

# NOTE: not in git directory, since it contains private info
@users = `egrep -v '^#' /home/barrycarter/20130603/users.txt`;

# parse
for $i (@users) {
  unless ($i=~m%^(.*?):(.*?):(.*)$%) {warn "BAD LINE: $i";}
  my($user,$pass,$int) = ($1,$2,$3);
  $pass{$user} = $pass;
  # parse interests
  for $j (split(/\,\s*/,$int)) {
    $interest{lc($j)}{$user} = 1;
  }
  # initialize nextfollowtime (should be unnecessary, but...)
  $nextfollowtime{$user} = 0;
}

# TODO: the fact that I'm loading the entire db here suggests I'm
# doing something wrong (and/or could just use a flat file)
my(@res) = sqlite3hashlist("SELECT * FROM bc_multi_follow", $db);
logmsg("START: $#res+1 rows in database");

for $i (@res) {
  unless ($i->{action} eq "SOURCE_FOLLOWS_TARGET") {next;}
  my($source,$target,$time) = ($i->{source_id},$i->{target_id},$i->{time});
  # we will need 'when followed' for unfollows later
  $alreadyfollowed{$source}{$target}=$time;
  $whenfollowed{$time}{$source}{$target} = 1;
}

# not using this yet, but it will help later
@whenfollowed = sort {$a <=> $b} (keys %whenfollowed);

for $i (@whenfollowed) {
  for $j (keys %{$whenfollowed{$i}}) {
    for $k (keys %{$whenfollowed{$i}{$j}}) {
      debug("$i, $j, $k");
    }
  }
}

# TODO: load list of people each user has followed (and then
# unfollowed) to avoid redundant following

# TODO: people use hashtags a lot less than I expected; consider
# searching for tweets with 'foo' not '#foo' (although that will
# nominally slow down the matching process)

# create filter (apparently adding '#' breaks things, hmmm)
# but %23 works as it should
my($filter) = join(",",(map("%23$_", keys %interest)));
# my($filter) = join(",",keys %interest);

# connect to twitter stream (using MY TWITTER pw, not users supertweet pw)
my($cmd) = "curl -N -s -u $twitter{user}:$twitter{pass} 'https://stream.twitter.com/1/statuses/filter.json?track=$filter&stall_warnings=true&lang=en'";
open(A,"$cmd|");

logmsg("ENTERING MAIN LOOP");

while (<A>) {

  # if no one can follow, sleep
  $now = time();
  # think this sorts blanks improperly?
  @nextfollow = sort {$a <=> $b} values %nextfollowtime;
  $nextfollow = join(", ",@nextfollow);
  logmsg("DEBUG: $nextfollow");
  if ($nextfollow[0] > $now) {
    my($sleep) = $nextfollow[0]-$now;
    logmsg("SLEEP: $sleep seconds until next possible follow");
    sleep($sleep);
  }

  # actual updates occur once an hour
  update_ff();

  unless (/^\{/) {
    logmsg("STREAM: BAD TWEET: #_");
    next;
  }

#  if (++$count > 4) {die "TESTING";}

  %json = %{JSON::from_json($_)};

  # convenience vars
  my($tweet_id, $twit_name, $twit_id, $tweet_body) = 
    ($json{id}, $json{user}{screen_name}, $json{user}{id}, $json{text});

  # log this tweet
  logmsg("\#$tweet_id ($twit_name:$twit_id) $tweet_body");

  # TODO: put entire tweet info into db so we don't lose anything
  # TODO: does this include info about user too? if not, request it?
  my($base64) = encode_base64($_);
  $base64=~s/\s+//isg;

  # find the hashtags and who is interested in them
  %interested = ();
  # NOTE: this is REALLY hideous coding, pretty much me showing off
  my(@hashtags) = @{$json{entities}{hashtags}};

  @hashtagstext = ();
  for $i (@hashtags) {
#    logmsg("\#$tweet_id HASHTAG: $i->{text}");
    push(@hashtagstext, $i->{text});
    map($interested{$_}=lc($i->{text}), keys %{$interest{lc($i->{text})}});
  }
  my($hashtags) = join(", ",@hashtagstext);
  logmsg("\#$tweet_id HASHTAGS: $hashtags");

  # TODO: favor users who have rarer hashtags by sorting by last follow?
#  my(@interested) = keys %interested;
  for $i (randomize([keys %interested])) {
    logmsg("\#$tweet_id HASHTAG: $interested{$i} INTERESTS: $i");

    # can $i follow $twit_id ?

    # putting this in loop would do weird things to 'next', so not doing it
    if ($ff{$i}{friends}{$twit_id}) {
      logmsg("\#$tweet_id $i NOFOLLOW $twit_name:$twit_id (already following)");
      next;
    }

    if ($ff{$i}{followers}{$twit_id}) {
      logmsg("\#$tweet_id $i NOFOLLOW $twit_name:$twit_id (twit already follows)");
      next;
    }

    # TODO: be sure to use/initialize %alreadyfollowed
    if ($alreadyfollowed{$i}{$twit_id}) {
      logmsg("\#$tweet_id $i NOFOLLOW $twit_name:$twit_id (already followed once)");
      next;
    }


    # TODO: move this test higher?
    if ($nextfollowtime{$i} > time()) {
      logmsg("\#$tweet_id $i NOFOLLOW $twit_name:$twit_id (can't follow anyone until $nextfollowtime{$i})");
      next;
    }

    # TODO: if no one can follow due to nextfollowtime, wait until
    # first one who can

    logmsg("\#$tweet_id $i FOLLOW $twit_name:$twit_id ATTEMPT");

    # at this point, we have no excuse not to follow, so let's try it
    my($out,$err,$res) = cache_command2("sleep 1; curl -s -u '$i:$pass{$i}' -d 'user_id=$json{user}{id}' 'http://api.supertweet.net/1.1/friendships/create.json'","age=86400");
 
   # we may put this in db too
    my($base64_reply) = encode_base64($out);
    $base64_reply=~s/\s+//isg;

    # the unknown failure <h>(my nickname in high school!)</h>
    unless ($out=~/^\s*\{/) {
      logmsg("\#$tweet_id $i FOLLOW $twit_name:$twit_id FAIL (response was not JSON): $out");
      next;
    }

    # too many follows
    if ($out=~/You are unable to follow more people at this time/i) {
      logmsg("\#$tweet_id $i FOLLOW $twit_name:$twit_id FAIL (unable to follow more people)");
      $nextfollowtime{$i} = time()+15*60;
      logmsg("\#$tweet_id $i THROTTLED for 15m (until $nextfollowtime{$i})");
      next;
    }

    # the JSON of the reply
    %json_reply = %{JSON::from_json($out)};

    # reply is JSON, but error
    unless ($json_reply{screen_name} eq $twit_name) {
      logmsg("\#$tweet_id $i FOLLOW $twit_name:$twit_id FAIL (bad JSON reply): $out");
      next;
    }

    logmsg("\#$tweet_id $i FOLLOW $twit_name:$twit_id SUCCESS");
    $ff{$i}{friends}{$twit_id} = 1;

    # keep whenfollowed hash and list up to date
    unless ($whenfollowed{$now}) {push(@whenfollowed,$now);}
    $whenfollowed{$now}{$i}{$twit_id} = 1;

    # add to db (using self-computed timestamp to be safe)
    $now = time();
    $query = << "MARK";
INSERT INTO bc_multi_follow 
 (source_id, target_id, target_name, action, time, tweet, follow_reply)
VALUES
 ('$i', '$twit_id', '$twit_name', 'SOURCE_FOLLOWS_TARGET', $now,
  '$base64', '$base64_reply')
MARK
;

    sqlite3($query, $db);

    # only one follow per tweet to avoid 'inbreeding'
    last;
  }
}

# TODO: this function is ugly
sub twitter_friends_followers_ids {
  my($TWITST) = "http://api.supertweet.net/1.1";
  my($which,$user,$pass) = @_;
  my($out,$err,$res);
  my($cursor) = -1;
  my(@res);

  # twitter returns 5K or so results at a time, so loop using "next
  # cursor" age=0 below, since we are now only called from another
  # subroutine that does its own timekeeping
  do {
    ($out,$err,$res) = cache_command2("curl -s -u '$user:$pass' '$TWITST/$which/ids.json?cursor=$cursor'", "age=0");
    my(%hash) = %{JSON::from_json($out)};
    push(@res, @{$hash{ids}});
    $cursor = $hash{next_cursor};
  } until (!$cursor);

  return @res;
}

# logging for this program (auto timestamping)
sub logmsg {
  my($str) = join(" ",@_);
  $str=~s/\s+/ /isg;
  my($date) = strftime("[%Y%m%d.%H%M%S] $str\n",gmtime());
  # this program runs forever so just spew logs to STDOUT for now
  print "$date\n";
}


=item schema

Schema of the twitter follow db for multiple user names:

CREATE TABLE bc_multi_follow (
 source_id BIGINT,
 target_id BIGINT,
 target_name TEXT,
 action TEXT,
 time BIGINT,
 tweet TEXT,
 follow_reply TEXT,
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

=cut

# updates friends/followers every hour (this subroutine is specific to
# this program)

sub update_ff {
  my($now) = time();
  # this allows updates to survive restarting program
  my($lastupdate) = read_file("/var/tmp/bctfs/ff.txt");
  if ($now-$lastupdate<3600) {
    return;
  }

  logmsg("FF: UPDATING");
  # intentionally NOT removing friends/followers, only adding to
  # global %ff hash
  for $i (keys %pass) {
    for $j ("friends","followers") {
      my(@ff) = twitter_friends_followers_ids($j,$i,$pass{$i});
      logmsg("FF: $i has $#ff+1 $j");
      for $k (@ff) {
	$ff{$i}{$j}{$k}=1;
      }
    }
  }

  # and record update
  write_file($now,"/var/tmp/bctfs/ff.txt");
}


