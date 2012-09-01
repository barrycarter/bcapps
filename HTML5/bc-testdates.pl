#!/bin/perl

# puts test dates into an SVG for zooming log timeline
# --nodb: don't query the db, just use moreevents.txt

require "/usr/local/lib/bclib.pl";

print << "MARK";
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" id="svg" 
 width="1024px" height="600px" viewbox="-512 -300 1024 600">
 <g id="g">
MARK
;

# random historical events, unless nodb set (query time is nontrivial)
unless ($globopts{nodb}) {
  @res= sqlite3hashlist("SELECT * FROM (SELECT * FROM events ORDER BY RANDOM() LIMIT 100) ORDER BY stardate", "/home/barrycarter/BCINFO/sites/DB/history.db");
}

# also picking up ALL event from moreevents.txt
for $i (split(/\n/,read_file("/home/barrycarter/BCGIT/TIMELINE/moreevents.txt"))) {
  debug("I: $i");
}

# die "TESTING";

for $i (0..$#res) {
  %row= %{$res[$i]};
  # TODO: this is inaccurate and for testing only
  $year = $row{stardate}/10000.;
  $year = 2013-$year;
  # in seconds
  $pos = -log($year*365.2425*86400)*100;

#  print qq%<text title="$row{shortname} ($row{stardate})" x="$pos" y="300" fill="black" style="font-size:1" transform="rotate(-90,$pos,0)">$row{stardate}</text>\n%;

#  print qq%<rect title="$row{shortname} ($row{stardate})" x="$pos" y="300" height=1 width=300 fill="black" transform="rotate(-90,$pos,0)" />\n%;

  print qq%<rect title="$row{shortname} ($row{stardate})" x="$pos" y="-10" height="20" width="0.5" fill="black" />\n%;

#  print qq%<rect title="$row{shortname} ($row{stardate})" x="$pos" y="300" height=600 width=600 fill="black" />\n%;

}

=item comment

for($i=-2000;$i<=2000;$i+=100) {
  debug("I: $i");
  if ($i>0) {
    $pos = log($i*365.2425*86400)*100;
  } elsif ($i<0) {
    $pos = -log(-$i*365.2425*86400)*100;
  } else {
    $pos = 0;
  }

  debug("POS: $pos");

  print qq%<text x="$pos" y="0" fill="black" style="font-size:15" transform="rotate(-90,$pos,0)">$i</text>\n%;

}

=cut

print "</g></svg>\n";

print read_file("svgtry.html");

