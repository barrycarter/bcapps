#!/bin/perl

# This script downloads my favorite stack questions, ie:
# https://stackexchange.com/users/favorites/144803?page=2&sort=recent
# and checks to see if I have a "bookmark comment" for them

# bookmark comment: I use firefox's bookmark "tag" feature to annotate
# pages (including stack pages) on which I wish to take action

require "/usr/local/lib/bclib.pl";

# TODO: make this an argument and/or find it from username?
my($userid) = 144803;

# copy my bookmarks file (running SQL commands on it "in situ" is
# probably a bad idea), and then query it

# TODO: allow non-default profile as an option
system("cp /home/barrycarter/.mozilla/firefox/*.default/places.sqlite /tmp");

# this is the "magic query" to show bookmarks with tags
my($query) = << "MARK";
SELECT mb1.title, mp.url, mp.title FROM moz_bookmarks mb1
 JOIN moz_bookmarks mb2 ON (mb1.id = mb2.parent)
 JOIN moz_places mp ON (mb2.fk = mp.id)
WHERE mb1.parent = 4;
MARK
;

my(@res) = sqlite3hashlist($query, "/tmp/places.sqlite");

debug(@res);

die "TESTING";

# TODO: lower 86400 in production
my($out,$err,$res) = cache_command2("curl 'https://stackexchange.com/users/favorites/$userid?sort=recent'", "age=86400");

debug("OUT: $out");


