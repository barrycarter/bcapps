#!/bin/perl

# splitting follow program into smaller, independent programs to make
# things easier. This one updates friends/followers for people using
# program, with slight improvements and checking

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";
$apihome = "http://api.supertweet.net/1.1";

# get info on all users
my(@users) = `egrep -v '^#' /home/barrycarter/20130603/users.txt|sed s/:.*//`;
$users = join(",",@users);
$users=~s/\s//isg;
warn("using age=3600 for testing only");
my($out,$err,$res) = cache_command2("curl -u $supertweet{user}:$supertweet{pass} $apihome/users/lookup.json?screen_name=$users","age=3600");
@users = @{JSON::from_json($out)};

for $i (@users) {
  my($user) = lc($i->{screen_name});
  for $j ("friends", "followers") {
    twitter_friends_followers_ids

  # we only really care about followers_count and friends_count, but...
  $userinfo{lc($i->{screen_name})} = $i;
  

}

debug($userinfo{barrycarter}{followers_count});

die "TESTING";

# TODO: this function is ugly
sub twitter_friends_followers_ids {
  my($TWITST) = "http://api.supertweet.net/1.1";
  my($which,$user,$pass) = @_;
  my($out,$err,$res);
  my($cursor) = -1;
  my(@res);

  # twitter returns 5K or so results at a time, so loop using "next
  # cursor" age=0 below, since we are now only called from another
  # subroutine that does its own timekeeping
  do {
    warn("age=3600 during testing only");
    ($out,$err,$res) = cache_command2("sleep $st_sleep; curl -s -u '$user:$pass' '$TWITST/$which/ids.json?cursor=$cursor'", "age=3600");
    my(%hash) = %{JSON::from_json($out)};
    push(@res, @{$hash{ids}});
    $cursor = $hash{next_cursor};
  } until (!$cursor);

  return @res;
}

