#!/bin/perl

# puts test dates into an SVG for zooming log timeline

require "/usr/local/lib/bclib.pl";

print << "MARK";
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" id="svg" 
 width="1024px" height="600px" viewbox="-512 -300 1024 600">
 <g id="g">
MARK
;


# some historical events
@res = sqlite3hashlist("SELECT * FROM events ORDER BY RANDOM() LIMIT 100", "/home/barrycarter/BCINFO/sites/DB/history.db");

for $i (@res) {
  %row= %{$i};
  # TODO: this is inaccurate and for testing only
  $year = $row{stardate}/10000.;
  $year = 2013-$year;
  # in seconds
  $pos = log($year*365.2425*86400)*100;

  print qq%<text x="$pos" y="300" fill="black" style="font-size:1" transform="rotate(-90,$pos,0)">$row{shortname} ($row{stardate})</text>\n%;

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

