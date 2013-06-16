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

# list of global hashes this program uses:
#
# $ff{$i}{friends|followers}{$j}: if set, $i is a friend/follower of $j
#
# $pass{$user}: $user's supertweet (not twitter) password
#
# $interest{$keyword}{$i}: if set, $i is interested in $keyword
#
# $nextfollowtime{$user}: next time $user may follow someone (if throttled)
#
# $alreadyfollowed{$user}{$target}: $user once followed $target, but
# perhaps not currently
#
# $whenfollowed{$time}{$user}{$target}: $user followed $target at $time
# @whenfollowed: sorted list of keys %whenfollowed
# when $user unfollows $target, entries are removed from unfollowed hash+list

# TODO: subroutinize properly. Currently, just taking code out of main
# loop and putting it into subroutines almost verbatim (ie, the
# opposite of inlining ... but pretty sure it's not called outlining),
# instead of making things true subroutines

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

# testing now that stream API is broken (will move this into main loop later)
@tweets = get_tweets();

debug(dump_var("tweets",\@tweets));

die "TESTING";

# TODO: if silent too long, check connection

parse_users();
load_db();

# TODO: people use hashtags a lot less than I expected; consider
# searching for tweets with 'foo' not '#foo' (although that will
# nominally slow down the matching process)

# create filter (apparently adding '#' breaks things, but %23 is fine)
my($filter) = join(",",(map("%23$_", keys %interest)));

# TODO: undo!
$globopts{debug}=1;

# connect to twitter stream (using MY TWITTER pw, not users supertweet pw)
my($cmd) = "curl -N -s -u $twitter{user}:$twitter{pass} 'https://stream.twitter.com/1.1/statuses/filter.json?track=$filter&stall_warnings=true&lang=en'";
debug("CMD: $cmd");
open(A,"$cmd|");

warn "TESTING";

while (<A>) {print $_;}

die "TESTING";


logmsg("ENTERING MAIN LOOP");

while (<A>) {

  debug("RAW: $_");

  $now = time();

  # actual updates occur once an hour (update_ff() keeps track)
  update_ff();

  # TODO: find unfollows (unfollows ARE blocked by "no more follows",
  # which is bad)
  # 25h allows for ff to be 1hr behind

  # we only unfollow one person per loop, but need 'while' to find that person
WHILE:  while ($whenfollowed[0] < $now-25*3600) {
    # we look at each timestamp once, but maintain %whenfollowed hash
    # so we won't try to re-follow someone we dropped for not
    # reciprocating
    my($drop) = shift(@whenfollowed);
    for $i (keys %{$whenfollowed{$drop}}) {
      for $j (keys %{$whenfollowed{$drop}{$i}}) {
	if (unfollow_q($i,$j)) {
	  do_unfollow($i,$j, "did not reciprocate follow at $drop");
	  # drop out of while loop
	  last WHILE;
	}
      }
    }
  }

  die "TESTING";

  # if everyone is throttled, sleep
  @nextfollow = sort {$a <=> $b} values %nextfollowtime;
  if ($nextfollow[0] > $now) {
    my($sleep) = $nextfollow[0]-$now;
    logmsg("SLEEP: $sleep seconds until next possible follow");
    sleep($sleep);
  }

  parse_tweet($_);

#  if (++$count > 4) {die "TESTING";}

  %json = %{JSON::from_json($_)};


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
# this program); also writes to file for debugging

sub update_ff {
  my($now) = time();

  # when this subroutine was last run
  my($lastupdate) = read_file("/var/tmp/bctfs/ff.txt");

  # if less than an hour ago, and in this instance (ie, %ff is
  # defined), do nothing
  if ($now-$lastupdate<3600 && %ff) {return;}

  logmsg("FF: UPDATING");
  # intentionally NOT removing friends/followers, only adding to
  # global %ff hash
  for $i (keys %pass) {
    for $j ("friends","followers") {
      my(@ff);
      # if less than an hour ago, but in different instance, load from files
      if ($now-$lastupdate<3600 && -f "/var/tmp/bctfs/$i-$j.txt") {
	@ff = split(/\n/, read_file("/var/tmp/bctfs/$i-$j.txt"));
	logmsg("FF: $i has $#ff+1 $j (cached)");
      } else {
	@ff = twitter_friends_followers_ids($j,$i,$pass{$i});
	# write these to file
	write_file(join("\n",@ff)."\n","/var/tmp/bctfs/$i-$j.txt");
	logmsg("FF: $i has $#ff+1 $j (not cached)");
      }

      for $k (@ff) {
	$ff{$i}{$j}{$k}=1;
      }
    }
  }

  # and record update
  write_file($now,"/var/tmp/bctfs/ff.txt");
}

# parse users

sub parse_users {
  # NOTE: not in git directory, since it contains private info
  # users is not a global, but the hashes below are
  my(@users) = `egrep -v '^#' /home/barrycarter/20130603/users.txt`;

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
}

# loads the db, indicating who has followed whom and whence
sub load_db {
  # TODO: the fact that I'm loading the entire db here suggests I'm
  # doing something wrong (and/or could just use a flat file)
  my(@res) = sqlite3hashlist("SELECT * FROM bc_multi_follow", $db);
  logmsg("START: $#res+1 rows in database");

  for $i (@res) {
    # TODO: perhaps only select these rows?
    # TODO: use unfollows somehow?
    unless ($i->{action} eq "SOURCE_FOLLOWS_TARGET") {next;}
    my($source,$target,$time) = ($i->{source_id},$i->{target_id},$i->{time});
    # we will need 'when followed' for unfollows later
    $alreadyfollowed{$source}{$target}=$time;
    $whenfollowed{$time}{$source}{$target} = 1;
  }

  @whenfollowed = sort {$a <=> $b} (keys %whenfollowed);
}

# parses a given tweet (and updates global variables), returning 0 if
# tweet is unparseable
sub parse_tweet {
  my($tweet) = @_;

  # not JSON? no good
  unless ($tweet=~/^\s*\{/) {
    logmsg("STREAM: BAD TWEET: $tweet");
    return 0;
  }

  # %json is global
  %json = %{JSON::from_json($_)};

  # convenience vars (also global)
  ($tweet_id, $twit_name, $twit_id, $tweet_body) = 
    ($json{id}, $json{user}{screen_name}, $json{user}{id}, $json{text});

  # log this tweet
  logmsg("\#$tweet_id ($twit_name:$twit_id) $tweet_body");

  # TODO: put entire tweet info into db so we don't lose anything
  # TODO: does this include info about user too? if not, request it?
  $base64 = encode_base64($_);
  $base64=~s/\s+//isg;
}

# under rules of this program, can $i unfollow $j?; returns 1 if yes
sub unfollow_q {
  my($i,$j) = @_;

  # is $i following $j at all?
  unless ($ff{$i}{friends}{$j}) {
    debug("$i can't unfollow $j: not following");
    return 0;
  }

  # have they reciprocated? (if yes, don't drop?)
  # TODO: could have an "evil" option to drop anyway
  if ($ff{$i}{followers}{$j}) {
    debug("$i follow reciprocated by $j (so not dropping)");
    return 0;
  }

  # no excuse not to unfollow...
  return 1;
}

# do_unfollow($i,$j,$msg): have $i unfollow $j with log message $msg;
# returns 0 on fail, 1 on success

sub do_unfollow {
  my($i,$j,$msg) = @_;

  # log attempt
  logmsg("UNFOLLOW: $i UNFOLLOW $j ATTEMPT ($msg)");
  # actual drop
  my($out,$err,$res) = cache_command2("sleep 1; curl -s -u '$i:$pass{$i}' -d 'user_id=$j' 'http://api.supertweet.net/1.1/friendships/destroy.json'","age=86400");
  # record out/err/res in base64 (for db)
  my($out64) = encode_base64("<out>$out</out>\n<err>$err</err>\n<res>$res</res>\n");
  # is reply JSON?
  unless ($out=~/^\s*\{/) {
    logmsg("UNFOLLOW: $i UNFOLLOW $j FAIL (response was not JSON): $out");
    return 0;
  }
  # look at JSON of reply
  my(%json) = %{JSON::from_json($out)};

  # id must match
  unless ($json{id} == $j) {
    logmsg("UNFOLLOW: $i UNFOLLOW $j FAIL (id not $j): $out");
    return 0;
  }

  # at this point, successful, so update friends/followers hash + log
  delete $ff{$i}{friends}{$j};
  logmsg("UNFOLLOW: $i UNFOLLOW $j:$json{screen_name} SUCCESS");

  my($query) = << "MARK";
INSERT INTO bc_multi_follow 
 (source_id, target_id, target_name, action, time, follow_reply)
VALUES
 ('$i', '$j', '$json{screen_name}', 'SOURCE_UNFOLLOWS_TARGET', $now, '$out64')
MARK
;
  sqlite3($query, $db);
  # TODO: do this in other places where I make sqlite3 queries
  # we still return 1 on error, since its an SQL error, not unfollow error
  if ($SQL_ERROR) {logmsg("SQLERROR: $SQL_ERROR");}

  return 1;
}

# obtain tweets using twitter's HTTP search stream (since they shut
# down basic auth stream API, the fish poops [aka bass turds])

sub get_tweets {
  my(@res);
  # TODO: currently hardcoding to find followbackers, not by keyword
  my($keyword)=urlencode("#teamfollowback OR #autofollowback OR #followback");
#  my($url) = "http://twitter.com/search?q=$keyword";
  my($url) = "http://twitter.com/search/realtime?q=$keyword";
  # TODO: reduce 3600 to 0 when not testing
  my($out,$err,$res) = cache_command2("curl -NL '$url'","age=3600");
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



