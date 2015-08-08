#!/bin/perl

# reads the Chebyshev coefficients from ascp1950.430.bz2

# NOTE: must use: reference plane=FRAME under "Table settings" to get
# answers that agree here; the Chebyshev polynomials are evaluated
# from -1 to +1

# 26873 = sizeof chunk

# ascp1550.430 (earliest) starts: 2287184.5
# ascp1950.430 starts at JD 2433264.5 = 1949-12-14 00:00:00
# ascp2050.430 starts at JD 2469776.5 = 2049-12-01 00:00:00, 36512 days later

# ftp://ssd.jpl.nasa.gov/pub/eph/planets/ascii/de430/

require "/usr/local/lib/bclib.pl";
use Astro::Time;

# unixdate2chebchunk("19491214.120711");
# stardate2chebarray("20141018");
# stardate2chebarray("19491214");

goto DUMP;

die "TESTING";

=item stardate2chebarray

Given a stardate (yyyyddmm.hhmmss, assumed UTC), return the array of
Chebyshev coefficients (from asc[pm]cc50.430) for that date.

TODO: expand to allow DE431 when outside DE430 range (1550-2650)

=cut

sub stardate2chebarray {
  my($sd) = @_;
  my($jd) = sd2jd($sd);

  if ($jd < 2287184.5) {warn "Too early for DE430"; return;}
  if ($jd > 2688976.5) {warn "Too late for DE430"; return;}

  # determine which file
  my($fname) = sprintf("$bclib{home}/SPICE/KERNELS/ascp%d.430", floor(($jd-2287184.5)/36512)*100+1550);

  # position in file
  debug("ALPHA", floor(($jd-2287184.5)/32));
  my($pos) = 26873*(floor(($jd-2287184.5)/32)%1141);

  # read data
  open(local(*A), $fname);
  seek(A, $pos, SEEK_SET);
  read(A, my($data), 26873);
  close(A);

  # split into array, after getting rid of first two useless terms and
  # convert D+ to E+ for Perl
  $data=~s/^\s*(\d+)\s+(\d+)\s*//;
  $data=~s/D/e/g;
  my(@arr) = split(/\s+/, $data);

  # the julian dates
  # TODO: eval here is ugly
  debug("FNAME: $fname, POS: $pos, ARR: $arr[0]/$arr[1]");
  $sjd = eval($arr[0]);
  $ejd = eval($arr[1]);

  if ($jd < $sjd) {warn "Error: $jd < $sjd"; return;}
  if ($jd > $ejd) {warn "Error: $jd > $ejd"; return;}

  return @arr;
}

=item sd2jd($stardate)

Given stardate $stardate (yyyyddmm.hhmmss, assumed UTC), return
corresponding Julian date

=cut

sub sd2jd {
  my($date) = @_;

  # split across "." (if any)
  my($ymd, $hms) = split(/\./, $date);
  
  # $ymd to $m $d (leaving $y in $ymd)
  $ymd=~s/(\d{2})(\d{2})$//;
  my($m,$d) = ($1,$2);

  # $hms to seconds since start of day
  $hms=~s/(\d{2})?(\d{2})?(\d{2})?$//;
  my($frac) = ($1*3600+$2*60+$3);

  return mjd2jd(cal2mjd($d, $m, $ymd, $frac/86400));
}



  # filename with decimal
#  my($fname) = 1950+floor(($date+7323)/36512);

#  debug("DATE: $date, FNAME: $fname");
# }

DUMP:

# list of planets with hardcoded coefficient numbers/etc
# TODO: don't hardcode, use header.430_572

# saturn pos at JD 32-day break mark
# 2457776.500000000, A.D. 2017-Jan-23 00:00:00.0000,
# -2.619630026472111E+08, -1.479262345684487E+09, 3.614600451880660E+07

# and mars:
# 2457776.500000000 = A.D. 2017-Jan-23 00:00:00.0000 (CT)
# 1.872704779146366E+08  1.048557408105275E+08 -2.422463501688972E+06

# earthmoon = earth-moon barycenter
# moongeo = position of moon from earth

# a "directory of the day"
my($workdir) = "/home/barrycarter/20140823";

# TODO: this should NOT be defined here!!!

@planets = ("mercury:3:14:4", "venus:171:10:2", "earthmoon:231:13:2",
	    "mars:309:11:1", "jupiter:342:8:1", "saturn:366:7:1",
	    "uranus:387:6:1", "neptune:405:6:1", "pluto:423:6:1",
	    "moongeo:441:13:8", "sun:753:11:2", "nutate:819:10:4");

for $i (@planets) {
#  my($plan,$pos,$num,$chunks) = split(/:/, $i);
  my(@l) = split(/:/, $i);
  for $j ("name", "pos", "num", "chunks") {
    $planetinfo{$i}{$j} = splice(@l,0,1);
  }
}

# get all info from filename(s) given on command line, assumed to be an
# asc[pm]yyyy.43[01] file from one of:
# ftp://ssd.jpl.nasa.gov/pub/eph/planets/ascii/de430/
# ftp://ssd.jpl.nasa.gov/pub/eph/planets/ascii/de431/

for $file (@ARGV) {
  # TODO: confirm these files are actually this well structured

  if ($file=~/\.bz2$/) {
    open(A,"bzcat $file|");
  } else {
    open(A, $file);
  }

  my($data);

  while (!eof(A)) {
    # TODO: confirm all chunks are this size, this seems incorrect
    read(A, $data, 26873);

    # convert D+ stuff
    # TODO: use "exact" form
    $data=~s/D/*10^/g;

    # break into individual coefficients
    my(@list) = split(/\s+/, $data);

    # first 5 coeffs are special
    my($blank, $chunknum, $tchunks, $jstart, $jend) = splice(@list,0,5);

    # error checking
    unless ($blank=~/^\s*$/) {warn "BAD BLANK: $data";}
    unless ($chunknum=~/^\d+$/) {warn "BAD CHUNKNUM: $data";}
    unless ($tchunks eq "1018") {warn "BAD TCHUNKS: $data";}

    # TODO: use julian days somehow

    # go thru planets
    for $planet (@planets) {
      debug("PLANET: $planet");
      # number of chunks for this planet
      for $i (1..$planetinfo{$planet}{chunks}) {
	# coordinates
	my(@coords) = ("x","y");
	unless ($planetinfo{$planet}{name} eq "nutate") {push(@coords,"z");}
	for $j (@coords) {
	  my(@coeffs) = splice(@list, 0, $planetinfo{$planet}{num});

	  # TODO: this is just testing
	  print "pos[$planetinfo{$planet}{name}][$chunknum][$i][$j] = {";
	  print join(", ",@coeffs);
	  print "};\n";
	}
      }
    }
  }
}

die "TESTING";

# yuk!
goto NUTATE;

# get earthmoon/moongeo coords for today (as part of EMRAT corrections)

for $i ("earthmoon", "moongeo") {
  %coeffs = planet_coeffs(str2time("2014-09-20 UTC"), $i, "tay");

  for $j ("x","y","z") {
    @tay = @{$coeffs{$j}};
    my(@terms) = ();
    print "$i\[t_,\"${j}\"] = \n";
    for $k (0..$#tay) {
      $tay[$k]=~s/e/*10^/;
      push(@terms,"$tay[$k]*t^$k");
  }
    print join("+\n", @terms),";\n";
  }
}

die "TESTING";




# my(%plan) = planet_coeffs(str2time("1994-06-17 UTC"),"mercury","cheb");
# my(%plan) = planet_coeffs(str2time("1949-12-14 UTC"),"mercury","cheb");

my(%plan) = planet_coeffs(time(),"mercury","tay");

# testing...

$count = 0;
for $i (@{$plan{x}}) {
  $i=~s/e/*10^/;
  push(@nomial, "$i*t^$count");
  $count++;
}

debug(join("+\n",@nomial));

die "TESTING";

# for mathematica, obtain raw coefficients for planets for 100 years


NUTATE:

open(A,"/home/barrycarter/20140124/ascp1950.430");

# for $planet (keys %planetinfo) {
for $planet ("nutate") {
  my(@all) = ();
  my($pos,$num,$chunks) = @{$planetinfo{$planet}};
  debug("ALPHA: $pos/$num/$chunks");

  unless (-f "$workdir/raw-$planet.m") {
    # 1142 based on file size of 30688966 divided by 26873 per chunk
    for $i (0..1141) {
      seek(A, $i*26873, SEEK_SET);
      read(A, my($data), 26873);
      my(@data) = split(/\s+/, $data);

      # HACK!
      if ($planet eq "nutate") {
	$axes = 2;
      } else {
	$axes = 3;
      }

      @data = @data[$pos+2..$pos+2+$num*$chunks*$axes-1];
      map(s%\.(\d{16})\D%$1/10^16*10^%, @data);
      push(@all,@data);
    }

    my($all) = join(",\n",@all);
    open(B,">$workdir/raw-$planet.m");
    print B << "MARK";
ncoeff = $num;
ndays = 32/$chunks;
coeffs = {$all};
MARK
  ;
    close(B);
  }

  # this only needs to be done once, really shouldn't even use cache_command
  my($out,$err,$res) = cache_command2("math -initfile $workdir/raw-$planet.m -initfile /home/barrycarter/BCGIT/ASTRO/bc-read-cheb.m","age=9999999");

  # the coefficients
  while ($out=~s/(bytes|nbits)_(cheb|tay)=List\[(.*?)\]//s) {
    my($bb,$ct,$coeffs) = ($1,$2,$3);
    $coeffs=~s/[^0-9,]//g;

    # for nbits, store as is (no bin conversion)
    if ($bb eq "nbits") {
      write_file($coeffs,"$workdir/$planet-$ct-$bb.txt");
      next;
    }

    my(@coeffs) = split(/\,/,$coeffs);
    map($_=chr($_),@coeffs);
    $coeffs = join("",@coeffs);
    write_file($coeffs,"$workdir/$planet-$ct.bin");
  }
}

close(A);

=item planet_coeffs($time,$planet,$type="cheb|tay")

Obtain the Chebyshev or Taylor coefficients for $planet at $time (Unix
seconds). Requires the .bin and .txt files created by bc-read-cheb.pl
(which will soon be included in the GIT directory).

TODO: output format

TODO: $workdir must change

TODO: dont use global @planet/%planetinfo

=cut

sub planet_coeffs {
  my($time,$planet,$type) = @_;

  my(@list);
  my(%rethash);

  # TODO: define planetinfo hash properly locally (dont do below)
  my($pos,$num,$chunks) = @{$planetinfo{$planet}};

  # bits per coefficient
  my(@nbits) = split(/\,/,read_file("$workdir/$planet-$type-nbits.txt"));

  # total bits per chunk
  my($sum)=0;
  for $i (@nbits) {$sum+=$i;}

  # in which chunk are these coeffs? (number of days since start
  # divided by number of days per chunk
  my($chunknum) = ($time+632707200)/86400/(32/$chunks);
  # compute the value of t for Chebyshev/Taylor
  my($frac) = $chunknum-floor($chunknum);
  $chunknum = floor($chunknum);

  # convert $frac to "t" value
  $frac = $frac*2-1;

  debug("CHUNK: $chunknum/$frac, SUM: $sum, TIME: $time");

  # TODO: allow output in pure Mathematica format

  # open file and seek to correct spot (in bits)
  local(*A);
  open(A,"$workdir/$planet-$type.bin");
  my(@bits) = seek_bits(A, $chunknum*$sum, $sum);

  # convert bits back to numbers
  # TODO: this needs to be a LOT more efficient!
  for $i (@nbits) {
    # reverse so we get low bit first
    my(@num) = reverse(splice(@bits,0,$i));

    # convert to decimal
    my($sum)=0;
    # last bit is sign
    for $j (0..$#num) {
      $sum+=2**$j*$num[$j];
    }

    # correct for what int2bit does
    $sum-=2**(scalar(@num)-1);

    # TODO: don't hardcode 32768 here
    $sum/=32768;
    push(@list,$sum);
  }

  # the return values
  for $i ("x","y","z") {
    $rethash{$i} = [splice(@list,0,$num)];
  }

  # some other useful info
  $rethash{t} = $frac;

  return %rethash;
}

=item seek_bits($fh, $start, $num)

Seek to bit (not byte) $start in filehandle $fh, and return the next
$num bits (as a list).

=cut

sub seek_bits {
  my($fh, $start, $num) = @_;

  # special case
  if ($num==0) {return;}

  # the byte where this bit starts and the offset
  my($fbyte, $offset) = (floor($start/8), $start%8);
  # the number of bytes to read ($offset does affect this)
  my($nbytes) = ceil(($num+$offset)/8);

  debug("STARTING AT $fbyte, seeking $nbytes");

  seek($fh, $fbyte, SEEK_SET);
  read($fh, my($data), $nbytes);

  my(@ret) = split(//, unpack("B*", $data));
  # return requested bits
  return @ret[$offset..$offset+$num-1];
}

