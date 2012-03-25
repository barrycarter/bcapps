#!/bin/perl

# a twitter command-line for ssfe that also uses sqlite3
# <h>in the ghetto...</h>

# This client is for horrible people (like me) who follow others for
# no reason except to get followback and don't really care about other
# people's tweets unless they happen to mention me!

# This client is synchronus, which is probably a bad thing

# Below, use your supertweet.net password, NOT your twitter password
# Usage: ssfe -hold $0 -username=username -password=password
# does work w/ GNU screen
#
# Options w/ default values:
#
# --log=1: log to ~/bc-twitter-$username-log.txt
# --verbose=0: be verbose, mostly for debugging
# --db=~/bc-twitter-$username.db: use this sqlite3 db (must already exist)
# --create=create db if it doesn't already exist (won't overwrite existing)
# --timelines=REPLY,SEARCH,DIRECT (see below)

# timelines:
#
# HOME: what you would see on your twitter home page
# SEARCH: results of whatever phrases I'm currently searching for
# REPLY: tweets with @your_username in them
# DIRECT: direct message to you
# SEND: direct messages you sent
# USER-$twit: tweets from $twit

require "bclib.pl";

# don't block when reading STDIN and keep pipes instant
use Fcntl;
fcntl(STDIN,F_SETFL,O_NONBLOCK);
$|=1;


# error checking
# twitter is case-insensitive, so lower case username
$globopts{username} = lc($globopts{username});
unless ($globopts{username} && $globopts{password}) {
  die "--username=username --password=password required";
}

# globals
set_globals();
defaults("nohome=1&log=1&db=$ENV{HOME}/bc-twitter-$globopts{username}.db&timelines=REPLY,SEARCH,DIRECT");

# die if sqlite3 db doesn't exist or has 0 size
unless (-s $globopts{db}) {
  unless ($globopts{create}) {
    die("$globopts{db} doesn't exist or is empty; use --create to create");
  } else {
    create_db($globopts{db});
  }
}

# TODO: let user set this
%search = ();

# get columns for SQLite3 tables, just in case they've changed from
# 'schema' below

%tweets_cols = sqlite3cols("tweets",$globopts{db});
%users_cols = sqlite3cols("users",$globopts{db});

# log
if ($globopts{log}) {
  open(A,">>$ENV{HOME}/bc-twitter-$globopts{username}-log.txt");
}




# create SQLite3 db for this program
sub create_db {
  my($file) = @_;
  local(*A);
  open(A, "|sqlite3 $file");
  print A << "MARK";

-- highwater mark
CREATE TABLE hwm (
 whoami TEXT,
 type TEXT,
 hwm INT
);

-- tweets (most of these fields come straight from twitter)
CREATE TABLE tweets (
 id INT PRIMARY KEY,
 text TEXT,
 in_reply_to_screen_name TEXT,
 created_at DATE,
 in_reply_to_status_id INT,
 truncated TEXT,
 source TEXT,
 favorited TEXT,
 in_reply_to_user_id INT,
 screen_name TEXT,
 user_id INT,
 raw TEXT,
 whoami TEXT,
 type TEXT,
 hashtags TEXT,
 replies TEXT,
 unix_time INT,
 iso_language_code TEXT,
 mentions_me INT,
 mentions_search TEXT,
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
 geo TEXT,
 contributors TEXT,
 coordinates TEXT,
 place TEXT);

-- twits (mostly from twitter again)
CREATE TABLE users (
 location TEXT,
 url TEXT,
 screen_name TEXT,
 description TEXT,
 id PRIMARY KEY,
 followers_count INT,
 profile_image_url TEXT,
 protected TEXT,
 name TEXT,
 profile_background_image_url TEXT,
 favourites_count INT,
 following TEXT,
 profile_background_color TEXT,
 profile_sidebar_border_color TEXT,
 friends_count INT,
 profile_text_color TEXT,
 utc_offset INT,
 profile_link_color TEXT,
 created_at TEXT,
 statuses_count INT,
 time_zone TEXT,
 profile_background_tile TEXT,
 profile_sidebar_fill_color TEXT,
 notifications TEXT,
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 verified TEXT,
 geo_enabled TEXT,
 contributors TEXT,
 contributors_enabled TEXT,
 lang TEXT);

-- useful indexes
CREATE INDEX i_in_reply_to_screen_name ON tweets(in_reply_to_screen_name);
CREATE INDEX i_in_reply_to_status_id ON tweets(in_reply_to_status_id);
CREATE INDEX i_screen_name ON tweets(screen_name);
CREATE INDEX i_screen_name2 ON users(screen_name);
CREATE INDEX i_type ON hwm(type);
-- can support multiple users in one db?
CREATE UNIQUE INDEX i_uniq ON hwm(whoami,type);
CREATE INDEX i_user_id ON tweets(user_id);
CREATE INDEX i_whoami ON tweets(whoami);
CREATE INDEX i_whoami2 ON hwm(whoami);

MARK
;

close(A);
}

# globals for this script

sub set_globals {
  # these are globals, so no "my" below
  # VT100/ssfe colors
  ($RED,$GREEN,$YELLOW,$BLUE,$MAGENTA,$CYAN,$WHITE,$CLEAR,$BOLD,$OFF) =
    ("\e[31m","\e[32m","\e[33m","\e[34m","\e[35m","\e[36m","\e[37m","\e[H\e[J","\e[34m\e[1m","\e[0m");
}

# figure out what time I should sleep until to avoid hitting the API
# limit

sub sleep_calc {
#  my(%lim) = twitter_rate_limit_status();

  # TODO: if 15s doesn't suffice, write more code here
  my($sleep) = 15;
  my($now) = time();

  # print next grab to status line (in "stardate" format)
  my($stardate) = stardate($now + $sleep);
  
  ssfeprint("NEXT: $stardate (${sleep}s)");
  
  # TODO: everything
  return $now+$sleep;
}

# print to ssfe status line (and to main screen if in verbose mode)
sub ssfeprint {
  my($text) = @_;
  # escape code for ssfe and text to print
  my($body) = "`#ssfe#s$text";
  # fill with "-" so status line looks complete
  my($filler) = "-"x(139-length($body)).">";
  print "$body$filler\n";
  # if verbose, print on main screen as well
  if ($globopts{verbose}) {doprint("$text\n");}
}

# wrapper for print function: print to stdout and log if needed

sub doprint {
  my($text) = @_;
  print $text;
  if ($globopts{log}) {print A $text;}
}
