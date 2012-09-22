#!/bin/perl

# attempts to generate the HTML5 canvas for "signifigant events"
# (currently undefined) between two dates

require "/usr/local/lib/bclib.pl";

# test case: 1950-present
# assuming a 1024-pixel width
$start = "19500000";
$end = "20130000";
$width = 1024;
$height=768;

# the header
print read_file("canvas-header.html");

# TODO: in real select, we can limit to events longer than a certain
# min (ie, longer than the min draw threshold)

# birth/death of same person, both occurring 1950-2013
$query = "SELECT e1.shortname, e1.longname, e1.stardate AS birth, e2.stardate AS death FROM events e1 JOIN events e2 ON (e1.shortname=e2.shortname) AND e1.type='BIRTHS' AND e2.type='DEATHS' AND e1.stardate>$start AND e2.stardate<$end ORDER BY e2.stardate DESC LIMIT 5";

@res = sqlite3hashlist($query,"/home/barrycarter/BCINFO/sites/DB/history.db");

# life length (not accurate, treating month/day as decimal, which it's
# not). In theory, could sort without this intermediate step (ended up
# doing w/o intermediate step after all)

# sort, finding shortest events first
@res = sort {$a->{death}-$a->{birth} <=> $b->{death}-$b->{birth}} @res;

# go through events
for $i (@res) {
  # start and end pixels (if we choose to draw this)
  $spixel = ($i->{birth}-$start)/($end-$start)*$width;
  $epixel = ($i->{death}-$start)/($end-$start)*$width;
  # and print it
  print "ctx.fillRect ($spixel, $height/2, 5, 10);\n";
  print "ctx.fillText('$i->{shortname}', $spixel, $height/2);\n";

  debug("PIX: $spixel-$epixel");
}

print "</script>\n";




