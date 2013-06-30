#!/bin/perl

# Attempting to get rid of memory bloat $ff hash; this subroutine
# queries the db for ff status, but also checks its fairly recently
# updated. is_ff($source, $type, $target)
# [$type='friend|follower']. Returns -1 on error, +1 on success, 0 on
# failure

require "/usr/local/lib/bclib.pl";

is_ff("barrycarter","followers","123");

sub is_ff {
  my($source,$type,$target) = @_;
  # TODO: globalize this
  my($db) = "/var/tmp/bctfs2/ff.db";
  # when was the db last updated for this $source/$type
  my($query) = "SELECT MIN(timestamp) FROM ff WHERE user='$source' AND type='$type'";
  # TODO: could do the math here in sqlite3, but easier this way?
  my($res) = sqlite3val($query, $db);
  # if no result, error
  unless ($res) {return -1;}
  my($diff) = str2time("$res UTC")-time();
  # distrust results more than an hour old
  if (abs($diff)>3600) {return -1;}
  # now the friend/follower query itself
  $query = "SELECT COUNT(*) FROM ff WHERE user='$source' AND type='$type' AND target='$target'";
  $res = sqlite3val($query,$db);
  # TODO: check for SQLite3 errors
  return $res;
}

