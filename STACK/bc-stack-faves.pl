#!/bin/perl

# This script downloads my favorite stack questions, ie:
# https://stackexchange.com/users/favorites/144803?page=2&sort=recent
# and checks to see if I have a "bookmark comment" for them

# bookmark comment: I use firefox's bookmark "tag" feature to annotate
# pages (including stack pages) on which I wish to take action

require "/usr/local/lib/bclib.pl";

# TODO: make this an argument and/or find it from username?
my($userid) = 144803;

# this is the order in which I want to see data
my(@order) = ("title", "mark", "surl", "date", "user");

# copy my bookmarks file (running SQL commands on it "in situ" is
# probably a bad idea), and then query it

# TODO: allow non-default profile as an option
system("cp /home/barrycarter/.mozilla/firefox/*.default/places.sqlite /tmp");

# this is the "magic query" to show bookmarks with tags (starting with "!")
# TODO: could further restrict query to stackexchange sites (but note
# stackoverflow and mathoverflow, so pattern isn't obvious?)

my($query) = << "MARK";
SELECT mb1.title AS tag, mp.url, mp.title FROM moz_bookmarks mb1
 JOIN moz_bookmarks mb2 ON (mb1.id = mb2.parent)
 JOIN moz_places mp ON (mb2.fk = mp.id)
WHERE mb1.parent = 4 AND tag LIKE '!%';
MARK
;

my(@res) = sqlite3hashlist($query, "/tmp/places.sqlite");
my(%marks);

# TODO: look for stackexchange.com pages with tags that are not
# favorited, probably an error on my part

# link url to record
for $i (@res) {$marks{$i->{url}} = $i;}

my($out,$err,$res);

# TODO: grab all pages, not just first 10 (also bad for users who have
# fewer than 10 pages of favorites!)

# TODO: lower 86400 in production

my($count) = 0;

for $i (1..100) {

  ($out,$err,$res) = cache_command2("curl 'https://stackexchange.com/users/favorites/$userid?page=$i&sort=recent'", "age=86400");

  my(@qs) = split(/<div class="favorite-container">/s, $out);

  for $j (@qs) {

    my(%data) = ();

    # TODO: this is a hideous way to get the time and user
    $j=~s%>\s*([^>]*?)\s*<span class="favorite-last-editor">\s*(.*?)\s*</span>%%sg;
    ($data{date}, $data{user}) = ($1,$2);

    for $k (keys %data) {$data{$k}=~s/<.*?>//g;}

    # the first URL is the only one I need
    $j=~s/href="(.*?)"//;
    $data{url} = $1;

    # if the URL contains /favorites/ this isn't actually a question
    if ($data{url}=~m%/favorites/%) {next;}

    $count++;

    # break URL into short link + name
    $data{url}=~m%^(.*?/\d+)/(.*?)$%;

    ($data{surl}, $data{title}) = ($1,$2);

    # if I don't have it tagged, note and proceed
    unless ($marks{$data{url}}) {
      # page number is important
      print "\nPage: $i ($count)\n";
      print "UNMARKED: $data{url}\n";
      next;
    }

    # if I do have it tagged, show details
    $data{mark} = $marks{$data{url}}->{tag};

    # ignore certain tags (intentionally keeping these conditions
    # separate for now)

    # TODO: make it customizable which ones I'm ignoring
#    if ($data{mark} eq "! JUST WATCHING") {next;}
    if ($data{mark} eq "! DONE") {next;}

    print "\nPage: $i ($count)\n";
    for $k (@order) {
      print "$k: $data{$k}\n";
    }
  }
}
