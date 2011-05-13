#!/bin/perl

# Script where I test code snippets; anything that works eventually
# makes it into a library or real program

# chunks are normally separated with 'die "TESTING";'

require "bclib.pl";

debug(unfold(nadex_quotes("USD-CAD","nointra=1")));

=item nadex_quotes($parity, $options)

Obtains NADEX option quotes for $parity, given as "USD-CAD" (for example).

Return values are $hash{"USD-CAD"}{strike}{Unix_exp_time}{bid|ask}

Options:
  nointra=1: Do not obtain intradaily options
  cache=t: Cache results for t seconds (default: 15m)

This function REQUIRES a file called "nadex-cookie.txt":

To obtain this cookie (requires Firebug):
  - Log into nadex.com (bugmenot.com has a demo username/pw)
  - Turn on Firebug and go to the Net/All panel
  - On main screen, click on any specific option
  - In Firebug, look at your first GET request
  - Copy/paste the cookie into a nadex-cookie.txt file
  - The cookie will look something like sample-data/nadex-cookie.txt
  - Do not use Firefox's cookies.sqlite: it doesn't work

TODO: automate cookie obtaining procedure

=cut

sub nadex_quotes {
 my($parity, $options) = @_;
 my(%hash); # to hold return values
 $parity = uc($parity);
 my($cookie) = read_file("/home/barrycarter/nadex-cookie.txt");
 chomp($cookie);
 # putting defaults first lets $options override
 my(%opts) = parse_form("cache=900&$options");

 # TODO: using /tmp here is ugly, but I don't see a way around it.
 # I can't use cache-command, since I'm using curl's wildcarding feature

 # commands to obtain daily, weekly, and intra-daily options
 my($daily_cmd) = "curl -v -L -k -o /tmp/daily#1-#2.txt -v -L -H 'Cookie: $cookie' 'https://demo.nadex.com/dealing/pd/cfd/displaySingleMarket.htm?epic=N{B}.D.$parity.OPT-1-[1-21].IP'";
 my($weekly_cmd) = "curl -v -L -k -o /tmp/weekly#1-#2.txt -v -L -H 'Cookie: $cookie' 'https://demo.nadex.com/dealing/pd/cfd/displaySingleMarket.htm?epic=N{B}.W.USD-CAD.OPT-1-[1-14].IP'";
 my($intra_cmd) = "curl -v -L -k -o intra#1-#2-#3.txt -v -L -H 'Cookie: $cookie' 'https://demo.nadex.com/dealing/pd/cfd/displaySingleMarket.htm?epic=N{B}.I.USD-CAD.OPT-[1-8]-[1-3].IP'";

 # and obtain data (since I'm using curl -o, below doesn't actually
 # return anything, so I ignore the return value)

 cache_command($daily_cmd, "age=$opts{cache}");
 cache_command($weekly_cmd, "age=$opts{cache}");
 unless ($opts{nointra}) {cache_command($daily_cmd, "age=$opts{cache}");}

 # parse results
 # TODO: in theory, could get old intra results here
 for $i (glob ("/tmp/daily*.txt /tmp/weekly*.txt /tmp/intra*.txt")) {
   my($all) = read_file($i);

   # option name
   $all=~m%<title>(.*?)</title>%;
   $title = $1;
   $title=~s/\|.*//;
   $title=~s/>\s+/>/g;

   # skip bad
   if ($title=~/^sorry/i) {next;}

   # title pieces
   my($par, $strdir, $tim, $dat) = split(/\s/, $title);
   for $j ($tim,$dat) {$j=~s/[\(\)]//isg;}
   $strdir=~s/>//isg;

   # Unix time
   $utime = str2time("$dat $tim EDT");

   # last updated time
   while ($all=~s%<span class="updated updateTime left">(.*?)</span>%%g) {
     my($updated)=$1;
   }

   # convert updated to time + calculate minute + price at minute
   my($uptime) = str2time("$updated EDT");

   # grab values
   my(@vals)=();
   while ($all=~s%<span class="valueNotFX">(.*?)</span>%%) {
     $val = $1;
     $val=~s/<.*?>//isg;
     push(@vals, $val);
   }

  ($obid, $oask) = @vals;

   # TODO: not sure skipping no bid/ask is a good idea here
   if ($obid eq "-" || $oask eq "-") {next;}

   $hash{$par}{$strdir}{$utime}{bid} = $obid;
   $hash{$par}{$strdir}{$utime}{ask} = $oask;
   $hash{$par}{$strdir}{$utime}{updated} = $uptime;
 }
 return %hash;
}

# debug("ONE: $1");

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

