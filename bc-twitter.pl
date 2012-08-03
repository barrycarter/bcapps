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

# badly assumes $user and $pass are global variables set by calling
# program ($pass here = supertweet.net password)

require "bclib.pl";

# endpoint for supertweet.net's "proxy" API (yes, it's global), and
# twitters own API for requests that don't require authentication

$TWITST = "http://api.supertweet.net/1";
$TWITTW = "http://api.twitter.com/1";

=item twitter_public_timeline()

Obtain the twitter public timeline (a sample of the "firehose") (no
auth required), return as list of hashes (each hash = one tweet)

=cut

sub twitter_public_timeline {
  my($out, $err, $res) = cache_command("curl -s '$TWITTW/statuses/public_timeline.json'", "age=60");
  return @{JSON::from_json($out)};
}

=item twitter_friends_followers_ids($which="friends|followers"$user,$pass)

Obtain friends/followers ids for $user (auth required)

NOTE: Twitter lets you get friends/followers for others, but not via
id-- weird?

=cut

sub twitter_friends_followers_ids {
  my($which,$user,$pass) = @_;
  my($out,$err,$res);
  my($cursor) = -1;
  my(@res);

  # twitter returns 5K or so results at a time, so loop using "next cursor"
  do {
    ($out,$err,$res) = cache_command("curl -s -u $user:$pass '$TWITST/$which/ids.json?cursor=$cursor'", "age=300");
    my(%hash) = %{JSON::from_json($out)};
    push(@res, @{$hash{ids}});
    $cursor = $hash{next_cursor};
    debug("CURSOR: $cursor, RES: $#res");
  } until (!$cursor);

  return @res;

}

=item twitter_rate_limit_status()

Get rate limit status (requires auth)

=cut

sub twitter_rate_limit_status {
  # TODO: REALLY don't cache this result!
  my($out, $err, $res) = cache_command("curl -s -u $user:$pass '$TWITST/account/rate_limit_status.json'", "age=300");
  return %{JSON::from_json($out)};
}

=item twitter_search($term)

Searches for English tweets w/ the given $term (no auth required)

=cut

sub twitter_search {
  my($term) = @_;
  my($i);
  my(@ret);

  # required, especially for hashtags
  $term = urlencode($term);

  # we'll never really hit page 100 -- twitter API stops us at max ~15
  for $i (1..100) {
    my($file) = cache_command("curl -s '$TWITTW/search.json?q=$term&rpp=100&lang=en&page=$i'","age=300&retfile=1");
    my($res) = suck($file);

    # die on bad result (or empty)
    if ($res=~/<error>/ || $res=~/^\s*$/) {
      warn "SEARCH ERROR";
      return;
    }

    my(%res) = %{JSON::from_json($res)};

    # results we found on this page
    my(@newres) = @{$res{results}};

    # if we found more results, keep going; otherwise return
    if ($#newres>=0) {
      push(@ret,@{$res{results}});
      next;
    }
    return @ret;
  }
}

=item tweet2list($str)

Converts a long tweet into several smaller tweets, preserving @replies
and \#hashtags

This is specific to twitter, but could be modified to be more general.

=cut

sub tweet2list {
  my($str) = @_;
  my($pre) = "[...] "; # put this in front of 2nd-last tweet
  my($post) = " [more]"; # put this in front of 1st-penultimate tweet
  my($tweetlimit) = 140; # tweet limit
  my($i);
  my($msg);
  my($res);
  my(@res);

  # if $str already less than $tweetlimit, just return 1 elt list
  if (length($str) <= $tweetlimit) {return ($str);}

  $str=" $str"; # HACK: hideous hack to make regex below work nicely

  # find the hashtags and @replies and remove them from message
  # UGLY: could I combine the two lines below?
  # first the @replies
  my(@rep) = ($str=~m/\s+(\@\S+)/g);
  $str=~s/\s+(\@\S+)/ /g;

  # now the hashtags
  my(@tags) = ($str=~m/\s+(\#\S+)/g);
  $str=~s/\s+(\#\S+)/ /g;

  # the string that will be prepended to all tweets
  my($prepend) = join(" ",@rep)." ".join(" ",@tags)." ";

  # cleanup $prepend (including nuke it completely if no tags/replies) and $str
  $prepend=~s/\s+/ /isg;
  $prepend=trim($prepend)." ";
  $str=trim($str);

  # how many characters we have left after $pre/$post/hashtags/@replies
  # if you have too many hashtags/@replies, this breaks
  my($chars) = $tweetlimit-length("$prepend$pre$post");

  # split message into words (fails if words are too long)
  my(@words)=split(/\s+/,$str);
  # always include the first word
  $msg=shift(@words);

  # keep adding words until we exceed tweetlimit (minus $pre and $post, etc)
  while (@words) {
    if (length("$msg $words[0]") <= $chars) {
      $msg = "$msg ".shift(@words);
      next;
    }

    # next word would put us over, so break here

    unless (@res) {
      # first tweet? No $prepend
      push(@res,"$prepend$msg$post");
    } else {
      push(@res,"$prepend$pre$msg$post");
    }

    $msg = shift(@words);
  }

  # last tweet (no $post)
  push(@res, "$prepend$pre$msg");
  return @res;
}

=item twitter_follow($sn, $user, $pass, $un=0, $options)

Follow $sn (requires auth); if $un is set, unfollow. $options:

cmdonly=1: return only the curl command, don't run it

=cut

sub twitter_follow {
  my($sn, $user, $pass, $un, $options) = @_;
  my(%opts) = parse_form($options);
  my($url,$post);

  if ($un) {
    ($url, $post) = ("destroy","");
  } else {
    ($url, $post) = ("create","?follow=true");
  }

  my($cmd) = "curl -s -d x -u $user:$pass '$TWITST/friendships/$url/$sn.xml$post'";
  debug($cmd);
  if ($opts{cmdonly}) {return $cmd;}
  my($file) = cache_command($cmd, "age=3600&retfile=1");
  my($res) = read_file($file);
  if ($res=~/<error>/) {warn "FOLLOW($sn) FAILED"; return -1}
  return 0;
}

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

=item twitter_get_friends_followers($sn,$which="friends|followers", $options)

Gets all friends or followers of $sn as list of hashes. $options unused

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
