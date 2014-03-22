#!/bin/perl

# parses a fetlife user page

require "/usr/local/lib/bclib.pl";

# test file (not anyone I know)
$all = read_file("/home/barrycarter/20140321/user1861827.html");

# debug($all);

# table fields with headers/colons
while ($all=~s%<tr>\s*<th[^>]*>(.*?)</th>\s*<td>(.*?)</td>\s*</tr>%%is) {
  $val{$1} = $2;
}

# location data is first <p> in page, all one line
$all=~s%<p>(.*?)</p>%%is;
$val{location} = $1;

# name and orientation/gender
$all=~s%<h2 class="bottom">(.*?)</h2>%%s;
$val{extra} = $1;

# latest activity (useful to see when user was last active)
$all=~s%<h3 class="bottom">Latest activity</h3>(.*?)<h3 class="bottom">Fetishes </h3>(.*?)%%

debug("VAL",%val);


die "TESTING";

# kinkster (user) name
$all=~s%<title>(.*?)\s+\-\s*kinksters\s*\-\s*fetlife</title>%%is || warn("NO NAME: $all");



debug($1);
