#!/bin/perl

# parses a fetlife user page

require "/usr/local/lib/bclib.pl";

# fixed random seed (we need predictability while testing)
srand(20140321);

# print the schema
print << "MARK";
DROP TABLE IF EXISTS kinksters;
DROP TABLE IF EXISTS fetishes;
CREATE TABLE kinksters (name, age INT, gender, role, location, user INT,
 orientation, active);
CREATE TABLE fetishes (user INT, type, fetish, role);
VACUUM;
BEGIN TRANSACTION;
MARK
;

@files = glob("/home/barrycarter/20140321/user*.html");

for $i (randomize(\@files)) {
  # read the file
  $all = read_file($i);

  # if the title is identically "Home - FetLife", something went wrong
  $all=~s%<title>(.*?)</title>%%s;
  $title = $1;
  if ($title eq "Home - FetLife") {next;}

  # wipe out variables
  %data = ();
  ($name, $age, $gender, $role, $location, $user, $fetishes) = ();

  # user number is only in filename
  $i=~/\/user(\d+)\.html$/;
  ($user) = $1;

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
      print "INSERT INTO fetishes (user, type, fetish, role) VALUES
           ($user, '$j', '$1', '$2');\n";
    }
    # ones where role is NOT indicated
    while ($data{$j}=~s%<a href="/fetishes/\d+">([^>]*?)</a>%%) {
      print "INSERT INTO fetishes (user, type, fetish, role) VALUES
           ($user, '$j', '$1', 'NA');\n";
    }
  }

  # need '' around age in case its blank
  print "INSERT INTO kinksters (name, age, gender, role, location, user,
         orientation, active)
         VALUES ('$name', '$age', '$gender', '$role', '$location', $user,
         '$data{orientation}', '$data{active}');\n";

  # latest activity (just want to know when user was last active)
  $latest = "";
  $all=~s%<ul id="mini_feed">(.*?)</ul>%%is;
  $activity = $1;
#  debug("ACT: $activity");
  while ($activity=~s%<li>\s*(.*?)\s*</li>%%s) {
    $act = $1;
    # find actor and date of event (most recent first)
    $act=~s%^(.*?)\s+%%s;
    $actor = $1;
    $act=~s%<span class="quiet small">(.*?)</span>%%s;
    $date = $1;
    # if actor and name match, we're done
    if ($actor eq $name) {$latest = $date; last;}
    warn("BADACT: $user,$name,$actor,$date");
  }

  # other frequently used fields, "relationship status" and "D/s
  # relationship status", are multivalued

}

print "COMMIT;\n";

die "TESTING";

# test file (not anyone I know)
$all = read_file("/home/barrycarter/20140321/user1861827.html");

# debug($all);

# name and orientation/gender
$all=~s%<h2 class="bottom">(.*?)</h2>%%s;
$val{extra} = $1;

# latest activity (useful to see when user was last active)
$all=~s%<h3 class="bottom">Latest activity</h3>(.*?)<h3 class="bottom">Fetishes </h3>(.*?)%%;

debug("VAL",%val);


die "TESTING";

# kinkster (user) name
$all=~s%<title>(.*?)\s+\-\s*kinksters\s*\-\s*fetlife</title>%%is || warn("NO NAME: $all");



debug($1);
