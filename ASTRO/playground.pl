#!/bin/perl

# libnova playing

require "/usr/local/lib/bclib.pl";

# on an ortho map, what goes in the .2,.3 to .3,.4 square (reverse
# quadrangling), in terms of a mercator map

# ortho limits: +-6378137 for x coord, same for y coord

# .1 = 637813.7, .2 = 1275627.4, .3 = 1913441.1, .4 = 2551254.8, .5 = 3189068.5

# cs2cs -e 'ERR ERR' +proj=ortho +to +proj=merc
# .2,.3 to 1347216.35 1961346.56 (NW)
# .3,.4 to 2126937.58 2685005.75 (SE)
# .2,.4 to 1403113.46 2685005.75 (SW)
# .3,.3 to 2040458.85 1961346.56 (NE)

# merc limits: +-20037508.34 in x direction, unlimited in y direction

# merc x range: 1347216.35 to 2126937.58
# merc y range: 1961346.56 to 2685005.75

# scaled x: .0672347243 to .1061478075
# scaled y: .0978837551 to .1339989835

# xwidth (scaled): .0389130832
# ywidth (scaled): .0361152284

# so about 1/32 width or 1/2^5 so level 5 slippy tile?

# roughly x tile 2
# roughly y tile 3

# better (Spain-ish): .4 - .5 in the x range and .1 - .2 in y range

# unscaled x: 2638741.07 to 3415783.48
# unscaled y: 635682.73 to 1284515.71

# scaled x: .1316900796 to .1704694726
# scaled y: .0317246395 to .0641055608

# right about level 5 tiles, x starting at 4.21ish, y at 1ish

# 2,1,1... children are 3,3,3 then 4,7,6 then 5,15,12


open(A,"/home/barrycarter/SPICE/KERNELS/jup310.xsp");
seek(A,253221110,SEEK_SET);

while (<A>) {
  debug(ieee754todec($_));
}

die "TESTING";

open(A,"/home/barrycarter/SPICE/KERNELS/de430.xsp");
seek(A,57896433,SEEK_SET);

# while (<A>) {
#   debug("THUNK: $_");
# }

# target: 464137200 = roughly today

# binary search (TODO: we know file structure (linear), so can do better)

my($f) = sub {debug("TESTING: $_[0]"); return test1(A,$_[0], "'A8C^5'")-464137200;};

debug(findroot($f, 57896433, .9*77810085, 0, 10));

my($sec) = test1(A, 66314639, "'A8C^5'");
debug("SEC: $sec");

# seek(A,66314639,SEEK_SET);

while (<A>) {
  debug(ieee754todec($_));
}

# horizons_data(399,str2time("2014-09-16 GMT"),str2time("2014-12-31 GMT"),86400);

=item horizons_data($object,$stime,$etime,$delta)

Use HORIZONS (telnet interface) to return vector coordinates of
$object (defined as a number as in /ASTRO/planet-ids.txt) from $stime
to $etime (Unix times) in intervals of $delta seconds

Uses caching when possible

=cut

sub horizons_data {
  my($object,$stime,$etime,$delta) = @_;
  local(*A);

  # how many steps (TODO: can't use seconds directly, hmmm)
  my($steps) = ceil(($etime-$stime)/$delta);

  # convert to preferred format
  $stime = strftime("%Y-%m-%d %H:%M:%S",gmtime($stime));
  $etime = strftime("%Y-%m-%d %H:%M:%S",gmtime($etime));

  # string we use for hashing
  my($str) = "target=$object&sdate=$stime&edate=$etime&interval=$steps";
  my($ofile) = sha1_hex($str);

  # do we have it cached?
  unless (-f "/var/tmp/HORIZONS/$ofile") {
    # no such file, so...
    my(%hash) = parse_form($str);
    my($all) = read_file("/home/barrycarter/BCGIT/ASTRO/template.tcl");
    $all=~s/\$([a-z]+)/$hash{$1}/sg;
    open(A, "|expect - > /var/tmp/HORIZONS/$ofile");
    print A $all;
    close(A);
  }

  my($data) = read_file("/var/tmp/HORIZONS/$ofile");
  $data=~s/\r//g;
  $data=~/\$\$SOE\s*(.*?)\$\$EOE/s;
  debug("GOT: $1");
}



die "TESTING";

# using template

my(%hash) = parse_form("target=399&sdate=2014-09-01&edate=2014-10-01&interval=12h");
my($all) = read_file("/home/barrycarter/BCGIT/ASTRO/template.tcl");
$all=~s/\$([a-z]+)/$hash{$1}/esg;
debug("ALL: $all");
# TODO: cache
local(*A);
open(A,"|expect - > /tmp/output.txt");
print A $all;
close(A);

# required: $target, $sdate, $edate, $interval






die "TESTING";

$str= << "MARK";
page
599
e
v
@0
frame
14-Sep-2014
14-Oct-2014
1h
y
x
MARK
;


open(A,"|ncat -t ssd.jpl.nasa.gov 6775 > /tmp/output.txt");

for $i (split(/\n/, $str)) {
  sleep(1);
  print A "$i\r\n";
}

# allow negotiation
# sleep(5);


die "TESTING";

# find position of Europa (to Jupiter) for today, generalize later

# from array-offsets.txt (I will copy this here later)
# jup310.xsp:7214658:129945847:BEGIN_ARRAY 2 7158904
# jup310.xsp:14380563:253221110:BEGIN_ARRAY 3 4772702

open(A,"/home/barrycarter/SPICE/KERNELS/jup310.xsp");
# seek(A,129945847,SEEK_SET);

# I know the interval for Europa is this (in hex)
$break="'A8C^4'";

for ($i=129945847; $i<253221110; $i+=(253221110-129945847)/100) {
  debug("I: $i", test1(A,$i,$break));
}

# debug(test1((A,191583479,$break)));

# for $i (0..98) {
#  $x=<A>;
#  debug("THUNK1: $x");
# }

# my($pos) = find_str_in_file(A, 191583479+1000, "'A8C^4'");

# for $i (1..10) {
#  debug(current_line(A,"\n",-1));
# }

# from the comments, I know Europa has 15+1 degree polynomials (and
# there are always 6 of them), so 96 rows = coeffs, meaning, in
# theory, any 97 rows will have AT LEAST ONE Julian date (but using
# 98, since we might be the middle of a line)

# seek to middle of array
# seek(A,191583479,SEEK_SET);

# for $i (0..98) {
#  $x=<A>;
#  debug("THUNK: $x");
# }

=item test1($fh, $pos, $delim)

Given an XSP filehandle, a position in that file, and a delimiter, return
the Julian date associated with that position.

=cut

sub test1 {
  my($fh, $pos, $delim) = @_;
  my($temp);
  # TODO: should I require caller to set $pos?
  seek($fh, $pos, SEEK_SET);
  my($pos) = find_str_in_file($fh, $pos, $delim);
  # Julian date is two lines before delimiter (3 because we are end of line)
  for $i (1..3) {$temp = current_line($fh, "\n", -1);}
  return ieee754todec($temp);
}


=item ieee754todec($str,$options)

Converts $str in IEEE-754 format to decimal number. If $str is not in
IEEE-754 format, return it as is (however, is $str is
apostrophe-quoted, will remove apostrophes)

WARNING: Perl does not have sufficient precision to do this 100% correctly.

Options:

mathematica=1: return in Mathematica format (exact), not decimal

=cut

sub ieee754todec {
  my($str,$options) = @_;
  my(%opts) = parse_form($options);

  $str=~s/\'//g;
  unless ($str=~/^(\-?)([0-9A-F]+)\^(\-?([0-9A-F]+))$/) {return $str;}
  my($sgn,$mant,$exp) = ($1,$2,hex($3));
  my($pow) = $exp-length($mant);

  # for mathematica, return value is easy
  if ($opts{mathematica}) {return qq%${sgn}FromDigits["$mant",16]*16^$pow%;}

  # now the "real" (haha) value
  my($num) = hex($mant)*16**$pow;
  if ($sgn eq "-") {$num*=-1;}
  return $num;
}

=item find_str_in_file($fh, $pos, $str)

Given an open filehandle $fh and a starting byte offset $pos, read
lines [not bytes] until finding one exactly matching $str. Return the
byte position of $str.

Effective does what "fgrep -xb" does, but semi-efficiently

=cut

sub find_str_in_file {
  my($fh, $pos, $str) = @_;

  # seek to initial position
  seek($fh, $pos, SEEK_SET);

  # read...
  # TODO: handle EOF
  while (<$fh>) {
    chomp;
    if ($_ eq $str) {return tell($fh);}
  }
}

# while(<A>) {debug($_);}

die "TESTING";

# getting data back from mercury file

# mercury stored in bitfields like this: {43, 42, 39, 37, 34, 31, 28,
# 26, 23, 21, 19, 18, 15, 11, 43, 41, 39, 36, 34, 31, 28, 26, 23, 21,
# 19, 18, 15, 11, 42, 41, 38, 35, 33, 30, 27, 25, 23, 20, 18, 17, 14,
# 10} 1145 bits total

# "F56277EC70CAD^3" appears early in jup310.xsp, can we find it in jup310.bsp?

open(A,"/home/barrycarter/SPICE/KERNELS/jup310.bsp");

read(A,my($data),1000000);

if ($data=~/(\xe7)$/) {
  debug("FOUND: $1");
}

# debug($data);

die "TESTING";

# the bits for mercury's 42 coefficients

@merc = (43, 42, 39, 37, 34, 31, 28, 26, 23, 21, 19, 18, 15, 11, 43, 41, 39, 36, 34, 31, 28, 26, 23, 21, 19, 18, 15, 11, 42, 41, 38, 35, 33, 30, 27, 25, 23, 20, 18, 17, 14, 10);

# to find mercury, find which 4 day chunk we are in:

# -632707200 = unix time of start of data

$time = time();

# 4 days per chunk, 86400 seconds per day (chunk 0 = first chunk)
$chunk = ceil(($time+632707200)/86400/4)-1;
debug("CHUNK: $chunk");

open(A,"/home/barrycarter/20140826/mercury4.bin");
my(@bits) = seek_bits(A, $chunk*1145+1, 1145);

# read bits in chunks
for $i (@merc) {
  # the first $i remaining bits (indexes 0 to $i-1)
  my(@ibits) = splice(@bits,0,$i);
  debug("ALPHA",scalar(@ibits));
  # ignore the last 16 bits for now (non-integer part)
#  splice(@ibits,-16,16);
  debug("BRAVO",scalar(@ibits));

  # compute total
  my($total) = 0;
  for $j (@ibits) {
    $total = $total*2+$j;
  }

  $total -= 2**(scalar(@ibits)-1);
  $total /= 65536;

#  debug("IBITS:",@ibits);
  debug("TOTAL: $total");
}

die "TESTING";

debug("FM", join(",",@bits[0..42]));

debug("LEN:",scalar(@bits));
# the first 43 bits
my(@first) = @bits[0..42];

# just the km part (43-16 = 27 bits)
for $i (@bits[0..26]) {
  $tot = $tot*2+$i;
}

$tot -= 2**26;

debug("TOT: $tot");

die "TESTING";


debug("PACK",pack("I",@first));

debug("BITS",@first);




=item seek_bits($fh, $start, $num)

Seek to bit (not byte) $start in filehandle $fh, and return the next
$num bits (as a list).

=cut

sub seek_bits {
  my($fh, $start, $num) = @_;
  # the byte where this bit starts and the offset
  my($fbyte, $offset) = (floor($start/8), $start%8);
  # the number of bytes to read ($offset does affect this)
  my($nbytes) = ceil($num+$offset)/8;

  seek($fh, $fbyte, SEEK_SET);
  read($fh, my($data), $nbytes);
  my(@ret) = split(//, unpack("B*", $data));
  # return requested bits
  return @ret[$offset-1..$offset+$num];
}

debug(num2base(4416951459393930,256));

die "TESTING";

# chebyshev

open(A,"bzcat /home/barrycarter/BCGIT/ASTRO/ascp1950.430.bz2|");

while (<A>) {
  # strip leading spaces and split into fields
  s/^\s+//isg;
  @fields = split(/\s+/, $_);

  # if this line has two integers, it's a section boundary
  # which means next line will be date spec
  if ($#fields==1 && $fields[0]=~/^\d+$/ && $fields[1]=~/^\d+$/) {
    $bound = 1;

    # TESTING ONLY: if we hit a boundary and have @coeffs, drop out of loop
    if ($#coeffs>2) {last;}

    next;
  }

  # convert from Fortran to Perl
  for $i (@fields) {$i=~s/^(.*?)D(.*)$/$1*10**$2/e;}

  # if we just hit a boundary, get date spec
  if ($bound) {
    ($sdate, $edate) = @fields;
    # indicate we are no longer at a boundary
    $bound = 0;
    # and store the third item in this row which is the first coefficient
    @coeffs = $fields[2];
    next;
  }

  # debug("IGNORING: $sdate-$edate");
  # this is 2011-01-01 00:54:00 GMT, close to earliest time I have data for
  if ($sdate <= 2455562.5375000000) {next;}

#  debug("THUNK: $_","FIELDS",@fields);
  push(@coeffs, @fields);
}

debug("$sdate-$edate");

# the first chunk is: 2455568.5-2455600.5

debug($#coeffs);

die "TESTING";

# the first 14 coeffs are the x coordinate of mercury for first 8 days
for $i (0..13) {
  push(@sum, sprintf("%f*ChebyshevT[$i,x]",$coeffs[$i]));
}

# the coeffs from 14-27 and 28-41 and y and z mercury coords first 8 days
# below are coeffs for x position mercury next 8 days
for $i (42..42+13) {
  $j = $i-42;
  push(@sum2, sprintf("%f*ChebyshevT[$j,x]",$coeffs[$i]));
}

print join("+\n", @sum),"\n";
print "\n\n";
print join("+\n", @sum2),"\n";

die "TESTING";

for $i (@coeffs) {
  debug(sprintf("%f",$i));
}

die "TESTING";

my($observer) = Astro::Nova::LnLatPosn->new("lng"=>0,"lat"=>35);


for $i (0..1439) {
  $t = 1386720000+713*60+60*$i;
  $jd = get_julian_from_timet($t);
  $az=get_hrz_from_equ(get_solar_equ_coords($jd), $observer, $jd)->get_az();
#  $az = $az - $i/4;
  print "$az\n";
}

die "TESTING";

for $i (1..100) {
  sleep(1);
  $randlat = rand(180)-90;
  $randlon = rand(360)-180;
  for $j ("s","m") {
    get_usno_calendar(2014, $randlon, $randlat, $j);
  }
}


die "TESTING";

$observer = Astro::Nova::LnLatPosn->new("lng"=>0,"lat"=>70);
# $observer = Astro::Nova::LnLatPosn->new("lng"=>-106.5,"lat"=>35);
# $observer = Astro::Nova::LnLatPosn->new("lng"=>0,"lat"=>80);
# get_body_rst_horizon2(2456620, $observer, \&get_lunar_equ_coords, 0.125);

$rep = get_body_rst_horizon3(2456450.500000, $observer, \&get_lunar_equ_coords, 0.125);
# $rep = get_body_rst_horizon3(2456620-33.5, $observer, \&get_solar_equ_coords, -5/6.);

debug("REP!");
debug($rep->get_rise());
debug($rep->get_transit());
debug($rep->get_set());

die "TSETING";

=item get_body_minmax_alt($jd, $observer, $get_body_equ_coords, $minmax=-1|1)

Determine time body reaches minimum/maximum altitude for $observer
between $jd and $jd+1, where bodys equitorial coordinates are given
by $get_body_equ_coords, a function.

Uses first derivative for efficiency, but allows for possibility that
min/max altitude is reached at a boundary condition.

=cut

sub get_body_minmax_alt {
  my($jd, $observer, $get_body_equ_coords, $minmax) = @_;

  # body's ra/dec at $jd+.5
  my($pos) = &$get_body_equ_coords($jd+.5);
  # precision
  my($precision) = 1/86400;

  # local siderial time at midday JD (midnight GMT, 5pm MST, 6pm MDT)
  my($lst) = fmodp(get_apparent_sidereal_time($jd+.5)+$observer->get_lng()/15,24);
  # approximate transit/zenith or nadir time of body (as fraction of day)
  my($att) = fmodp(1/4+$minmax/4+($pos->get_ra()/15-$lst)/24,1);

  # the psuedo first derivative of the body's elevation
  my($delta) = 1/86400.;
  my($f) = sub {(get_hrz_from_equ(&$get_body_equ_coords($_[0]+$delta), $observer, $_[0]+$delta)->get_alt() - get_hrz_from_equ(&$get_body_equ_coords($_[0]-$delta), $observer, $_[0]-$delta)->get_alt())/$delta/2};

  # TODO: can D[object elevation,t] be non-0 for 12h+ (retrograde?)
  # the max altitude occurs w/in 6 hours of approx transit time
  my($ans) = findroot2($f, $jd+$att-1/4, $jd+$att+1/4, $precision);

  # $ans may've slipped into next/previous day; if so, look at next/prev day
  if ($ans < $jd) {
    $ans=findroot2($f,$jd+$att+3/4,$jd+$att+5/4,0,"delta=$precision");
  } elsif ($ans > $jd+1) {
    $ans=findroot2($f,$jd+$att-5/4,$jd+$att-3/4,0,"delta=$precision");
  }

  # altitudes at various times (exclude $ans if its STILL out of range)
  my(%alts);

  for $i ($jd, $ans, $jd+1) {
    if ($i>=$jd && $i<=$jd+1) {
      debug("I: $i");
      $alts{$i} = 
	get_hrz_from_equ(&$get_body_equ_coords($i), $observer, $i)->get_alt();
    }
  }

  # sort hash by value
  my(@l) = sort {$alts{$a} <=> $alts{$b}} (keys %alts);
  # and return desired value
  if ($minmax==-1) {return $l[0];}
  if ($minmax==+1) {return $l[$#l];}
}

=item get_body_rst_horizon3($jd, $observer, $get_body_equ_coords, $horizon)

For Julian day $jd and observer $observer, give the rise/set/transit
times of body whose coordinates are given by the function
$get_body_equ_coords; rise and set are computed relative to $horizon

NOTE: $jd should be an integer
TODO: assumes bodys elevation is fairly unimodal 

TODO: what is get_dynamical_time_diff() and why do I need it?
TODO: handle multiple rise/sets in a given day
TODO: this gives time of highest elevation as "transit", not true transit

TODO: this subroutine is slow; can speed up (at expense of accuracy)
by tweaking findmax/findmin

=cut

sub get_body_rst_horizon3 {
  my($jd, $observer, $get_body_equ_coords, $horizon) = @_;
  # thing Im going to return
  my($ret) = Astro::Nova::RstTime->new();
  # to the nearest second (sheesh)
  my($precision) = 1/86400;

  # find bodys min/max alt times and altitudes (above horizon) at those times
  my($mintime) = get_body_minmax_alt($jd, $observer, $get_body_equ_coords, -1);
  my($maxtime) = get_body_minmax_alt($jd, $observer, $get_body_equ_coords, +1);
  my($minalt) = get_hrz_from_equ(&$get_body_equ_coords($mintime), $observer, $mintime)->get_alt()-$horizon;
  my($maxalt) = get_hrz_from_equ(&$get_body_equ_coords($maxtime), $observer, $maxtime)->get_alt()-$horizon;

  debug("RANGE: $mintime,$maxtime,$minalt,$maxalt", get_hrz_from_equ(&$get_body_equ_coords($jd), $observer, $jd)->get_alt()-$horizon, get_hrz_from_equ(&$get_body_equ_coords($jd+1), $observer, $jd+1)->get_alt()-$horizon);

  # circumpolar conditions ($minalt/$maxalt gives elevation ABOVE horizon)
  if ($maxalt < 0) {return -1;}
  if ($minalt > 0) {return +1;}

  # bodys elevation at time t under given conditions
  my($f) = sub {get_hrz_from_equ(&$get_body_equ_coords($_[0]), $observer, $_[0])->get_alt()-$horizon};

  # if $mintime < $maxtime, find rise efficiently, set inefficiently
  my($rise,$set);
  if ($mintime < $maxtime) {
    $rise = findroot2($f, $mintime, $maxtime,0, "delta=$precision");
    # set may occur from start of day to nadir or zenith to end of day
    # TODO: it can actually be BOTH!
    $set = findroot2($f, $jd, $mintime,0, "delta=$precision");
    debug("ALTSET", findroot2($f,$maxtime,$jd+1,0,"delta=$precision"));
    # if that returned nothing...
    unless ($set) {$set = findroot2($f,$maxtime,$jd+1,0,"delta=$precision");}
  } else {
    # if $maxtime < $mintime, find set efficiently, rise inefficiently
    $set = findroot2($f, $maxtime, $mintime,0,"delta=$precision&comment=alpha");
    # rise is from start of day to zenith or from nadir to end of day
    $rise = findroot2($f, $jd, $maxtime,0, "delta=$precision");
    unless ($rise) {$rise = findroot2($f,$mintime,$jd+1,0,"delta=$precision");}
  }

  # TODO: this could be more efficient methinks
  $ret->set_rise($rise);
  $ret->set_set($set);
  $ret->set_transit($maxtime);

  # TODO: I can return more here, including maxalt, minalt, nadir time, etc
  return $ret;
}

die "TESTING";

$observer = Astro::Nova::LnLatPosn->new("lng"=>-60,"lat"=>70);

# for ($i=2456327.5; $i<2456329; $i+=.01) {
for ($i=2456329; $i<=2456331; $i++) {
  print "DAY: $i\n";
  ($status,$rst) = get_lunar_rst($i, $observer);
  print "STATUS: $status\n";

  $rst->get_transit();

  $rise = $rst->get_rise();
  print "RISE: $rise\n";
  $set = $rst->get_set();
  print "SET: $set\n\n";
}

# lunar elevation at 89.5,0 at given time
sub fx {
  my($t) = @_;
  my($pos) = Astro::Nova::LnLatPosn->new("lng"=>0,"lat"=>89.5);
  my($altaz) = get_hrz_from_equ(get_lunar_equ_coords($t), $pos, $t);
  return $altaz->get_alt()-0.125;
}

debug(fx(2456623.83105469));

my($res) = findroot(\&fx, 2456623, 2456624, .001);
my($res2) = findmin(\&fx, 2456623, 2456624, .001);

debug("RES: $res, RES: $res2");

debug(fx($res2));

die "TESTING";

debug(mooninfo(time()));

die "TESTING";

$t = 1384063127.11639;
print join("\n", phasehunt($t)),"\n";
@arr = phase($t);
print "$arr[2]\n";

die "TESTING";

for $i (0..140) {
  $t = 1383483033+86400*$i/10;
  %sm = sunmooninfo(-106,35, $t);
  print "$i $sm{moon}{phase}\n";
  push(@xs, $i);
  push(@ys, $sm{moon}{phase});
#  print $sm{moon}{phase}/$i,"\n";
}

debug(unfold(linear_regression(\@xs,\@ys)));

die "TESTING";

$lon = 0.;
$lat = 89.5;
$time = 1383918337;
# julian
$day = 2456605-60;
$observer = Astro::Nova::LnLatPosn->new("lng"=>$lon,"lat"=>$lat);

for ($i=$day; $i<$day+180; $i++) {
  $rst = get_lunar_rst($i, $observer);
  debug("RST: $rst");
  debug("TIMES($i)", $rst->get_rise(), $rst->get_transit(), $rst->get_set());
}

die "TESTING";

# info I actually want

my(%sunmooninfo) = sunmooninfo($lon,$lat,$time);

for $i ("sun","moon","civ") {
  if ($sunmooninfo{$i}{alt} > 0) {
    # if sun/moon up give me previous rise + next set
    my($lr) = np_rise_set($lon,$lat,$time,$i,"rise",-1);
    my($ns) = np_rise_set($lon,$lat,$time,$i,"set",1);
    print strftime("$i up\nRise: %c\n", localtime($lr));
    print strftime("Set: %c\n\n", localtime($ns));
  } else {
    # otherwise, last set and next rise
    my($ls) = np_rise_set($lon,$lat,$time,$i,"set",-1);
    my($nr) = np_rise_set($lon,$lat,$time,$i,"rise",1);
    print strftime("$i down\nSet: %c\n", localtime($ls));
    print strftime("Rise: %c\n\n", localtime($nr));
  }
}

debug(unfold(%sunmooninfo));

die "TESTING";

# why does libastro fail sometimes?
# below chosen "randomly"
$jd = 2456605;
$lon = -106;
$lat = 35;
$observer = Astro::Nova::LnLatPosn->new("lng"=>$lon,"lat"=>$lat);
debug("OBS:", $observer->as_ascii());
$sunpos = get_solar_equ_coords($jd);
$moonpos = get_lunar_equ_coords($jd);
$rst = get_lunar_rst($jd,$observer);
debug("RST",$rst->get_set());


die "TESTING";

# hideous way of seeing moon is waxing or waning

# linear regress date of new/etc moons ("good enough" for lunar phase calc?)

@y = split(/\n/, read_file("/tmp/phases.txt"));
@x = (0..$#y);

debug(linear_regression(\@x,\@y));

# 7.3823125330 between phases or 637831.802853671s, lc 1388570812.87346
# full moons only: 1389850790.98776 2551297.36530609

for $i (@y) {
#  my($guess) = 1388570812.87346+$n*637831.802853671;
  my($guess) = 1389850790.98776+$n*2551297.36530609;
  print $i-$guess;
  $n++;
  print "\n";
}

die "TESTING";

# debug(np_rise_set(0,80,time(),"moon","rise",-1));
for $i (-1,1) {
  for $j ("moon", "sun", "civ", "naut", "astro") {
    for $k ("rise","set") {
      print strftime("$j$k ($i): %c\n",localtime(np_rise_set($lon,$lat,time(),$j,$k,$i)));
    }
  }
}

die "TESTING";

#$ENV{TZ}="UTC";

# %hash = suninfo(-106-35/60,75+0*35.1, str2time("Nov 15"));
# %hash = sunmooninfo(-106-35/60,35.1,time()-12*3600);

# high latitude sun/moon info
%hash = testing(0,80,time());

for $i (keys %hash) {
  for $j (keys %{$hash{$i}}) {
    print strftime("$i$j ($hash{$i}{$j}): %x %I:%M:%S %p\n",localtime($hash{$i}{$j}));
  }
}

# if sun is up, previous rise and next set; if down, previous set and next rise (wrapper around sunmooninfo)

sub testing {
  my($lon, $lat, $time) = @_;

  my(%info) = sunmooninfo($lon,$lat,$time);
  # variable for loop
  my($timel) = $time;

  # if sun is down, seek to next rise (which may already be in %info)
  if ($info{sun}{alt} < 0) {
    # negative results = no sun rise
    while ($info{sun}{rise} < 0 || $info{sun}{rise} < $time) {
      $timel += 12*3600; # TODO: could I get away with 24 here?
      debug("TIMEL: $timel");
      %info = sunmooninfo($lon,$lat,$timel);
    }
  }

  debug(unfold(%info));
}

die "TESTING";

my $observer = Astro::Nova::LnLatPosn->new();
$observer->set_lat(80);
$observer->set_lng(0);

$jd = Astro::Nova::get_julian_from_timet(1361360700+60);

$ans = Astro::Nova::get_solar_equ_coords($jd);
$ans2 = Astro::Nova::get_hrz_from_equ($ans, $observer, $jd);

debug(%Astro::Nova::HrzPosn::);

# debug(methods($ans2));

debug($ans2,$ans2->get_alt(), $ans2->get_az());


# rst
# $rst = Astro::Nova::get_solar_rst($jd, $observer);
# debug(Astro::Nova::get_timet_from_julian($rst->get_rise()));
# debug(Astro::Nova::get_timet_from_julian($rst->get_set()));

die "TESTING";

# below is http://stackoverflow.com/questions/16293146

# my location
my $observer = Astro::Nova::LnLatPosn->new();
$ut = Time::Local::timegm(0,0,0,1,1-1,2013);
$jd = Astro::Nova::get_julian_from_timet($ut);
$rst = Astro::Nova::get_solar_equ_coords($jd);
debug($rst->get_ra(), $rst->get_dec());

die "TESTING";

$observer->set_lat(70);
$observer->set_lng(0);
$observer->set_altitude(5000);

# unix time
$ut = Time::Local::timegm(0,0,12,14,5-1,2012);
$jd = Astro::Nova::get_julian_from_timet($ut);

# rst
$rst = Astro::Nova::get_solar_rst($jd, $observer);
debug(Astro::Nova::get_timet_from_julian($rst->get_rise()));
debug(Astro::Nova::get_timet_from_julian($rst->get_set()));

die "TESTING";

$dms = Astro::Nova::DMS->new(0,25,03,22);
debug($dms->get_degrees());
debug($dms->get_minutes());
debug(dump_var($dms));

die "TESTING";

$observer->set_lat(Astro::Nova::DMS->from_string("49 degrees")->to_degrees);
$observer->set_lng(Astro::Nova::DMS->from_string("8 E"));

# debug("NOW",dump_var($now));
debug(dump_var($observer));

=item docs

(int $status, Astro::Nova::RstTime $rst) =
  get_object_rst(double JD, Astro::Nova::LnLatPosn observer, Astro::Nova::EquPosn object)
  (int $status, Astro::Nova::RstTime $rst) =
  get_object_rst_horizon(double JD, Astro::Nova::LnLatPosn observer,
                         Astro::Nova::EquPosn object, double horizon)
  (int $status, Astro::Nova::RstTime $rst) =
  get_object_next_rst(double JD, Astro::Nova::LnLatPosn observer, Astro::Nova::EquPosn object)
  (int $status, Astro::Nova::RstTime $rst) =
  get_object_next_rst_horizon(double JD, Astro::Nova::LnLatPosn observer,
                              Astro::Nova::EquPosn object, double horizon)

=cut
