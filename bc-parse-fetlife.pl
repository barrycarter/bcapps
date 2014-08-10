#!/bin/perl

# parses a fetlife user page

# list of files by size (assuming larger user pages will have more items)
# \ls -ls | sort -nr | perl -anle 'print $F[-1]' | egrep -iv '[a-z]'

# TODO: make the warnings more 'vocal' and remove warnings that are unneeded

require "/usr/local/lib/bclib.pl";

# this is for a newer pull on 20140808
# @files = glob("/home/barrycarter/20140808/[0-9]*");
@files = split(/\n/, read_file("/home/barrycarter/20140808/filesbysize.txt"));

for $i (@files) {
  if (++$count>20) {warn "TESTING"; last}

  # user number in filename
  $user = $i;
  $user=~s/.*\///g;
  # below is sort of pointless
  $data{$user}{id} = $user;

  # read the file
  $all = read_file($i);

  # get rid of footer
  $all=~s/<em>going up\?<\/em>.*$//s;

  # title (= username)
  $all=~s%<title>(.*?) - Kinksters - FetLife</title>%%s||warn("BAD TITLE: $all");
  $data{$user}{name} = $1;

  # after getting title, get rid of header
  $all=~s%^.*</head>%%s;

  # latest activity (could get all activity on front page, but no)
  $all=~s%<span class="quiet small">(.*? ago)</span>%%;
  # leaving this in "fetlife format", like "3 hours ago"
  $data{$user}{latestactivity} = $1;

  # after getting latest activity, nuke the activity feed, it interferes
  $all=~s%<ul id="mini_feed">(.*?)</ul>%%s;

  # now grab events (but not those in activity feed)
  while ($all=~s%<a href="/events/(\d+)">(.*?)<%%s) {
    $data{$user}{event}{$2} = 1;
    $meta{event}{$2}{number} = $1;
  }

  # number of pics (may have commas)
  if ($all=~s/view pics.*?\(([\,\d]+)\)//) {
    $data{$user}{npics} = $1;
    $data{$user}{npics}=~s/,//g;
  }

  # number of friends (may have commas)
  if ($all=~s%Friends <span class="smaller">\(([\d\,]+)\)</span>%%s) {
    $data{$user}{nfriends} = $1;
    $data{$user}{nfriends}=~s/,//g;
  }

  # age, and orientation/gender
  $all=~s%<h2 class="bottom">$data{$user}{name}\s*<span class="small quiet">(\d+)(.*)\s+(.*?)</span></h2>%%||warn("NO EXTRA DATA($i): $all");
  ($data{$user}{age}, $data{$user}{gender}, $data{$user}{role}) = ($1, $2, $3);

  # city if first /cities link in page
  $all=~s%<a href="/cities/(\d+)">(.*?)</a>%%;
  $data{$user}{city} = $2;
  $meta{city}{$2}{number} = $1;

  # "realify" quotes (needed for csv below)
  $all=~s/\&quot\;/\"/sg;

  # get groups
  # TODO: exclude activity feed!
  while ($all=~s/<li><a href="\/groups\/(\d+)">(.*?)<\/a><\/li>//s) {
    $data{$user}{groups}{$2} = $1;
  }

  # get fetishes in better way
  while ($all=~s/(into|curious about):(.*)$//im) {
    my($type, $fetishes) = ($1, $2);

    # look for ones with role attached first
    while ($fetishes=~s%<a href="/fetishes/(\d+)">([^<>]*?)</a>\s*<span class="quiet smaller">\((.*?)\)</span>%%) {
      $data{$user}{fetish}{$type}{$2} = $3;
      $meta{fetish}{$2}{number} = $1;
    }

    # ones without a role
    while ($fetishes=~s%<a href="/fetishes/(\d+)">([^<>]*?)</a>%%) {
      $data{$user}{fetish}{$type}{$2} = 1;
      $meta{fetish}{$2}{number} = $1;
    }

    # make sure we got them all
    $fetishes=~s/<.*?>//g;
    $fetishes=~s/[\,\s\.]//g;
    if ($fetishes) {warn "LEFTOVER FETISHES: $fetishes";}
  }

  # table fields with headers/colons
  # TODO: "looking for" is multivalued
  # TODO: "relationships in" is multivalued (but may not be of interest,
  # except for 6 degrees stuff?, which wouldn't include "friends" in general?)
  while ($all=~s%<tr>\s*<th[^>]*>(.*?)</th>\s*<td>(.*?)</td>\s*</tr>%%is) {
    ($key, $val) = (lc($1),$2);
    $key=~s/:\s*$//isg;
    $key=~s/[\/\s]//isg;
    $val=~s/\'//isg;
    $data{$user}{$key} = $val;
  }

  # parse out relationshipstatus + dsrelationshipstatus
  for $j ("relationshipstatus", "dsrelationshipstatus") {
    while ($data{$user}{$j}=~s%<li>(.*?)</li>%%) {
      my($rel) = $1;
      # need underscore below to avoid overwriting variable we're reading from
      if ($rel=~s%^(.*?)\s*<a href="/users/(\d+)">.*?</a>%%m) {
	$data{$user}{"_$j"}{$1}{$2} = 1;
      } else {
	$data{$user}{"_$j"}{$rel}{0} = 1;
      }
    }
    # fix the hash (hopefully)
    $data{$user}{$j} = $data{$user}{"_$j"};
    delete $data{$user}{"_$j"};
  }

  # and islookingfor
  for $j (split("<br/>", $data{$user}{islookingfor})) {
    $data{$user}{"_islookingfor"}{$j} = 1;
  }
  # and fix
  $data{$user}{islookingfor} = $data{$user}{"_islookingfor"};
  delete $data{$user}{"_islookingfor"};

}

system("rm -f /tmp/bcpfl.db");
open(A,"|sqlite3 /tmp/bcpfl.db");

# print the schema
print A << "MARK";
CREATE TABLE kinksters (id INT, name, age INT, gender, role, city,
 orientation, active, latestactivity, npics INT, nfriends INT);
CREATE TABLE fetishes (user INT, type, fetish, role);
BEGIN;
MARK
;

for $i (sort keys %data) {
  debug("USER: $i");
#  debug("KEYS", sort keys %{$data{$i}});
  for $j ("id", "name", "age", "gender", "role", "city", "orientation",
	  "active", "npics", "nfriends", "latestactivity") {
    # the delete below is just so we can see what keys are unused
    debug("$j: $data{$i}{$j}");
    delete $data{$i}{$j};
  }

  # cases with 4 levels of hashing
  for $j ("dsrelationshipstatus", "relationshipstatus", "fetish") {
    for $k (sort keys %{$data{$i}{$j}}) {
      for $l (sort keys %{$data{$i}{$j}{$k}}) {
	debug("BETA: $i $j $k $l");
      }
    }
    delete $data{$i}{$j};
  }

  for $j ("groups", "islookingfor", "event") {
    for $k (sort keys %{$data{$i}{$j}}) {
      debug("BETA: $i $j $k $data{$i}{$j}{$k}");
    }
    delete $data{$i}{$j};
  }

  for $j (sort keys %{$data{$i}}) {
    debug("$j (AFTER($i)):", unfold($data{$i}{$j}));
  }
}

=item views

Useful view:

DROP VIEW IF EXISTS recent;

CREATE VIEW recent AS SELECT * FROM kinksters WHERE latest LIKE
'%minute%' OR latest LIKE '%hour%' OR latest LIKE '%day%' OR (latest
LIKE '%month%' AND latest NOT LIKE '%months%');

=cut
