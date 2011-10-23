#!/bin/perl

# Uses Delaunay triangulation to map stuff, using average of vertex
# values (qhull does the work)

push(@INC,"/home/barrycarter/BCGIT");
require "bclib.pl";
require "bc-weather-lib.pl";

# all work in temporary directory
chdir("/tmp/bcdtp");

# obtain current weather
@w = recent_weather();

for $i (@w) {
  %hash = %{$i};

#  if (++$count>5) {warn "TESTING"; last;}

  # confirm numeric
  unless ($hash{latitude}=~/^[0-9\-\.]+$/ && $hash{longitude}=~/^[0-9\-\.]+$/) {
#    warn("BAD DATA: %hash");
    next;
  }

  push(@points, "$hash{longitude} $hash{latitude}");

  # @w contains even bad reports, so @wok contains good only
  push(@wok, $i);

}

write_file(join("\n", (2, $#points+1, @points)), "file1");
system("qdelaunay i < file1 > file2");

# skip first line, process rest
@tri = split(/\n/, read_file("file2"));
shift(@tri);

for $i (@tri) {
  # data for the three points
  @p = map($_=$wok[$_],split(/\s+/, $i));

  # the triangle
  @tripoints = ();
  $tempavg = 0;
  for $j (@p) {
    %hash = %{$j};
    push(@tripoints, "$hash{longitude},$hash{latitude}");
    $tempavg += ($hash{temp_c}*1.8+32)/3;
    debug("BETA: $hash{longitude}, $hash{latitude}, $hash{temp_c}");
  }

  $hue=5/6-($tempavg/100)*5/6;
  debug("$tempavg -> $hue ALPHA");
  $tri = join(" ",@tripoints);
  $col = hsv2rgb($hue, 1, 1);

  push(@svg,  "<polygon points='$tri' style='fill:$col' />");
}

open(A,">file3.svg");
print A << "MARK";
<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
 width="1080px" height="540px"
 viewBox="-180 -90 360 180">
MARK
;

print A join("\n", @svg);
print A "\n</svg>\n";
