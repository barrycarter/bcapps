#!/bin/perl

# attempts to generate the HTML5 canvas for "signifigant events"
# (currently undefined) between two dates

require "/usr/local/lib/bclib.pl";

# test case: 1950-present
# assuming a 1024-pixel width
$start = 1900*10000;
$end = 2000*10000;
$width = 800;
$height=600;

# the header
print read_file("canvas-header.html");

# TODO: in real select, we can limit to events longer than a certain
# min (ie, longer than the min draw threshold)

# birth/death of same person
$query = "SELECT e1.shortname, e1.longname, e1.stardate AS birth, e2.stardate AS death FROM events e1 JOIN events e2 ON (e1.shortname=e2.shortname) AND e1.type='BIRTHS' AND e2.type='DEATHS' AND e1.stardate>$start AND e2.stardate<$end AND e1.stardate<e2.stardate ORDER BY RANDOM() LIMIT 50";

@res = sqlite3hashlist($query,"/home/barrycarter/BCINFO/sites/DB/history.db");

# life length (not accurate, treating month/day as decimal, which it's
# not). In theory, could sort without this intermediate step (ended up
# doing w/o intermediate step after all)

# sort, finding shortest events first
@res = sort {$a->{death}-$a->{birth} <=> $b->{death}-$b->{birth}} @res;
@res = reverse(@res);

# TODO: this is just testing
@res = sort {$a->{birth} <=> $b->{birth}} @res;
@res = sort {$a->{death} <=> $b->{death}} @res;
@res = sort {($a->{death}+$a{birth}) <=> ($b->{death}+$b{birth})} @res;

# go through events
for $i (@res) {
  # start and end pixels (if we choose to draw this)
  $spixel = ($i->{birth}-$start)/($end-$start)*$width;
  $epixel = ($i->{death}-$start)/($end-$start)*$width;

  # TODO: if (decide not to print) {next;}

  # removed dreaded apostrophe of doom
  $i->{shortname}=~s/\'//isg;

  $ypos+=15;

  # and print it
#  print "ctx.fillStyle = 'rgb(255,255,255)';\n";
  print "ctx.strokeStyle = 'rgb(255,0,0)';\n";
  print "ctx.strokeWidth = 15;\n";
  print "ctx.strokeRect($spixel, $ypos, $epixel-$spixel, 10);\n";
#  print "ctx.fillStyle = 'rgb(0,0,0)';\n";
  print "ctx.fillText('$i->{shortname} ($i->{birth} - $i->{death})', $spixel, $ypos+9);\n";

  debug("PIX: $spixel-$epixel");
}

print "</script>\n";




