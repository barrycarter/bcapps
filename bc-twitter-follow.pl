#!/bin/perl

# Obtain twitter followers by following others
# --username: twitter username
# --password: supertweet (NOT TWITTER) password
# --create: create SQLite3 table it it doesn't already exist

# WARNING: Twitter often bans users who use programs like this; use
# with caution

require "bclib.pl";
require "bc-twitter.pl";

# twitter is case-insensitive, so lower case username
$globopts{username} = lc($globopts{username});
unless ($globopts{username} && $globopts{password}) {
  die "--username=username --password=password required";
}

# SQL db to store data for this program
$dbname = "$ENV{HOME}/bc-twitter-follow-$globopts{username}.db";

# die if sqlite3 db doesn't exist or has 0 size
unless (-s $dbname) {
  unless ($globopts{create}) {
    die("$dbname doesn't exist or is empty; use --create to create");
  } else {
    create_db("$dbname.db");
  }
}

# my friends and followers
@followers = twitter_friends_followers_ids("followers", $globopts{username}, $globopts{password});
@friends = twitter_friends_followers_ids("friends", $globopts{username}, $globopts{password});

# people who follow me, but I don't followback
@tofollow = minus(\@followers, \@friends);

# not sure reciprocality is useful, but it's polite
for $i (@tofollow) {
  debug("FOLLOWING: $i");
  twitter_follow($i, $globopts{username}, $globopts{password});
  # below to avoid slamming twitter/supertweet API
  sleep(1);
}

die "TESTING";

debug(@tofollow);

# debug(@followers);
# debug(@friends);

die "TESTING";
debug("ALPHA");
debug(@followers);

# NOTE: I'm copying this from a much longer program that does a lot more!

=item create_db($file)

Create SQLite3 db in file $file

=cut

sub create_db {
  my($file) = @_;
  local(*A);
  open(A, "|sqlite3 $file");
  print A << "MARK";
CREATE TABLE bc_twitter_follow (
 userid BIGINT,
 -- action is one of 'FOLLOW','UNFOLLOW','BLOCKED','FOLLOWED','UNFOLLOWED'
 action TEXT,
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
MARK
;
  close(A);
}

