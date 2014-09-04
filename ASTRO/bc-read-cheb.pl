#!/bin/perl

# reads the Chebyshev coefficients from ascp1950.430.bz2

# NOTE: must use: reference plane=FRAME under "Table settings" to get
# answers that agree here; the Chebyshev polynomials are evaluated
# from -1 to +1

# This helps find limits, which are -15 to +10, inclusive
# bzcat ascp1950.430.bz2 | perl -nle 'while (s/D(...)//) {print $1}' | sort | uniq
# can represent: 10^-31 to 10^10 with 16 digits of precision

require "/usr/local/lib/bclib.pl";

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

@planets = ("mercury:3:14:4", "venus:171:10:2", "earthmoon:231:13:2",
	    "mars:309:11:1", "jupiter:342:8:1", "saturn:366:7:1",
	    "uranus:387:6:1", "neptune:405:6:1", "pluto:423:6:1",
	    "moongeo:441:13:8", "sun:753:11:2");

# TODO: this should NOT be defined here!!!

for $i (@planets) {
  my($plan,$pos,$num,$chunks) = split(/:/, $i);
  $planetinfo{$plan} = [$pos,$num,$chunks];
}

# get earthmoon/moongeo coords for today (as part of EMRAT corrections)

for $i ("earthmoon", "moongeo") {
  %coeffs = planet_coeffs(time(), $i, "tay");

  for $j ("x","y","z") {
    @tay = @{$coeffs{$j}};
    my(@terms) = ();
    print "$i\[${j}_\,t_] = \n";
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

open(A,"/home/barrycarter/20140124/ascp1950.430");

for $planet (keys %planetinfo) {
  my(@all) = ();
  my($pos,$num,$chunks) = @{$planetinfo{$planet}};


  unless (-f "$workdir/raw-$planet.m") {
    # 1142 based on file size of 30688966 divided by 26873 per chunk
    for $i (0..1141) {
      seek(A, $i*26873, SEEK_SET);
      read(A, my($data), 26873);
      my(@data) = split(/\s+/, $data);
      @data = @data[$pos+2..$pos+2+$num*$chunks*3-1];
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
  my($chunknum) = floor(($time+632707200)/86400/(32/$chunks));
  debug("CHUNK: $chunknum, SUM: $sum, TIME: $time");

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

