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

# I have 'curl' symlinked to both 'curl-kill' and 'curl-keep', and an
# external program (bc-daemon-checker.pl) that will kill curl-kill
# instances that run too long, but keep curl-keep instances no matter
# how long they run; since the curl instances here are disposable
# (should be killed), I use 'curl-kill' throughout this program; this
# effectively implements timeouts

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# sleep between calls
$st_sleep = 0.5;

# for logging purposes
$|=1;

# program tends to die so I am lazily crontabbing this... however,
# this means I must lock against double run
unless (mylock("bctfs", "lock")) {
  logmsg("LOCKED");
  exit(0);
}

$db = "/usr/local/etc/bc-multi-follow.db";
# below is updated hourly so its ok that its in a "tmp" directory
$ffdb = "/var/tmp/bctfs2/ff.db";
unless (-s $db && -s $ffdb) {die "$db: does not exist or empty";}

logmsg("START");

# setup (we ignore user interests for now)
parse_users();
# load_db();

# neverending loop
for (;;) {
  $now = time();

  # prioritize users w/ fewest followers, so update hourly
  if ($now-$lastfollowupdate>3600) {
    $lastfollowupdate = $now;
    for $i (sort keys %pass) {
      # below is purely information, we don't use it
      my($numfriends) = count_ff($i, "friends");
      # TODO: handle -1 case better (what if prog start?)
      my($numfollowers) = count_ff($i, "followers");
      if ($numfollowers == -1) {next;}
      $numfollowers{$i} = $numfollowers;
      logmsg("UPDATE: $i has $numfollowers followers ($numfriends friends)");
    }
  }

  # actual updates occur once an hour (update_ff() keeps track)
#  update_ff();

  # get more tweets if I've run out
  unless (@tweets) {@tweets = get_tweets();}
  my($tweet) = shift(@tweets);

  # don't use the same tweet
  if ($seen{$tweet->{tweet_id}}) {next;}
  $seen{$tweet->{tweet_id}} = 1;

  # even cross user, don't follow the same person twice ever (which
  # also avoids following someone who didnt reciprocate) to avoid suspicion
  my($query) = "SELECT COUNT(*) FROM bc_multi_follow WHERE target_id = $tweet->{user_id} AND action='SOURCE_FOLLOWS_TARGET'";
  my($res) = sqlite3val($query,$db);
  if ($res>0) {next;}

  # TODO: filter for English tweets only (can't using HTTP search!)

  # give priority to users with fewer followers
  # this code is hideous, but does work
  for $user (sort {$numfollowers{$a} <=> $numfollowers{$b}} keys %pass) {
    # if user can and successfully follows tweeter, end this loop
    # TODO: while this works, it looks ugly + confusing, codewise
    if (follow_q($user,$tweet) && do_follow($user,$tweet)) {last;}
  }

  # unfollows are now entirely handled by another (as-yet-unwritten) program

  # if no one can follow for a while, sleep
  @nextfollow = sort {$a <=> $b} values %nextfollowtime;
  if ($nextfollow[0] > $now) {
    my($sleep) = $nextfollow[0]-$now;
    logmsg("SLEEP: $sleep seconds until next possible follow");
    sleep($sleep);
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
    ($out,$err,$res) = cache_command2("sleep $st_sleep; curl-kill -s -u '$user:$pass' '$TWITST/$which/ids.json?cursor=$cursor'", "age=0");
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
  # TODO: the fact that I'm loading the entire db here (albeit only
  # certain columns) suggests I'm doing something wrong (and/or could
  # just use a flat file)

  my(@res) = sqlite3hashlist("SELECT source_id,target_id,target_name,action,time,timestamp FROM bc_multi_follow", $db);
  logmsg("START: $#res+1 rows in database");

  for $i (@res) {
    # keep track of screen name
    $screen_name{$i->{target_id}} = $i->{target_name};
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
  logmsg("UNFOLLOW: $i UNFOLLOW $screen_name{$j}:$j ATTEMPT ($msg)");
  # actual drop
  my($out,$err,$res) = cache_command2("sleep $st_sleep; curl-kill -s -u '$i:$pass{$i}' -d 'user_id=$j' 'http://api.supertweet.net/1.1/friendships/destroy.json'","age=86400");
  # record out/err/res in base64 (for db)
  my($out64) = encode_base64("<out>$out</out>\n<err>$err</err>\n<res>$res</res>\n");
  # is reply JSON?
  unless ($out=~/^\s*\{/) {
    logmsg("UNFOLLOW: $i UNFOLLOW $screen_name{$j}:$j FAIL (response was not JSON): $out");
    return 0;
  }
  # look at JSON of reply
  my(%json) = %{JSON::from_json($out)};

  # id must match
  unless ($json{id} == $j) {
    logmsg("UNFOLLOW: $i UNFOLLOW $screen_name{$j}:$j FAIL (id not $j): $out");
    return 0;
  }

  # at this point, successful, so update friends/followers hash + log
  delete $ff{$i}{friends}{$j};
  logmsg("UNFOLLOW: $i UNFOLLOW $json{screen_name}:$j SUCCESS");

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

# under rules of this program, can $i follow the person tweeting
# $tweet?; returns 1 if yes

sub follow_q {
  my($i,$tweet) = @_;

  my($twit_id, $twit_name, $tweet_id) = 
    ($tweet->{user_id}, $tweet->{screen_name}, $tweet->{'tweet_id'});

  # hit follow limit (this is independant of who tweeted)
  if ($nextfollowtime{$i} > time()) {
    logmsg("\#$tweet_id $i NOFOLLOW $twit_name:$twit_id (can't follow anyone until $nextfollowtime{$i})");
    return 0;
    }

  # already following, so no
  if (is_ff($i,"friends",$twit_id)) {
    logmsg("\#$tweet_id $i NOFOLLOW $twit_name:$twit_id (already following)");
    return 0;
  }

  # no point in following follower
  if (is_ff($i,"followers",$twit_id)) {
    logmsg("\#$tweet_id $i NOFOLLOW $twit_name:$twit_id (twit already follows)");
    return 0;
  }

  # no excuse not to follow...
  return 1;
}


# do_follow($i,$tweet,$msg): have $i follow the person who tweeted
# $tweet with log message $msg; returns 0 on fail, 1 on success

sub do_follow {
  my($i,$tweet) = @_;
  my($now) = time();
  my($twit_id, $twit_name, $tweet_id) = 
    ($tweet->{user_id}, $tweet->{screen_name}, $tweet->{'tweet_id'});

  # log attempt
  logmsg("FOLLOW: $i FOLLOW $twit_name:$twit_id ATTEMPT");

  # actual follow (sleep to avoid annoying supertweet)
  my($out,$err,$res) = cache_command2("sleep $st_sleep; curl-kill -s -u '$i:$pass{$i}' -d 'user_id=$twit_id' 'http://api.supertweet.net/1.1/friendships/create.json'","age=86400");

  # record out/err/res in base64 (for db)
  my($out64) = encode_base64("<out>$out</out>\n<err>$err</err>\n<res>$res</res>\n");

  # is reply JSON?
  unless ($out=~/^\s*\{/) {
    logmsg("FOLLOW: $i FOLLOW $twit_name:$twit_id FAIL (response was not JSON): $out");
    return 0;
  }

  # JSON reply stating "too many follows"
  if ($out=~/You are unable to follow more people at this time/i) {
    logmsg("\#$tweet_id $i FOLLOW $twit_name:$twit_id FAIL (unable to follow more people)");

    # TODO: unfollowing means more follows allowed, so waiting n
    # minutes may actually hurt, not help
    $nextfollowtime{$i} = time()+5*60;
    logmsg("\#$tweet_id $i THROTTLED for 5m (until $nextfollowtime{$i})");
    return 0;
  }

  # reply is JSON and not "too many follows"
  # TODO: I should decode JSON even before 'too many follows'
  my(%json) = %{JSON::from_json($out)};

  # id must match
  unless ($json{id} == $twit_id) {
    logmsg("FOLLOW: $i FOLLOW $twit_name:$twit_id FAIL (id not $twit_id): $out");
    return 0;
  }

  # at this point, successful, so update friends/followers db + log
  my($query) = "INSERT INTO ff (user, type, target) VALUES ('$i', 'friends', '$twit_id')";
  sqlite3($query,$db);

  # this is new: insert reminder to unfollow (doing this in separate
  # db because sqlite3 locks entire dbs, not just tables, so this is
  # safer?)
  # below query does make SQLite3 do the math
  $query = "INSERT INTO unfollow (source_id, target_id, time) VALUES
            ('$i', '$twit_id', $now+86400)";
  sqlite3($query,$db);

  logmsg("FOLLOW: $i FOLLOW $twit_name:$twit_id SUCCESS");

  $query = << "MARK";
INSERT INTO bc_multi_follow 
 (source_id, target_id, target_name, action, time, follow_reply)
VALUES
 ('$i', '$twit_id', '$twit_name', 'SOURCE_FOLLOWS_TARGET', $now, '$out64')
MARK
;
  sqlite3($query, $db);
  # TODO: check for sqlite3 errors in above queries too
  # TODO: do this in other places where I make sqlite3 queries
  # we still return 1 on error, since its an SQL error, not follow error
  if ($SQL_ERROR) {logmsg("SQLERROR: $SQL_ERROR");}

  return 1;
}

# Attempting to get rid of memory bloat $ff hash; this subroutine
# queries the db for ff status, but also checks its fairly recently
# updated. is_ff($source, $type, $target)
# [$type='friend|follower']. Returns -1 on error, +1 on success, 0 on
# failure

sub is_ff {
  my($source,$type,$target) = @_;

  unless (freshness_check($source,$type)) {return -1;}

  # now the friend/follower query itself
  $query = "SELECT COUNT(*) FROM ff WHERE user='$source' AND type='$type' AND target='$target'";
  $res = sqlite3val($query,$ffdb);
  if ($SQL_ERROR) {logmsg("SQLERROR: $SQL_ERROR"); return -1;}
  return $res;
}

# counts number of friends/followers for given user (returns -1 on error)
sub count_ff {
  my($source,$type) = @_;

  unless (freshness_check($source,$type)) {return -1;}

  # now the count
  $query = "SELECT COUNT(*) FROM ff WHERE user='$source' AND type='$type'";
  $res = sqlite3val($query,$ffdb);
  if ($SQL_ERROR) {logmsg("SQLERROR: $SQL_ERROR"); return -1;}
  return $res;
}

# checks freshness of ff db for given user and type (ie, "friends" or
# "followers"); returns 0 if db not fresh [or other error], 1 if db is
# fresh (called from other subroutines)

sub freshness_check {
  my($source,$type) = @_;
  # when was the db last updated for this $source/$type
  my($query) = "SELECT MIN(timestamp) FROM ff WHERE user='$source' AND type='$type'";
  # TODO: could do the math here in sqlite3, but easier this way?
  my($res) = sqlite3val($query, $ffdb);
  # if no result, error
  unless ($res) {return 0;}
  # distrust results more than an hour old
  my($diff) = str2time("$res UTC")-time();
  if (abs($diff)>3600) {return 0;}
  return 1;
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

And of the unfollow reminder table (now handled by a separate program); people in this table aren't automatically unfollowed; rather, this is a reminder to check whether to unfollow them or not + update status

CREATE TABLE unfollow (
 source_id BIGINT,
 target_id BIGINT,
 time BIGINT,
 resolution TEXT,
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX i1 ON unfollow(source_id,target_id);

The table above is initially seeded FROM bc-multi-follow.db AS

INSERT IGNORE INTO unfollow 
SELECT source_id,target_id,time+86400 AS time FROM bc_multi_follow
WHERE action='SOURCE_FOLLOWS_TARGET';

=cut

