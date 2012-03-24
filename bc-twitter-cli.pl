#!/bin/perl

# a twitter command-line for ssfe that also uses sqlite3
# <h>in the ghetto...</h>

# This client is for horrible people (like me) who follow others for
# no reason except to get followback and don't really care about other
# people's tweets unless they happen to mention me!

# Below, use your supertweet.net password, NOT your twitter password
# Usage: ssfe -hold $0 -username=username -password=password
# does work w/ GNU screen
#
# Optiosn w/ default values:
#
# -nohome=1: don't show tweets from home page (ie, the crap I ignore)
# -log=1: log to ~/bc-twitter-$username-log.txt
# -verbose=0: be verbose, mostly for debugging
# -db=~/bc-twitter-$username.db: use this sqlite3 db (must already exist)

require "bclib.pl";

set_globals();
defaults("nohome=1&log=1&db=$ENV{HOME}/bc-twitter-$globopts{username}.db");

# don't block when reading STDIN and keep pipes instant
use Fcntl;
fcntl(STDIN,F_SETFL,O_NONBLOCK);
$|=1;

# TODO: let user set this
%search = ();

# twitter is case-insensitive
$globopts{username} = lc($globopts{username});

# get columns for SQLite3 tables, just in case they've changed from
# 'schema' below; also useful to confirm this db really exists

%tweets_cols = sqlite3cols("tweets",$globopts{db});
%users_cols = sqlite3cols("users",$globopts{db});





=item schema

The schema for the SQLite3 db:

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

=cut

# globals for this script

sub set_globals {
  # these are globals, so no "my" below
  # VT100/ssfe colors
  ($RED,$GREEN,$YELLOW,$BLUE,$MAGENTA,$CYAN,$WHITE,$CLEAR,$BOLD,$OFF) =
    ("\e[31m","\e[32m","\e[33m","\e[34m","\e[35m","\e[36m","\e[37m","\e[H\e[J","\e[34m\e[1m","\e[0m");
}
