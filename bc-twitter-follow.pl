#!/bin/perl

# Obtain twitter followers by following others
# --username: twitter username
# --password: supertweet (NOT TWITTER) password
# --create: create SQLite3 table it it doesn't already exist

# WARNING: Twitter often bans users who use programs like this; use
# with caution

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/BCGIT/bc-twitter.pl";

# twitter is case-insensitive, so lower case username
$globopts{username} = lc($globopts{username});
unless ($globopts{username} && $globopts{password}) {
  die "--username=username --password=password required";
}

# SQL db to store data for this program
$dbname = "/usr/local/etc/bc-twitter-follow/$globopts{username}.db";

# create db if requested (could do this auto, but no)
if ($globopts{create}) {create_db($dbname);}

# die if sqlite3 db doesn't exist or has 0 size
unless (-s $dbname) {
  die("$dbname doesn't exist or is empty; use --create to create");
}

# my friends and followers
@followers = twitter_friends_followers_ids("followers", $globopts{username}, $globopts{password});
@friends = twitter_friends_followers_ids("friends", $globopts{username}, $globopts{password});

# no point in following either (friends: already following; followers:
# they're already following you, you get nothing more by following
# them back)
for $i (@friends,@followers) {$donotfollow{$i}=1;}

# won't really follow this many, but good to get
@twits = get_twits(500);

# now to follow and record
for $i (@twits) {
  if ($donotfollow{$i}) {next;}
  if (++$totes>=25) {last;}

  # cache result just to avoid duplicating everything
  my($out,$err,$res) = cache_command("curl -s -u $globopts{username}:$globopts{password} -d 'user_id=$i' 'http://api.supertweet.net/1.1/friendships/create.json'","age=86400");
  debug("OUT: $out, ERR: $err");

  # add to db
  $now = time(); # timestamp does this too, but I don't trust it
  $query = "INSERT INTO bc_twitter_follow (source_id, target_id, action, time)
VALUES ('$globopts{username}', '$i', 'SOURCE_FOLLOWS_TARGET', $now)";
  sqlite3($query,$dbname);
}

=item create_db($file)

Create SQLite3 db in file $file

=cut

sub create_db {
  my($file) = @_;
  local(*A);
  open(A, "|sqlite3 $file");
  print A << "MARK";
CREATE TABLE bc_twitter_follow (
 source_id BIGINT,
 target_id BIGINT,
 action TEXT,
 time BIGINT,
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
#    debug("CURRENTLY HAVE: $#ids ids");
    # already have enough?
    if ($#ids > $n) {last;}

    # if not, get first one, and add followers/friends
    my($user) = $ids[$pos++];

    # my twitter lib is seriously broken and only gets your own
    # friends/followers; below gets friends followers of arbitrary
    # person
    # sleep to avoid getting locked out of supertweet
    my($out,$err,$res) = cache_command("sleep 1; curl -s -u $globopts{username}:$globopts{password} 'http://api.supertweet.net/1.1/friends/ids.json?user_id=$user'","age=60");
    $out=~m/\[(.*?)\]/;
    my($friends) = $1;
    my(@friends) = split(/\,\s*/,$friends);

    # add these to @ids but avoid repeats
    for $i (@friends) {
      if ($ids{$i}) {next;}
#      debug("ADDING $i to IDS list [FRI]");
      push(@ids,$i);
      $ids{$i}=1;
    }

    # same for followers
    my($out,$err,$res) = cache_command("sleep 1; curl -s -u $globopts{username}:$globopts{password} 'http://api.supertweet.net/1.1/followers/ids.json?user_id=$user'","age=60");
    $out=~m/\[(.*?)\]/;
    my($followers) = $1;
    my(@followers) = split(/\,\s*/,$friends);

    # add these to @ids but avoid repeats
    for $i (@followers) {
      if ($ids{$i}) {next;}
#      debug("ADDING $i to IDS list [FOL]");
      push(@ids,$i);
      $ids{$i}=1;
    }
  }

  return @ids;
}

