#!/bin/perl

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# TODO: if silent too long, check connection

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

# TODO: lower this in prod
$cachetime = 3600;

# NOTE: not in git directory, since it contains private info
@users = `egrep -v '^#' /home/barrycarter/20130603/users.txt`;

# parse
for $i (@users) {
  unless ($i=~m%^(.*?):(.*?):(.*)$%) {warn "BAD LINE: $i";}
  my($user,$pass,$int) = ($1,$2,$3);
  $pass{$user} = $pass;
  # parse interests
  for $j (split(/\,\s*/,$int)) {
    $interest{$j}{$user} = 1;
  }
}

# friends/followers for each user
for $i (keys %pass) {
  for $j ("friends","followers") {
    my(@ff) = twitter_friends_followers_ids($j,$i,$pass{$i});
    for $k (@ff) {
      $ff{$i}{$j}{$k}=1;
    }
  }
}

# TODO: load list of people each user has followed (and then
# unfollowed) to avoid redundant following

# TODO: people use hashtags a lot less than I expected; consider
# searching for tweets with 'foo' not '#foo' (although that will
# nominally slow down the matching process)

# create filter (apparently adding '#' breaks things, hmmm)
# but %23 works as it should
my($filter) = join(",",(map("%23$_", keys %interest)));
# my($filter) = join(",",keys %interest);

# connect to twitter stream (using MY TWITTER pw, not users supertweet pw)
my($cmd) = "curl -N -s -u $twitter{user}:$twitter{pass} 'https://stream.twitter.com/1/statuses/filter.json?track=$filter'";
open(A,"$cmd|");

while (<A>) {
  unless (/^\{/) {
    debug("NOT JSON, IGNORED: $_");
    next;
  }

  %json = %{JSON::from_json($_)};
  debug("JSON",dump_var("json",{%json}));
  # TODO: put entire tweet info into db so we don't lose anything
  # TODO: does this include info about user too? if not, request it?
  my($base64) = encode_base64($_);

  debug("THUNK: $_",$base64);

  # find the hashtags and who is interested in them
  %interested = ();
  # NOTE: this is REALLY hideous coding, pretty much me showing off
  for $i (@{$json{entities}{hashtags}}) {
    map($interested{$_}=lc($i->{text}), keys %{$interest{lc($i->{text})}});
  }

  # TODO: favor users who have rarer hashtags by sorting by last follow?
#  my(@interested) = keys %interested;
  for $i (randomize([keys %interested])) {
    debug("IKEA: $i");
    debug("$i to follow $json{user}{id} $json{user}{screen_name} for $json{text}, tweet number $json{id}");

    # can $i follow $json{user}{id}?

    # putting this in loop would do weird things to 'next', so not doing it
    if ($ff{$i}{friends}{$json{user}{id}}) {
      debug("$i can't follow $json{user}{id} $json{user}{screen_name}, already following");
      next;
    }

    if ($ff{$i}{followers}{$json{user}{id}}) {
      debug("$i won't follow $json{user}{id} $json{user}{screen_name}, since latter is already following");
      next;
    }

    # TODO: be sure to use/initialize %alreadyfollowed
    if ($alreadyfollowed{$i}{$json{user}{id}}) {
      debug("$i won't follow $json{user}{id} $json{user}{screen_name}; already followed at one point, may or may not be following now");
      next;
    }

    # TODO: if twitter has said "too many follows" (or other reasons),
    # set this variable
    if ($nextfollowtime{$i} > time()) {
      debug("$i won't follow $json{user}{id} $json{user}{screen_name}; can't follow anyone until $nextfollowtime{$i}");
      next;
    }

    debug("$i would follow $json{user}{id} $json{user}{screen_name}");
    die "TESTING";

    # at this point, we have no excuse not to follow, so let's try it
    my($out,$err,$res) = cache_command2("sleep 1; curl -s -u '$i:$pass{$i}' -d 'user_id=$json{user}{id}' 'http://api.supertweet.net/1.1/friendships/create.json'","age=86400");

    # the unknown failure <h>(my nickname in high school!)</h>
    unless ($out=~/^\s*\{/) {
      logmsg("FAIL: follow($i,$json{user}{screen_name}:$json{user}{screen_name}): result not JSON: $out");
      next;
    }

    
    




  }
}

# TODO: this function is ugly
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
  } until (!$cursor);

  return @res;

}
