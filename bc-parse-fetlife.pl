#!/bin/perl

# parses a fetlife user page

require "/usr/local/lib/bclib.pl";

# fixed random seed (we need predictability while testing)
# tweaked this slightly since initial random seed gave bad first result
srand(20140);

# print the schema
print << "MARK";
DROP TABLE IF EXISTS kinksters;
DROP TABLE IF EXISTS fetishes;
CREATE TABLE kinksters (name, age INT, gender, role, location, user INT,
 orientation, active, latest);
CREATE TABLE fetishes (user INT, type, fetish, role);
VACUUM;
BEGIN TRANSACTION;
MARK
;

# this is for a newer pull on 20140808
@files = glob("/home/barrycarter/20140808/[0-9]*");

for $i (randomize(\@files)) {
  # read the file
  $all = read_file($i);

  debug("ALL($i): $all");

  # TODO: add group memberships

  # if the title is identically "Home - FetLife", something went wrong
  $all=~s%<title>(.*?)</title>%%s;
  $title = $1;
  if ($title eq "Home - FetLife") {
    warn "BAD FILE: $i";
    next;
  }


  # wipe out variables
  %data = ();
  ($name, $age, $gender, $role, $location, $user, $fetishes) = ();

  # get groups
  while ($all=~s/<li><a href="\/groups\/(\d+)">(.*?)<\/a><\/li>//s) {
    $data{$title}{groups}{$2} = $1;
  }

  # get fetishes in better way
  while ($all=~s/(into|curious about):(.*)$//im) {
    my($type, @list) = ($1, split(/\,/, $2));
    for $j (@list) {
      $j=~s/<a href="\/fetishes\/(\d+)">(.*?)<\/a>//;
      my($na, $nu) = ($1, $2);
      $data{$i}{fetishes}{$na}{number} = $nu;
      $j=~s/<span class="quiet smaller">\((.*?)\)<\/span>//;
      $data{$i}{fetishes}{$na}{role} = $1;
      }
    }

  debug(unfold(\%data));

die "TESTING";

  # TODO: this get fetishes in timeline which might be bad/noncurrent
#  while ($all=~s/$title (.*?) <a href="\/fetishes\/(\d+)">(.*?)<\/a>//s) {
  while ($all=~s/<a href="\/fetishes\/(\d+)">(.*?)<\/a>//s) {
    debug("FET: $1, $2, $3");
  }




#                                <li><a href="/groups/311">FetLife Announcements</a></li>


  # user number in filename
  $user = $i;
  $user=~s/.*\///g;
  chomp($user);
  debug("USER: $user");

  # name, age, and orientation/gender
  # I have confirmed names never have spaces
  $all=~s%<h2 class="bottom">(.*?)\s*<span class="small quiet">(\d+)(.*)\s+(.*?)</span></h2>%%;
  ($name, $age, $gender, $role) = ($1, $2, $3, $4);

  # location data is first <p> in page, all one line
  $all=~s%<p>(.*?)</p>%%is;
  ($location) = $1;
  $location=~s/<.*?>//isg;
  # since I only searched NM, the tail of the location is irrelevant
  $location=~s/, new mexico, united states$//i;
  # should really fix unicode more genrically, this works for n tilde only
  # only necessarily for Espanola <h>which barely qualifies as a city</h>
  $location=~s/\xe2\x88\x9a\xc2\xb1/n/isg;

  # table fields with headers/colons
  while ($all=~s%<tr>\s*<th[^>]*>(.*?)</th>\s*<td>(.*?)</td>\s*</tr>%%is) {
    ($key, $val) = (lc($1),$2);
    $key=~s/:\s*$//isg;
    $key=~s/\s//isg;
    $val=~s/\'//isg;
    $data{$key} = $val;
  }

  # list of fetishes
  while ($all=~s%<p><span class="quiet"><em>(.*?)</em>(.*?)</p>%%is) {
    ($key, $val) = (lc($1),$2);
    $key=~s/:\s*$//isg;
    $key=~s/\s//isg;
    $val=~s/\'//isg;
    $data{$key} = $val;
  }

  # split the "into" and "curiousabout" lists
  for $j ("into", "curiousabout") {
    # ones where role is indicated
    while ($data{$j}=~s%<a href="/fetishes/\d+">([^>]*?)</a> <span class="quiet smaller">(.*?)</span>%%) {
      print "INSERT INTO fetishes (user, type, fetish, role) VALUES ($user, '$j', '$1', '$2');\n";
    }
    # ones where role is NOT indicated
    while ($data{$j}=~s%<a href="/fetishes/\d+">([^>]*?)</a>%%) {
      print "INSERT INTO fetishes (user, type, fetish, role) VALUES ($user, '$j', '$1', 'NA');\n";
    }
  }

  # latest activity (just want to know when user was last active, only
  # need most recent activity, not all)
  $all=~s%<ul id="mini_feed">(.*?)</ul>%%is;
  $activity = $1;
  $activity=~s%<li>\s*(.*?)\s*</li>%%s;
  $act = $1;
  # find date of last activity
  $act=~s%<span class="quiet small">(.*?)</span>%%s;
  $date = $1;
  # some dates are hyperlinked, sigh
  $date=~s/<(.*?)>//isg;

  # need '' around age in case its blank
  # TODO: change date from weird format to better format
  print "INSERT INTO kinksters (name, age, gender, role, location, user, orientation, active, latest) VALUES ('$name', '$age', '$gender', '$role', '$location', $user, '$data{orientation}', '$data{active}', '$date');\n";

  # other frequently used fields, "relationship status" and "D/s
  # relationship status", are multivalued
  die "TESTING";

}

print "COMMIT;\n";

=item views

Useful view:

DROP VIEW IF EXISTS recent;

CREATE VIEW recent AS SELECT * FROM kinksters WHERE latest LIKE
'%minute%' OR latest LIKE '%hour%' OR latest LIKE '%day%' OR (latest
LIKE '%month%' AND latest NOT LIKE '%months%');

=cut
