#!/bin/perl

# unfollows people for stream follow program

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";
require "/home/barrycarter/BCGIT/TWITTER/projectlib.pl";
$db = "/usr/local/etc/bc-multi-follow.db";
$unfollowdb = "/usr/local/etc/bc-unfollow.db";
$ffdb = "/var/tmp/bctfs2/ff.db";

$now=time();
$st_sleep = 1;
parse_users();

$query = "SELECT oid,* FROM unfollow WHERE time<$now AND (resolution='' OR resolution IS NULL)";
@res = sqlite3hashlist($query,$unfollowdb);

for $i (@res) {
  my($source_id, $target_id) = ($i->{source_id}, $i->{target_id});

  # does source still follow target (if not, can't unfollow, but update db)
  $follow_q = is_ff($source_id, "friends", $target_id);
  unless ($follow_q) {
    $query = "UPDATE unfollow SET resolution='SOURCE_NO_LONGER_FOLLOWS_TARGET' WHERE rowid=$i->{rowid}";
    sqlite3($query,$unfollowdb);
    # this is really just a debugging statement
    print "NOLONGERFOLLOWS: $i->{rowid}\n";
    next;
  }

  # has target followed back (if yes, no need to unfollow)
  $follower_q = is_ff($source_id, "followers", $target_id);
  if ($follower_q) {
    $query = "UPDATE unfollow SET resolution='TARGET_FOLLOWEDBACK_SOURCE' WHERE rowid=$i->{rowid}";
    sqlite3($query,$unfollowdb);
    # this is really just a debugging statement
    print "FOLLOWBACK: $i->{rowid}\n";
    next;
  }

  do_unfollow($source_id,$target_id,"did not reciprocate follow at $i->{time}-86400");
  sqlite3("UPDATE unfollow SET resolution='SOURCE_UNFOLLOWS_TARGET' WHERE rowid=$i->{rowid}",$unfollowdb);
}

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

