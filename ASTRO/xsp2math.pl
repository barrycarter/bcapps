#!/bin/perl

# converts XSP files for use with Mathematica, and tries to be a
# little clever about it

require "/usr/local/lib/bclib.pl";


xsp2math("de431_part-2", 3, 0, 0);


die "TESTING";

my($fname) = @ARGV;
open(A,"$homedir/SPICE/KERNELS/$fname.xsp");
my($temp);

while (<A>) {

  # raw 1024 ignore so often, I want to ignore them early and quietly
  if (/^1024$/) {next;}

  # start of new array?
  if (/BEGIN_ARRAY\s+(\d+)\s+(\d+)$/) {
    ($arraydata{num}, $arraydata{length}) = ($1,$2);

    # read the first few lines which are special
    # x1/x2/x3 uninteresting for now
    for $i ("name", "jdstart", "jdend", "objid", "x1", "x2", "x3", "startsec",
	   "secs") {
      # avoid 1024
      $temp = <A>;
      if ($temp=~/^1024$/) {$temp=<A>;}
      $temp = ieee754todec($temp);
      debug("$i -> $temp");
      $arraydata{$i} = $temp;
    }

    # the body id (it's not in IEEE-754 format, so not caught above)
    $arraydata{objid} = hex($arraydata{objid});

    # record next interval midpoint so we can ignore it later
    $nextint = $arraydata{startsec}+2*$arraydata{secs};

    # TODO: check if output file already exists
    open(B,">$homedir/SPICE/KERNELS/MATH/xsp2math-$fname-array-$arraydata{objid}.m");
    print B "coeffs$arraydata{objid} = {\n";
    next;
  }

  if (/END_ARRAY\s+(\d+)\s+(\d+)$/) {
    # to avoid "last comma" issue, add/remove artificial 0 to end of array
    print B "0};\n";
    print B "coeffs$arraydata{objid} = Drop[coeffs$arraydata{objid},-1];\n";
    close(B);
    next;
  }

  $num = ieee754todec($_);
  if ($num eq $_) {warn "NO CHANGE: $num, ignoring"; next;}

  # are we seeing the next interval? If so, ignore 2 lines and reset nextint
  if ($num eq $nextint) {
    # read the next line and reset nextint
    $temp = <A>;
    $nextint += 2*ieee754todec($temp);
    next;
  }

  print B ieee754todec($_,"mathematica=1"),",\n";

}

=item xsp2math($kern, $idx, $stime, $etime)

Return Mathematica coefficients for array $idx in SPICE kernel $kern
(in xsp form) good from $stime to $etime, given in Unix
seconds. Result is normalized to Unix days (ie: Unix second/86400)

=cut

sub xsp2math {
  my($kern, $idx, $stime, $etime) = @_;
  my(@arr, %info);
  # convert stime/etime to NASA format (seconds since 2000-01-01)
  $stime -= 946684800;
  $etime -= 946684800;

  # this file must exist, start of arrays in bytes
  my($res)=`fgrep 'BEGIN_ARRAY $idx' $bclib{githome}/ASTRO/array-offsets.txt | fgrep $kern`;
  debug("RES: $res");

  # read data about this array
  unless ($res=~s/^.*?:.*?:(.*?):BEGIN_ARRAY $idx (\d+)$//) {warn "BAD: $res";}
  my($byte, $len) = ($1,$2);

  # TODO: use filehandle instead of opening one ourselves?
  my($fname) = "$bclib{home}/SPICE/KERNELS/$kern.xsp";
  open(A,$fname) || die("Can't open $fname, $!");
  debug("BYTE: $byte");
  seek(A, $byte, SEEK_SET);

  # first 11 lines of the array are special
  for $i (0..10) {push(@arr, scalar(<A>));}
  debug("ARR",@arr);
  # start/end of integration dates, not actual data dates (but close?)
  $info{sdate} = ieee754todec($arr[2]);
  $info{edate} = ieee754todec($arr[3]);
  $info{objid} = ieee754todec($arr[4]);
  $info{truestart} = ieee754todec($arr[9]);
  $info{interval} = ieee754todec($arr[10]);
  # we need the hex form of the interval to find interval boundaries
  $info{boundary} = $arr[10];

  # distance in bytes between boundaries (at least first/second)
  my($bs) = tell(A);
  do {$i=<A>;} until ($i eq $info{boundary});
  my($clen) = tell(A)-$bs;

  # how many chunks ahead for $stime? (using floor since we want earlier time)
  # each chunk is 2 intervals (given time +- interval)
  my($spos) = $clen*floor(($stime-$info{truestart})/2/$info{interval});
  # seek to next boundary + then backup to find NASA second
  seek(A, $spos, SEEK_CUR);
  do {$i=<A>} until ($i eq $info{boundary});
  my($date);
  for $j (1..3) {
    $date = current_line(A, "\n", -1);
  }

  debug("SPOS: $spos/$date", ieee754todec($date));

  while ($j=<A>) {debug("J: $j",ieee754todec($j));}

  die "TESTING";

  debug("TRUESTART: $info{truestart}");

  # how many intervals to expect (approx)
  my($nint) = ($info{edate}-$info{sdate})/$info{interval};
  # how long is each polynomial (based on array length + number of intervals)?
  # (there are 6 quantities per interval: X,Y,Z,VX,VY,VZ
  # 12 of array entries are not coeffs
  # the "floor" below compensates for spurious "1024" like things
  my($plen) = floor(($len-12)/6/$nint);

  # roughly where does stime fall in the bytes
  # TODO: assuming about 14 bytes per coeff, not a great estimate
  # TODO: get end position (by looking at next "BEGIN_ARRAY") instead

  # look for next boundary (find_str_in_file does this too)
  debug("PRE",tell(A));
  seek(A,$spos,SEEK_SET);
  debug("POST",tell(A));
  do {$i=<A>} until ($i eq $info{boundary});
  # now seek backwards for associated NASA second
  my($date);

  $date = ieee754todec($date);
  debug("I: $i/$date");
  debug("NINT: $nint/$plen/$spos");
  debug("ARR",@arr);
  debug("INFO",%info);
}

