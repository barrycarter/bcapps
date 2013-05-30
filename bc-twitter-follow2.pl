#!/bin/perl

# Obtain twitter followers by following others
# --username: twitter username
# --password: supertweet (NOT TWITTER) password
# --create: create SQLite3 table it it doesn't already exist

# v2: adds unfollows and never re-follows initial attempts

# WARNING: Twitter often bans users who use programs like this; use
# with caution

require "/usr/local/lib/bclib.pl";

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

# people Ive already (tried to) followed
# TODO: loading the whole db here seems inefficient
@db = sqlite3hashlist("SELECT * FROM bc_twitter_follow ORDER BY time", $dbname);

# do not try to refollow people i have followed, even if i unfollowed them
for $i (@db) {
  if ($i->{action}=~/SOURCE_FOLLOWS_TARGET/i) {
    # we will use time of follow later
    $alreadyfollowed{$i->{target_id}}=$i->{time};
  }
}

# my friends and followers (NOT using bc-twitter.pl)
@followers = twitter_friends_followers_ids("followers", $globopts{username}, $globopts{password});
@friends = twitter_friends_followers_ids("friends", $globopts{username}, $globopts{password});

# no point in following either (friends: already following; followers:
# they're already following you, you get nothing more by following
# them back)
for $i (@friends) {$friends{$i}=1;}
for $i (@followers) {$followers{$i}=1;}

# won't really follow this many, but good to get
@twits = get_twits(500);

debug("TWITS",@twits);

die "TESTING";

# now to follow and record
for $i (@twits) {
  if ($donotfollow{$i}) {next;}
  if (++$totes>=25) {last;}

  # cache result just to avoid duplicating everything
  my($out,$err,$res) = cache_command2("curl -s -u '$globopts{username}:$globopts{password}' -d 'user_id=$i' 'http://api.supertweet.net/1.1/friendships/create.json'","age=86400");
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
  my($out,$err,$res) = cache_command2("curl -s 'https://twitter.com/search?q=i'", "age=60");
  # find all user ids
  debug("OUT: $out");
  while ($out=~s/data-user-id="(\d+)"//is) {$ids{$1}=1;}
  my(@ids) = keys %ids;

  # add new ids until we have enough
  while (@ids) {
    # already have enough?
    if ($#ids > $n) {last;}

    # if not, get first one, and add followers/friends
    my($user) = $ids[$pos++];

    # sleep to avoid getting locked out of supertweet
    my($out,$err,$res) = cache_command2("sleep 1; curl -s -u '$globopts{username}:$globopts{password}' 'http://api.supertweet.net/1.1/friends/ids.json?user_id=$user'","age=60");
    $out=~m/\[(.*?)\]/;
    my($friends) = $1;
    my(@friends) = split(/\,\s*/,$friends);

    # add these to @ids but avoid repeats
    for $i (@friends) {
      if ($ids{$i}) {next;}
      push(@ids,$i);
      $ids{$i}=1;
    }

    # same for followers
    my($out,$err,$res) = cache_command2("sleep 1; curl -s -u '$globopts{username}:$globopts{password}' 'http://api.supertweet.net/1.1/followers/ids.json?user_id=$user'","age=60");
    $out=~m/\[(.*?)\]/;
    my($followers) = $1;
    my(@followers) = split(/\,\s*/,$followers);

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

=item twitter_friends_followers_ids($which="friends|followers"$user,$pass)

NOTE: I COPIED/MODIFIED THIS FROM bc-twitter.pl which I expect to stop using

Obtain friends/followers ids for $user (auth required)

NOTE: Twitter lets you get friends/followers for others, but not via
id-- weird?

=cut

sub twitter_friends_followers_ids {
  my($TWITST) = "http://api.supertweet.net/1.1";
  my($which,$user,$pass) = @_;
  my($out,$err,$res);
  my($cursor) = -1;
  my(@res);

  # twitter returns 5K or so results at a time, so loop using "next cursor"
  do {
    ($out,$err,$res) = cache_command2("curl -s -u '$user:$pass' '$TWITST/$which/ids.json?cursor=$cursor'", "age=60");
    my(%hash) = %{JSON::from_json($out)};
    push(@res, @{$hash{ids}});
    $cursor = $hash{next_cursor};
    debug("CURSOR: $cursor, RES: $#res");
  } until (!$cursor);

  return @res;

}

