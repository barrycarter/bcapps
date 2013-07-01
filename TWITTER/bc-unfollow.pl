#!/bin/perl

# unfollows people for stream follow program

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";
require "/home/barrycarter/BCGIT/TWITTER/projectlib.pl";
$unfollowdb = "/usr/local/etc/bc-unfollow.db";
$ffdb = "/var/tmp/bctfs2/ff.db";

$now=time();

# doing these in chunks of 1000 and piping instead of doing via this prog
$query = "SELECT oid,* FROM unfollow WHERE time<$now AND (resolution='' OR resolution IS NULL) LIMIT 1000";
@res = sqlite3hashlist($query,$unfollowdb);

print "BEGIN;\n";

for $i (@res) {
  my($source_id, $target_id) = ($i->{source_id}, $i->{target_id});
  # does source still follow target (if not, can't unfollow, but update db)
  $follow_q = is_ff($source_id, "friends", $target_id);
  unless ($follow_q) {
    $query = "UPDATE unfollow SET resolution='SOURCE_NO_LONGER_FOLLOWS_TARGET' WHERE rowid=$i->{rowid}";
    # TODO: first shot: just going to wrap this into a TRANSACT block
    print "$query;\n";
    next;
  }
}

print "COMMIT;\n";


