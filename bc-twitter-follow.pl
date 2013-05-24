#!/bin/perl

# Obtain twitter followers by following others
# --username: twitter username
# --password: supertweet (NOT TWITTER) password
# --create: create SQLite3 table it it doesn't already exist

# WARNING: Twitter often bans users who use programs like this; use
# with caution

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/BCGIT/bc-twitter.pl";

# get_twits(); die "TESTING";

# twitter is case-insensitive, so lower case username
$globopts{username} = lc($globopts{username});
unless ($globopts{username} && $globopts{password}) {
  die "--username=username --password=password required";
}

# SQL db to store data for this program
$dbname = "/usr/local/lib/bc-twitter-follow/$globopts{username}.db";

# create db if requested (could do this auto, but no)
if ($globopts{create}) {create_db($dbname);}

# die if sqlite3 db doesn't exist or has 0 size
unless (-s $dbname) {
  die("$dbname doesn't exist or is empty; use --create to create");
}

# my friends and followers
# @followers = twitter_friends_followers_ids("followers", $globopts{username}, $globopts{password});
# @friends = twitter_friends_followers_ids("friends", $globopts{username}, $globopts{password});

debug("FRI",@friends);
debug("FOL",@followers);
warn "TESTING";

debug(get_twits(500));

die "TESTING";

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

=item get_twits($n)

Obtain a list of at least $n user ids, starting from the public timeline

NOTE: cant find working public timeline url, using search for 'i'
instead (for now)

=cut

sub get_twits {
  my($n) = @_;
  my(%ids);
  my(@res);
  my($pos)=0;

  # query for "i"
  my($out,$err,$res) = cache_command("curl -s 'https://twitter.com/search?q=i'", "age=300");
  # find all user ids
  while ($out=~s/data-user-id="(\d+)"//is) {$ids{$1}=1;}
  my(@ids) = keys %ids;

  # add new ids until we have enough
  while (@ids) {
    # already have enough?
    if ($#ids > $n) {last;}

    # if not, get first one, and add followers/friends
    my($user) = $ids[$pos++];

#    my(@friends) = twitter_friends_followers_ids("followers", $globopts{username}, $globopts{password});

  debug("IDS",@ids);

  die "TESTING";

  # obtain ids from the public timeline
  # TODO: this unnecessarily excludes friends/followers of people in %hash???
  my(@tweets) = twitter_public_timeline($user,$pass);
  for $i (@tweets) {push(@init, $i->{user}{id});}

  debug("INIT",@init);
  die "TESTING";


  
  my(@res); # result
  my(@init); # list of "seeds" from which I recurse into followers/friends
  unless ($n) {$n=100;}






  # TODO: filter out people in hash!
  
#  debug(@tweets);
}
