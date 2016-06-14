#!/bin/perl

# To help someone create a montage of images/text

require "/usr/local/lib/bclib.pl";

# work directory for this project (this site is not in git because the
# images are not freely usable)

chdir("/home/barrycarter//home/user/BCINFO3-PRIV/sites/test/20160613");

my(@text) = split(/\r\n/, read_file("1.txt"));

# @out holds the output text for both the "buttons" page and the main page
my(@out);

# make indices match
unshift(@text, "");

push(@out,"<table border>");

for $i (1..3) {
  push(@out, "<tr>");
  for $j (1..5) {
    $n++;
    push(@out,"<td><img src='$n.jpg'><br>$text[$n]</td>");
  }
  push(@out,"</tr>");
}

push(@out,"</table>");

my($out) = join("\n",@out);

write_file(join("\n",@out), "guitars.html");

open(A,">table.html");

print A "<table border><tr><th><a href='guitars.html'>Guitars</a></th></tr>\n";
print A "<tr><td>$out</td></tr></table>\n";

close(A);
