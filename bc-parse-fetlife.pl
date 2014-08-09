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
  if (++$count>20) {warn "TESTING"; last}

  # read the file
  $all = read_file($i);

  # get rid of footer
  $all=~s/<em>going up\?<\/em>.*$//s;

  # user number in filename
  $user = $i;
  $user=~s/.*\///g;
  debug("USER: $user");

  # title (= username)
  $all=~s%<title>(.*?) - Kinksters - FetLife</title>%%s||warn("BAD TITLE: $all");
  $data{$user}{name} = $1;

  # number of pics (may have commas)
  if ($all=~s/view pics.*?\(([\,\d]+)\)//) {
    $data{$user}{npics} = $1;
    $data{$user}{npics}=~s/,//g;
  }

  # number of friends (may have commas)
  if ($all=~s%Friends <span class="smaller">\(([\d\,]+)\)</span>%%s) {
#  debug("ALL: $all");
#  if ($all=~s%<span class=\"smaller\">(.*?)</span>%%s) {
    debug("MATCH!");
    $data{$user}{nfriends} = $1;
    $data{$user}{nfriends}=~s/,//g;
  }

  # age, and orientation/gender
  $all=~s%<h2 class="bottom">$data{$user}{name}\s*<span class="small quiet">(\d+)(.*)\s+(.*?)</span></h2>%%||warn("NO EXTRA DATA: $all");
  ($data{$user}{age}, $data{$user}{gender}, $data{$user}{role}) = ($1, $2, $3);

  # city if first /cities link in page
  $all=~s%<a href="/cities/(\d+)">(.*?)</a>%%;
  $data{$user}{city} = $2;
  $meta{city}{$2}{number} = $1;

  # "realify" quotes (needed for csv below)
  $all=~s/\&quot\;/\"/sg;

  # get groups
  while ($all=~s/<li><a href="\/groups\/(\d+)">(.*?)<\/a><\/li>//s) {
    $data{$user}{groups}{$2} = $1;
  }

  # get fetishes in better way
  while ($all=~s/(into|curious about):(.*)$//im) {
    # TODO: csv is broken in some cases (quoted stuff), need to fix
#    debug("2: $2");
    my($type, @list) = ($1, csv($2));
#    debug("TYPE: $type, LIST",@list);
    for $j (@list) {
      $j=~s/<a href="\/fetishes\/(\d+)">(.*?)<\/a>//;
      my($nu, $na) = ($1, $2);
      $data{$user}{fetishes}{$na}{number} = $nu;
      $j=~s/<span class="quiet smaller">\((.*?)\)<\/span>//;
      $data{$user}{fetishes}{$na}{role} = $1;
    }
  }

  # table fields with headers/colons
  # TODO: "looking for" is multivalued
  # TODO: "relationships in" is multivalued (but may not be of interest,
  # except for 6 degrees stuff?, which wouldn't include "friends" in general?)
  while ($all=~s%<tr>\s*<th[^>]*>(.*?)</th>\s*<td>(.*?)</td>\s*</tr>%%is) {
    ($key, $val) = (lc($1),$2);
    $key=~s/:\s*$//isg;
    $key=~s/\s//isg;
    $val=~s/\'//isg;
    $data{$user}{$key} = $val;
  }

#  debug("DATA($user):",unfold(\%data));

next; warn "TESTING";

  ($name, $age, $gender, $role, $location, $user, $fetishes) = ();

  # since I only searched NM, the tail of the location is irrelevant
  $location=~s/, new mexico, united states$//i;
  # should really fix unicode more genrically, this works for n tilde only
  # only necessarily for Espanola <h>which barely qualifies as a city</h>
  $location=~s/\xe2\x88\x9a\xc2\xb1/n/isg;

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
#  print "INSERT INTO kinksters (name, age, gender, role, location, user, orientation, active, latest) VALUES ('$name', '$age', '$gender', '$role', '$location', $user, '$data{orientation}', '$data{active}', '$date');\n";

  # other frequently used fields, "relationship status" and "D/s
  # relationship status", are multivalued
#  die "TESTING";

}

# print "COMMIT;\n";

for $i (sort keys %data) {
  debug("USER: $i");
  debug("KEYS", sort keys %{$data{$i}});
  for $j ("name", "age", "gender", "role", "city", "orientation", "active",
	 "npics", "nfriends") {
    debug("$j: $data{$i}{$j}");
  }
  debug(); # blank line
}

=item views

Useful view:

DROP VIEW IF EXISTS recent;

CREATE VIEW recent AS SELECT * FROM kinksters WHERE latest LIKE
'%minute%' OR latest LIKE '%hour%' OR latest LIKE '%day%' OR (latest
LIKE '%month%' AND latest NOT LIKE '%months%');

=cut
