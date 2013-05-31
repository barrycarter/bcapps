#!/bin/perl

# Obtain twitter followers by following others
# --username: twitter username
# --password: supertweet (NOT TWITTER) password
# --create: create SQLite3 table it it doesn't already exist

# v2: adds unfollows and never re-follows initial attempts

# WARNING: Twitter often bans users who use programs like this; use
# with caution

# <h>I wish to apologize to all people my age for using $totes and
# $peeps as variables</h>

require "/usr/local/lib/bclib.pl";

# cache for most (not all) curl commands (60 for prod, 300/600 for testing)
$cachetime = 60;

# how many people to follow/unfollow every time this program is run
# numbers should almost equal each other to avoid backlog
# TODO: make this a cmd line option
# temporarily lowered to 1 as beta testers run out of follow perms
$follow_number = 55;
$unfollow_number = 55;

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

# my friends and followers
# no point in following either (friends: already following; followers:
# they're already following you, you get nothing more by following
# them back)
%followers = list2hash(twitter_friends_followers_ids("followers", $globopts{username}, $globopts{password}));
%friends = list2hash(twitter_friends_followers_ids("friends", $globopts{username}, $globopts{password}));

# just for reporting purposes (which means I pretty much broke earlier
# code and fixed it wrong, yay!)
@friends = sort keys %friends;
@followers = sort keys %followers;

logmsg("INFO: $globopts{username} follows $#friends+1 people");
logmsg("INFO: $globopts{username} has $#followers+1 followers");

# won't really follow this many, but good to get
@twits = get_twits(500);

# find peeps to follow
for $i (@twits) {
  # people to not follow
  if ($friends{$i} || $followers{$i} || $alreadyfollowed{$i}) {next;}
  if (++$totes>=$follow_number) {last;}
  push(@tofollow, $i);
}

# get some (fairly constant) info on these users
# it turns out we get this info when following anyway, but makes a
# great double check
$tofollow=join(",",@tofollow);
my($out,$err,$res) = cache_command2("curl -s -u '$globopts{username}:$globopts{password}' 'http://api.supertweet.net/1.1/users/lookup.json?user_id=$tofollow'","age=86400");
@json = @{JSON::from_json($out)};
# lots of good info here, but I just record the screen name
for $i (@json) {$name{$i->{id}} = $i->{screen_name};}

# now, to actually follow
for $i (@tofollow) {
  # sleep to avoid annoying supertweet
  my($out,$err,$res) = cache_command2("sleep 1; curl -s -u '$globopts{username}:$globopts{password}' -d 'user_id=$i' 'http://api.supertweet.net/1.1/friendships/create.json'","age=86400");

  # result not JSON? follow failed
  unless ($out=~/^\s*\{/) {
    logmsg("FAIL: follow($i:$name{$i}): result not JSON: $out");
    next;
  }

  # cant do this wo making sure result is JSON; program ends otherwise
  %json = %{JSON::from_json($out)};
  # screen names do not match? error!
  unless ($json{screen_name} eq $name{$i}) {
    logmsg("FAIL: follow($i:$name{$i}): bad JSON: $out");
    if ($out=~/You are unable to follow more people at this time/i) {
      logmsg("You cannot follow more people, ending follow loop early");
      last;
    }
    next;
  }

  # success!
  logmsg("SUCC: follow($i:$name{$i})");
  # add to db (using self-computed timestamp to be safe)
  $query = << "MARK";
INSERT INTO bc_twitter_follow
(source_id, target_id, action, time, target_name) VALUES
('$globopts{username}', '$i', 'SOURCE_FOLLOWS_TARGET', $now, '$name{$i}')
MARK
;
  sqlite3($query,$dbname);
}

# and now the unfollows
# TODO: write query for this, dont go thru entire db
for $i (@db) {
  # if less than 72 hours, ignore all from now on (since time-ordered)
  # using $now from above
  # TODO: let '3' be a parameter
  if ($now-$i->{time}<86400*3) {last;}

  # if not following, cant unfollow
  unless ($friends{$i->{target_id}}) {next;}

  # if they are following me, shouldnt unfollow
  # TODO: add --cruel option since some people keep following even
  # after unfollowed
  if ($followers{$i->{target_id}}) {next;}

  # left with: people i followed 3+ days ago, have not followed back
  push(@unfollow,$i->{target_id});
  # never unfollow more than $unfollow_number at a time
  if ($#unfollow>$unfollow_number) {last;}

}

# and now to actually unfollow
for $i (@unfollow) {
  # sleep to avoid annoying supertweet
  my($out,$err,$res) = cache_command2("sleep 1; curl -s -u '$globopts{username}:$globopts{password}' -d 'user_id=$i' 'http://api.supertweet.net/1.1/friendships/destroy.json'","age=86400");
  # result not JSON? unfollow failed
  unless ($out=~/^\s*\{/s) {
    logmsg("FAIL: unfollow($i): result not JSON: *$out*");
    next;
  }

  # cant do this wo making sure result is JSON; program ends otherwise
  %json = %{JSON::from_json($out)};
  # screen names do not match? error!
#  unless ($json{screen_name} eq $name{$i}) {
#    logmsg("FAIL: follow($i:$name{$i}): bad JSON: $out");
#    next;
#  }

  # success!
  logmsg("SUCC: unfollow($i:$json{screen_name})");
  # add to db (using self-computed timestamp to be safe)
  $query = << "MARK";
INSERT INTO bc_twitter_follow
(source_id, target_id, action, time, target_name) VALUES
('$globopts{username}', '$i', 'SOURCE_UNFOLLOWS_TARGET', $now, '$json{screen_name}')
MARK
;
  sqlite3($query,$dbname);
}

$logs = join("\n",@logs);

# email
if ($globopts{email}) {
  sendmail("tweety\@barrycarter.info", $globopts{email}, "bc-twitter-follow log ($globopts{username})", $logs);
}

# the end-user log (without all my crappy debugging statements)
sub logmsg {
  my($str) = join(" ",@_);
  $str=~s/\s+/ /isg;
  my($date) = strftime("[%Y%m%d.%H%M%S] $str\n",gmtime());
  push(@logs,$date);
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
 target_name TEXT,
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
  my($out,$err,$res) = cache_command2("curl -s 'https://twitter.com/search?q=i'", "age=$cachetime");
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

    for $j ("friends","followers") {
      # sleep to avoid getting locked out of supertweet
      my($out,$err,$res) = cache_command2("sleep 1; curl -s -u '$globopts{username}:$globopts{password}' 'http://api.supertweet.net/1.1/$j/ids.json?user_id=$user'","age=$cachetime");
    $out=~m/\[(.*?)\]/;
      my($peeps) = $1;
      my(@peeps) = split(/\,\s*/,$peeps);

      # add these to @ids but avoid repeats
      # TODO: create a ordered hash class/function?
      for $i (@peeps) {
	if ($ids{$i}) {next;}
	push(@ids,$i);
	$ids{$i}=1;
      }
    }
  }
  return @ids;
}

=item twitter_friends_followers_ids($which="friends|followers",$user,$pass)

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
    ($out,$err,$res) = cache_command2("curl -s -u '$user:$pass' '$TWITST/$which/ids.json?cursor=$cursor'", "age=$cachetime");
    my(%hash) = %{JSON::from_json($out)};
    push(@res, @{$hash{ids}});
    $cursor = $hash{next_cursor};
    debug("CURSOR: $cursor, RES: $#res");
  } until (!$cursor);

  return @res;

}
