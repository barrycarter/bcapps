#!/bin/perl

# splitting follow program into smaller, independent programs to make
# things easier. This one updates friends/followers for people using
# program, with slight improvements and checking

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";
$apihome = "http://api.supertweet.net/1.1";
$db = "/var/tmp/bctfs2/ff.db";

# make changes to new copy only
system("cp $db $db.new");

# get info on all users
parse_users();
$users = join(",",sort keys %pass);
$users=~s/\s//isg;
my($out,$err,$res) = cache_command2("curl -u $supertweet{user}:$supertweet{pass} $apihome/users/lookup.json?screen_name=$users","age=0");
@users = @{JSON::from_json($out)};

for $i (@users) {
  my($user) = lc($i->{screen_name});
  debug("$user -> $pass{$user}");

  for $j ("friends", "followers") {
    my(@res) = twitter_friends_followers_ids($j, $user, $pass{$user});
    # compare size to expected size
    my($expected) = $i->{"${j}_count"};
    # slight variation possible
    # 25 seems large, but appears to be necessary?
    # TODO: figure out why I need 25 below
    if (abs($expected-($#res+1)) > 25) {
      # TODO: insert some retries here
      warn("Could not update $j for $user ($expected vs $#res), skipping");
      next;
    }

    # and now the SQL
    local(*A);
    open(A,">/var/tmp/bctfs2/update-$user-$j.txt");
    print A "BEGIN;\n";
    print A "DELETE FROM ff WHERE user='$user' AND type='$j';\n";
    for $k (@res) {
      print A "INSERT INTO ff (user, type, target) VALUES ('$user', '$j', '$k');\n";
    }
    print A "END;\n";
    close(A);
    system("sqlite3 $db.new < /var/tmp/bctfs2/update-$user-$j.txt");
  }
}

# and safe move
system("mv $db $db.old; mv $db.new $db");

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
    ($out,$err,$res) = cache_command2("sleep 1; curl -s -u '$user:$pass' '$TWITST/$which/ids.json?cursor=$cursor'", "age=0");
    my(%hash) = %{JSON::from_json($out)};
    push(@res, @{$hash{ids}});
    $cursor = $hash{next_cursor};
  } until (!$cursor);

  return @res;
}

# copied from bc-twitter-follow-stream.pl
# TODO: centralize library for these progs

# parse users

sub parse_users {
  # NOTE: not in git directory, since it contains private info
  # users is not a global, but the hashes below are
  my(@users) = `egrep -v '^#' /home/barrycarter/20130603/users.txt`;

  # parse
  for $i (@users) {
    unless ($i=~m%^(.*?):(.*?):(.*)$%) {warn "BAD LINE: $i";}
    my($user,$pass,$int) = ($1,$2,$3);
    $pass{lc($user)} = $pass;
    # parse interests
    for $j (split(/\,\s*/,$int)) {
      $interest{lc($j)}{$user} = 1;
    }
    # initialize nextfollowtime (should be unnecessary, but...)
    $nextfollowtime{$user} = 0;
  }
}

=item schema

CREATE TABLE ff (user, type, target, timestamp TIMESTAMP DEFAULT
CURRENT_TIMESTAMP);

=cut
