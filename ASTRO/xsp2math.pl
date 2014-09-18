#!/bin/perl

# converts XSP files for use with Mathematica, and tries to be a
# little clever about it

require "/usr/local/lib/bclib.pl";


# xsp2math("de431_part-2", 4, 0, 0);
xsp2math("jup310", 4, 0, 0);


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

  # find where this array begins/ends
  my(@res)=`fgrep '_ARRAY $idx' $bclib{githome}/ASTRO/array-offsets.txt | fgrep $kern`;
  for $i (@res) {
    unless ($i=~s/^.*?:.*?:(.*?):(BEGIN|END)_ARRAY $idx (\d+)$//) {
      warn "BAD: $res";
    }
    $info{lc($2)."_array"} = $1;
    $info{length} = $3;
  }

  # TODO: use filehandle instead of opening one ourselves?
  my($fname) = "$bclib{home}/SPICE/KERNELS/$kern.xsp";
  open(A,$fname) || die("Can't open $fname, $!");
  seek(A, $info{begin_array}, SEEK_SET);

  # first 11 lines of the array are special
  for $i (0..10) {push(@arr, scalar(<A>));}

  # get information from those lines
  $info{objid} = ieee754todec($arr[4]);
  $info{interval} = ieee754todec($arr[10]);
  # middle of the first interval (not true start)
  $info{sdate} = ieee754todec($arr[9]);
  # we need the hex form of the interval to find interval boundaries
  $info{boundary} = $arr[10];

  debug("INFO",%info);

  # function for binary search
  my($f) = sub {
    debug("CALLED",@_);
    seek(A,shift,SEEK_SET);
    return nasa_sec(A,$info{boundary})-$stime;
  };

  debug(findroot($f, $info{begin_array}, $info{end_array}));

  die "TESTING";

  # TESTING
  seek(A, 370000000, SEEK_SET);
  debug("NS", nasa_sec(A,$info{boundary}));
  die "TESTING";

  # TODO: this reverse engineering seems really clunky

  # how many coefficients per "chunk"?
  do {
    $i=<A>;
    $info{count}++;
  } until ($i eq $info{boundary});

  # find end date
  seek(A, $info{end_array}, SEEK_SET);
  do {$i = current_line(A, "\n", -1)} until ($i eq $info{boundary});
  $info{edate} = ieee754todec(current_line(A, "\n", -1));

  # how many sets of coefficients? (interval is half length)
  $info{ncoeffsets} = ($info{edate}-$info{sdate})/$info{interval}/2;
  # how many coeffs per set (subtract 2 for interval + NASA second)
  $info{ncoeffs} = floor($info{length}/$info{ncoeffsets}-2);
  # TODO: ncoeffs and count are redundant

  # in which coefficient set does $stime fall (-1/2 because interval is midpt)
  my($int) = floor(($stime-$info{sdate})/$info{interval}/2-0.5);
  debug("INT: $int");
  # roughly, where is this interval?
  my($ipos) = floor(($info{end_array}-$info{begin_array})*($int/$info{ncoeffsets})+$info{begin_array});

  debug("INFO",%info);

  seek(A, $ipos, SEEK_SET);
  debug("IPOS: $ipos");
  while ($i=scalar(<A>)) {debug(ieee754todec($i));}



die "TESTING";


  # how many chunks (based on array length)
  $info{nchunks} = floor($info{length}/$info{count});

  # all but 2 are coeffs
  $info{ncoeffs} = $info{count}-2;

  # TODO: this is sometimes 6, sometimes 3!
  # coeffs per poly... TODO

  # how many sets of coefficients?
  debug("GAMMA: $info{length} $info{count}");

  # estimate position of $stime (in bytes)
  my($spos)=($stime-$info{truestart})/($info{edate}-$info{truestart});
  debug("SPOS: $spos");

  debug("COUNT: $info{count}");

  debug("INFO",%info);
  die "TESTING";

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

# Given an open filehandle to an XSP file and a delimiter, return the
# NASA second closest to where the filehandle is open (this function
# is local to this program, not global)

sub nasa_sec {
  my($fh, $delim) = @_;
  my($temp, $i);
  # find delimiter
  while (scalar(<$fh>) ne $delim) {next;}
  # rewind three rows
  debug("REWINDING...");
  for $i (1..3) {$temp = current_line($fh, "\n", -1);}
  return ieee754todec($temp);
}
