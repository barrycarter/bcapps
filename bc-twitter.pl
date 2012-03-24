#!/bin/perl

# WARNING: this library uses supertweet.net, since I'm too lazy to
# learn OAuth. Here are some reasons this is "bad":
#
# - supertweet.net may go away (tho someone'll probably create a replacement)
# - defeating OAuth is a bad idea (writing your own OAuth app is better)
# - supertweet.net can send tweets as you (eg, ads, viruses, etc)
# - supertweet.net can read your private DMs (and send DMs as you)
# - if your timeline is private, supertweet can see it
# - other bad things I can't think of right now

# Of course, I trust supertweet.net to keep their servers virus-free
# and act within their privacy policy

# this is a "total rewrite" using supertweet.net (OAuth, who needs it!)

# attempt to create a twitter library or app or something ... maybe

# NOTE: caching for 5m during testing, but a good idea regardless

require "bclib.pl";

# endpoint for supertweet.net's "proxy" API (yes, it's global), and
# twitters own API for requests that don't require authentication

$TWITST = "http://api.supertweet.net/1";
$TWITTW = "http://api.twitter.com/1";

=item twitter_get_info($sn)

Get info on $sn as a hash (no auth required)

=cut

sub twitter_get_info {
  my($sn) = @_;
  my($file) = cache_command("curl -s '$TWITTW/users/show/$sn.json'","retfile=1&age=300");
  my($res) = suck($file);
  my(@hash) = JSON::from_json($res);
  return %{$hash[0]};
}

=item twitter_get_friends_followers($sn,$which="friends|followers")

Gets all friends or followers of $sn as list of hashes

=cut

sub twitter_get_friends_followers {
  my($sn,$which) = @_;
  my(@retval);

  # find out how many friends/followers $sn has
  my(%info) = twitter_get_info($sn);
  my($num) = $info{"${which}_count"};
  my($pages) = int($num/100)+1;

  # loop to get enough pages (will never really hit 1000)
  for $i (1..$pages) {
    # get this page of followers
    my($file) = cache_command("curl -s '$TWITTW/statuses/$which/$sn.json?page=$i'", "retfile=1&age=300");
    my($res) = suck($file);
    my(@newres) = @{JSON::from_json($res)};

    if (@newres) {
      push(@retval, @newres);
      debug("RETVAL SIZE: $#retval");
      next;
    }
    return @retval;
  }
}

# all perl libs must return truth!
1;
