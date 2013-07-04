#!/bin/perl

# unfollows people for stream follow program

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";
require "/home/barrycarter/BCGIT/TWITTER/projectlib.pl";
$unfollowdb = "/usr/local/etc/bc-unfollow.db";
$ffdb = "/var/tmp/bctfs2/ff.db";

$now=time();

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

  print "NEITHER: $i->{rowid}\n";

}


