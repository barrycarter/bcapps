#!/bin/perl

# converts XSP files for use with Mathematica, and tries to be a
# little clever about it

require "/usr/local/lib/bclib.pl";


# xsp2math("de431_part-2", 4, 0, 0);
# xsp2math("jup310", 4, 719812778, 1411072450);
# xsp2math("sat365", 6, 0, 3.14*10**7);
# xsp2math("sat365", 6, time(), time()+86400*100);
# xsp2math("jup310", 1, 0, 86400*10);
# get earth position from earth/moon barycenter from jup310.xsp (just
# as a weird example)
# xsp2math("jup310", 13, 0, 86400*365);

# mars from earth

open(A,">/tmp/math.m")||die("Can't open, $!");

# array 3: earth/moon barycenter to solar system barycenter
# array 10: sun to solar system barycenter
# array 11: moon to earth/moon barycenter
# array 12: earth to earth/moon barycenter

for $i (6) {
  my($str) = xsp2math("de430", $i, str2time("1970-01-01"), str2time("2030-01-01"));
#  my($str) = xsp2math("sat365", $i, str2time("2014-01-01"), str2time("2015-01-01"));

# for $i (3,4,5,12) {
#   my($str) = xsp2math("de431_part-2", $i, str2time("2014-01-01"), str2time("2015-01-01"));
  print A $str;
}

close(A);

die "TESTING";

# mercury from earth, this year

open(A,">/tmp/math.m")||die("Can't open, $!");
for $arr (1..14) {
  my($str)=xsp2math("de430",$arr,str2time("2014-01-01"),str2time("2015-01-01"));
  debug("STR: $str");
  print A $str;
}
close(A)||die("Can't close, $!");

=item xsp2math($kern, $idx, $stime, $etime)

Return Mathematica string for array $idx in SPICE kernel $kern
(in xsp form) good from $stime to $etime, given in Unix
seconds. Result is normalized to Unix days (ie: Unix second/86400)

=cut

sub xsp2math {
  my($kern, $idx, $stime, $etime) = @_;
  my(@arr, %info);
  local(*A);
  # convert stime/etime to NASA format (seconds since 2000-01-01 noon UTC)
  $stime -= 946728000;
  $etime -= 946728000;

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

  my(%info) = spk_array_info(A, $info{begin_array}, $info{end_array});

  # function for binary search
  my($f) = sub {
    my($byte) = @_;
    my($rval);
    debug("BYTE: $_[0]");
    seek(A,round($byte),SEEK_SET);
    # pull towards middle to avoid running off end of array
    if ($byte > ($info{begin_array}+$info{end_array})/2) {
      $rval = nasa_sec(A,$info{boundary},-1);
    } else {
      $rval = nasa_sec(A,$info{boundary},0);
    }
    debug("RETURNING $rval-$stime", $rval-$stime);
    return $rval-$stime;
  };

  # below automatically positions A correctly, so we ignore return value
  debug("INT: $info{interval}");
  findroot($f, $info{begin_array}, $info{end_array}, $info{interval});
  return read_coeffs(A, $stime, $etime, {%info});
}

# Given $fh, an open filehandle to an XSP file and a delimiter $delim,
# return the next NASA second from the filehandle's current position.
# If $dir==-1, return the previous NASA second (should be 0 otherwise)
# This subroutine is local and thus not perldoc'd

sub nasa_sec {
  my($fh, $delim, $dir) = @_;
  my($temp, $i, @arr);
  debug("DELIM: $delim");

  # find delimiter
  if ($dir == -1) {
    while ($i = scalar(current_line($fh, "\n", -1))) {
      debug("REV: $i");
      if ($i eq $delim) {last;}
    }
  } else {
    while ($i = scalar(<$fh>)) {
      debug("FOR: $i");
      if ($i eq $delim) {last;}
    }
  }

  # TODO: watch out for stray '1024' like things

  # rewind one or three rows depending on direction
  for $i (1..3+2*$dir) {
    $temp = current_line($fh, "\n", -1);
  }

  return ieee754todec($temp);
}

# Read Chebyshev coefficients for given object (as hash) from $fh,
# starting at $stime (or earlier) and ending at $etime (in NASA
# seconds) or later, in Mathematica usable format (the Mathematica
# forms are in Unix days, not NASA seconds).

sub read_coeffs {
  my($fh, $stime, $etime, $hashref) = @_;
  # @pw = piecewise
  my(@ret,@pw);

  # interval is the delimiter in decimal form
  my($int) = ieee754todec($hashref->{boundary});
  my($time, %hash);

  # read elements, do special things if we see $delim
  while (my($i)=scalar<$fh>) {

    # ignore things outside quotes
    unless ($i=~/^\'/) {next;}

    # push most elts to array of current time
    unless ($i eq $hashref->{boundary}) {
      push(@{$hash{$time}},$i);
      next;
    }

    # if this elt is delim, last elt was time, so set new time
    # this allows removes the time (which isn't a coeff) from the prev array
    $time = ieee754todec(pop(@{$hash{$time}}));

    # if $time too early, true error (but do nothing about it)
    if ($time+$int < $stime) {warn "TOO EARLY"; next;}

    # if $time too late, we've reached end of coeffs (not an error)
    if ($time-$int > $etime) {last;}
  }

  # the null entry causes problems
  delete $hash{""};

  # convenience variables
  my($target, $center) = ($hashref->{target}, $hashref->{center});
  # TODO: do this better, keep track of which target/center combos I have
  push(@ret, "pairs[$target][$center] = 1;");

  # make everything a function, including the condition

  # range and conversion depends only on interval, i, and time
  # TODO: probably only need this once globally?

  push(@ret, "range[int_][i_][t_] = (t >= 21915/2 + (i-int)/86400 &&
  t<= 21915/2 + (i+int)/86400);", "conv[int_][i_][t_] =
  86400*(t-(i+946728000)/86400)/int;");

  # now, handle coefficients for each time period
  for $i (sort {$a <=> $b} keys %hash) {
    for $j ("x","y","z") {
      # arrays of Cheb coeffs
      my(@cheb,@cheb2);

      for $k (0..$hashref->{ncoeffs}-1) {
	# the current coefficient
	my($coeff) = ieee754todec(shift(@{$hash{$i}}), "mathematica=1");
      # TODO: keep raw polys around too, not just converted ones
	push(@cheb2, "$coeff*ChebyshevT[$k, w]");
	push(@cheb, "$coeff*ChebyshevT[$k, conv[$int][$i][w]]");
      }

      my($cheb) = join("+\n", @cheb);
      my($cheb2) = join("+\n", @cheb2);

      # NOTE: do not move "/;" to the next line, it breaks stuff
      push(@pw, "{Function[w,$cheb], range[$int][$i][t]}");
      push(@ret, "poly[$j,$target,$center,t_] := Function[w, $cheb] /;
      range[$int][$i][t];");

      push(@ret, "eval[$j,$target,$center,w_] := $cheb /;
      range[$int][$i][w];");

      push(@ret, "raw[$j][$target][$center][t_] := Function[w, $cheb2] /;
      range[$int][$i][t];");
    }
  }

  my($pw) = join(",\n", @pw);
  debug("<pw>$pw</pw>");
  return join("\n", @ret);
}

# given open filehandle to SPK file (with arrays of type 2 or 3 only),
# byte positions of array start/end, return a hash of information
# about the array, see:
# spk.html#Segments--The%20Fundamental%20SPK%20Building%20Blocks
# spk.html#Type%202:%20Chebyshev%20%28position%20only%29
# in this directory for details

sub spk_array_info {
  my($fh, $bs, $be) = @_;
  my(%hash);

  # pretty silly, but needed
  $hash{begin_array} = $bs;
  $hash{end_array} = $be;

  # info from the end of the array
  seek($fh, $be, SEEK_SET);

  # NOTE: interval here is twice the previous thing I was calling "interval"
  @map = ("footer", "numrec", "rsize", "interval", "init");
  for $i (0..$#map) {$hash{$map[$i]}=ieee754todec(current_line($fh,"\n",-1));}

  # from start of array (do this last so we can leave tell($fh) in good place)
  seek($fh, $bs, SEEK_SET);

  # directly from html file (except header = "BEGIN_ARRAY" line, and
  # xsp does not have start/end address of array)
  my(@map) = ("header", "name", "start_sec", "end_sec", "target",
	      "center", "ref_frame", "eph_type");
  for $i (0..$#map) {$hash{$map[$i]} = ieee754todec(scalar(<$fh>));}

  # 3rd line from above has boundary (hex format)
  # UGLY: this assigns boundary thrice, third one is correct
  for (1..3) {$hash{boundary} = scalar(<$fh>);}

  # from formulas in spk.html, but we want #coeffs, not degree, so don't -1
  if ($hash{eph_type} == 2) {
    $hash{ncoeffs} = ($hash{rsize}-2)/3;
  } elsif ($hash{eph_type} == 3) {
    $hash{ncoeffs} = ($hash{rsize}-2)/6;
  } else {
    die "Can only handle arrays of type 2 or 3 (for now)";
  }

  # PEDANTIC: this is really a list, but ok if receiver treats it as hash
  return %hash;
}
