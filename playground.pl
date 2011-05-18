#!/bin/perl

# Script where I test code snippets; anything that works eventually
# makes it into a library or real program

# chunks are normally separated with 'die "TESTING";'

require "bclib.pl";

$data = read_file("data/moonxyz.txt");
@l = nestify($data);

# hermite testing
# <h>No hermits were harmed during these tests</h>

@xvals = @{$l[0][0][2]};
@yvals = @{$l[0][0][3]};

# convert mathematica to perl form
map(s/\*\^/e+/, @xvals);
map(s/\*\^/e+/, @yvals);

# 3.5107128*^9 is April 2nd at 6am is our test case

debug("ALPHA");
debug(hermite(3510755800, \@xvals, \@yvals));

# debug("X",@xvals,"Y",@yvals);

die "TESTING";

sub jd2unix {return(($_[0]-2440587.5)*86400);}
sub unix2jd {return(($_[0]/86400+2440587.5));}

=item hermite($x, \@xvals, \@yvals)

Computes the Hermite interpolation at $x, for the Hermite-style cubic
spline given by @xvals and @yvals

NOT YET DONE!

=cut

sub hermite {
  debug("HERMITE",@_);
  my($x,$xvals,$yvals) = @_;
  my(@xvals) = @{$xvals};
  my(@yvals) = @{$yvals};

  # compute size of x intervals, assuming they are all the same
  my($intsize) = ($xvals[-1]-$xvals[0])/$#xvals;

  # what interval is $x in and what's its position in this interval?
  # interval 0 = the 1st interval
  my($xintpos) = ($x-$xvals[0])/$intsize;
  my($xint) = floor($xintpos);
  my($xpos) = $xintpos - $xint;

  # slope for immediately preceding and following intervals?
  # NOTE: we do NOT use the slope for this interval itself (strange, but true)
  # <h>At least, I think it's strange, and I've been assured that it's true</h>
  my($pslope) = ($yvals[$xint]-$yvals[$xint-1])/$xint;
  my($fslope) = ($yvals[$xint+2]-$yvals[$xint+1])/$xint;

  debug("XPOS: $xpos");
  debug($xint, $xpos, $yvals[$xint-1], $yvals[$xint], $yvals[$xint+1], $vals[$xint+2]);
  debug("HERM",h00($xpos), h10($xpos), h01($xpos), h11($xpos), "END");
  return h00($xpos)*$yvals[$xint] + h10($xpos)*$pslope + h01($xpos)*$yvals[$xint+1] + h11($xpos)*$fslope;

  # TODO: defining the Hermite polynomials here is probably silly (and
  # doesn't have the effect I want: hij are available globally)

  sub h00 {(1+2*$_[0])*(1-$_[0])**2}
  sub h10 {$_[0]*(1-$_[0])**2}
  sub h01 {$_[0]**2*(3-2*$_[0])}
  sub h11 {$_[0]**2*($_[0]-1)}

}

# TODO: cache like crazy!
# moonxyz.txt contains 10 arrays

die "TESTING";

# read_mathematica("data/sunxyz.txt");

$all = read_file("data/sunxyz.txt");

while ($all=~s/[\{\[]([^\{\}\[\]]*)[\}\]]/f2($1)/eisg) {}

# debug($all);
# debug($res[441]);
# debug($res[431]);
# debug($res[400]);
# debug($res[367]);
# debug($res[25]);

# debug("RES",@res);
$all=~s/\s//isg;
debug($all);

@res = f3($all);

debug("RES",unfold(@res));

sub f3 {
  my(@ret);
  my($val) = @_;
  for $i (split(/\,\s*/,$val)) {
    if ($i=~/RES(\d+)/) {
      push(@ret, [f3($res[$1])]);
    } else {
      push(@ret, $i);
    }
  }

  return @ret;
}


# NOTES: only reads (possibly nested) lists, uses static var, returns ref

sub read_mathematica {
  my($file) = @_;
  if ($static{mathematica}{$file}) {return $static{mathematica}{$file};}
  my($data) = read_file($file);

  # only what's between the {}
  $data=~m%(\{.*?\})%isg || warnlocal("No braces: $data");

  # convert mathematica's {} to []
  $data=~tr/\{\}/\[\]/;
  # remove bad chars
  $data=~s/\`//isg;

  debug($data);

  my(@l) = eval($data);
  debug($@);

  debug(@l);

}



die "TESTING";

use Math::MatrixReal;

my($a) = Math::MatrixReal->new_random(5, 5);

debug($a);


die "TESTING";

# TESTS
# order is irrelevant
# print convert_time(1001, "%M minutes %S seconds")."\n";
# print convert_time(1001, "%S seconds %M minutes")."\n";

# just in seconds
# print convert_time(1001, "%S seconds")."\n";

# hours and seconds (no minutes)
# print convert_time(3600*7+60*4, "%H hours, %S seconds")."\n";
# with minutes, but weird order
# print convert_time(3600*7+60*4, "%M minutes, %H hours, %S seconds")."\n";

# larger value testing
# below doesn't agree with calendar because of leap year
# print convert_time(time(), "%Y years, %m months, %d days")."\n";
print convert_time(time(), "%Y years, %m months, %d days, %H hours, %M minutes, %S seconds")."\n";
# print convert_time(time(), "%U weeks")."\n";
# print convert_time(time(), "%S seconds plus %U weeks")."\n";
# print convert_time(time(), "%S seconds")."\n";

die "TESTING";

use Astro::Coord::ECI::Moon;
my $loc = Astro::Coord::ECI->geodetic (0, 0, 0);
$moon = Astro::Coord::ECI::Moon->new ();
@almanac = $moon->almanac($loc, time());

debug(unfold(@almanac));

die "TESTING";

use PDL::Transform::Cartography;
        $a = earth_coast();
        $a = graticule(10,2)->glue(1,$a);
        $t = t_mercator;
        $w = pgwin(xs);
        $w->lines($t->apply($a)->clean_lines());

die "TESTING";


# debug(to_mercator(-85,0,"order=xy"));

debug(from_mercator(0,0));


sub from_mercator {
  my($x, $y, $options) = @_;
  my(%opts) = parse_form($options);
  return atan(sinh($y)), $x*360-180;
}


=item project($lay, $lox, $proj, $dir)

Projects latitude/longitude $lay/$lox to xy coordinates for the
projection $proj; if $dir is 1, does the reverse and converts xy
coordinates to latitude/longitude.

$lax: the latitude or y-coordinate
$loy: the longitude or x-coordinate

(note the order of the xy coordinates are reversed, so that latitude
matches y and longitude matches x)

Note: center of map is 0,0; x and y values range from -0.5 to +0.5

NOT YET DONE!

=cut

sub project {
  my($lay, $lox, $proj, $dir) = @_;

  # this is an ugly way to do this (if/elsif/else)

  # Specifically, google's mercator projection
  if ($proj=~/^merc/) {
    if ($dir) {
      return (atan(sinh($lay)), $lox*360);
    } else {
      return (-1*(log(tan($PI/4+$lay/180*$PI/2))/2/$PI), $lox/360);
    }
  }
}

=item to_mercator($lat,$lon)

Converts $lat, $lon (degrees) to google maps' yx Mercator projects
(top left = 0,0; bottom right = 1,1); can return abs($y)>1 for far
south/north latitudes. Options:

 order=(xy|yx): return coordinates in xy or yx format (latter is default)

NOTE: return order is yx, not xy

=cut

sub to_mercator {
  my($lat,$lon, $options) = @_;
  my(%opts) = parse_form($options);

  my($y) = 1/2-1*(log(tan($PI/4+$lat/180*$PI/2))/2/$PI);
  if ($opts{order} eq "xy") {
    return ($lon+180)/360, $y;
    # else below is actually optional, but omitting it is confusing
  } else {
    return $y,($lon+180)/360;
  }
}




die "TESTING";

@pts = (35.08, -106.66, 48.87, 2.33, 71.26826, -156.80627, -41.2833,
174.783333, -22.88, -43.28);

debug("ALPHA");
debug(unfold(voronoi(\@pts,"infinityok=1")));

die "TESTING";


=item hashlist2sqlite

DOC ME! (but test me first!)

=cut

sub hashlist2sqlite {
  my($hashs, $tabname, $outfile) = @_;
  my(%iskey);
  my(@queries);

  for $i (@{$hashs}) {
    my(@keys,@vals) = ();
    my(%hash) = %{$i};
    for $j (sort keys %hash) {
      $iskey{$j} = 1;
      push(@keys, $j);
      push(@vals, "\"$hash{$j}\"");
    }

    push(@queries, "INSERT INTO $tabname (".join(", ",@keys).") VALUES (".join(", ",@vals).");");
  }

  debug(@queries);
}

exit 1;

die "TESTING";

$all="{this, {is, some, {deeply, nested}, text}, for, you}";

# $all = read_file("data/sunxyz.txt");

# could try to match newline, but this is easier
$all=~s/\n/ /isg;

# <h>It vaguely annoys me that Perl doesn't require escaping curly braces</h>
while ($all=~s/{([^{}]*?)}/handle($1)/seg) {
  $n++;
  debug("AFTER RUN $n, ALL IS:",$all);
}

debug(*$all);

debug("ALL",$all);

debug("ALL",@{$all});


sub handle {
  my($str) = @_;
  debug("Handling $str");
  return \{split(/\,\s*/, $str)};
  debug("L IS:",@l);
  debug("Returning ". \@l);
  return \@l;
}

die "TESTING";

$all="{this, {is, some, {deeply, nested}, text}, for, you}";

while ($all=~s/\{([^{}]*?)\}/f($1)/seg) {
  debug("ALL: $all");
}

sub f {
  my($x) = @_;
  return \$x;
}

debug(*$all);

# sub f {return \{split(",",$_[0])};}

# debug(unfold(@res));


die "TESTING";

debug(project(1,0,"mercator",1));


die "TESTING";

# RPC-XML

# get password
$pw = read_file("/home/barrycarter/bc-wp-pwd.txt"); chomp($pw);

# using raw below so i can cache and stuff

$req=<<"MARK";
<?xml version="1.0"?>
<methodCall> 
<methodName>metaWeblog.newPost</methodName> 
<params> 
<param> 
<value> 
<string>MyBlog</string> 
</value> 
</param> 
<param> 
<value>admin</value> 
</param> 
<param> 
<value> 
<string>$pw</string> 
</value> 
</param> 
<param> 
<struct> 

<member> 
<name>description</name> 
<value>Dr. Quest is missing while on an expedition to find the Yeti. Jonny and his friends head to the Himalayas to find him, but run into another scientist who's determined to bring back the Yeti.
</value>
</member> 
<member> 
<name>title</name> 
<value>Expedition To Khumbu</value> 
</member> 
<member> 
<name>dateCreated</name> 
<value>
<dateTime.iso8601>20040716T19:20:30</dateTime.iso8601> 
</value> 
</member> 
</struct> 
</param> 
<param>
 <value>
  <boolean>1</boolean>
 </value>
</param> 
</params> 
</methodCall>
MARK
;

write_file($req,"/tmp/rpc1.txt");
system("curl -o /tmp/rpc2.txt --data-binary \@/tmp/rpc1.txt http://wordpress.barrycarter.info/xmlrpc.php");

die "TESTING";

# reading Mathematica interpolation files

$all = read_file("sample-data/manytables.txt");

while ($all=~s/InterpolatingFunction\[(.*?)\]//s) {
  $func = $1;

  # get rid of pointless domain
  # {} are not special to Perl?!
  $func=~s/{{(.*?)}}//;

  # xvals
  $func=~s/{{(.*?)}}//s;
  $xvals = $1;
  debug("XV: $xvals");

  # split and fix
  @xvals=split(/\,|\n/s, $xvals);

  for $i (@xvals) {
    $i=~s/(.*?)\*\^(\d+)/$1*10**$2/iseg;
  }

  debug($func);

}

