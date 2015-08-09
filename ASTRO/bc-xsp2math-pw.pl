#!/bin/perl

# creates piecewise functions for Mathematica representing planetary
# positions at given Unix day (second/86400)

require "/usr/local/lib/bclib.pl";

# testing
print xsp2math("de430", 2, 16656*86400, 16657*86400);

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
#      debug("REV: $i");
      if ($i eq $delim) {last;}
    }
  } else {
    while ($i = scalar(<$fh>)) {
#      debug("FOR: $i");
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
  my(@ret,@pw,@convs,@ranges,@piecewise,@raw);

  # interval is the delimiter in decimal form
  map(chomp($_), values %{$hashref});
  my($int) = ieee754todec($hashref->{boundary});
  my($time, %hash);

  # read elements, do special things if we see $delim
  while (my($i)=scalar<$fh>) {
    chomp($i);

    # ignore things outside quotes
    unless ($i=~/^\'/) {next;}

    # push most elts to array of current time
    unless ($i eq $hashref->{boundary}) {
      debug("I: $i, TIME: $time");
      push(@{$hash{$time}},$i);
      next;
    }

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

  # breaking this up into multiple arrays for convenience

  # TODO: do this better, keep track of which target/center combos I have
  push(@ret, "pairs[$target][$center] = 1");

  # the ranges and conversions
  push(@ret, "range[int_][i_][t_] = (t >= 21915/2 + (i-int)/86400 &&
  t<= 21915/2 + (i+int)/86400)");
  push(@ret, "conv[int_][i_][t_] = 86400*(t-(i+946728000)/86400)/int");

  # TODO: make this initialization less kludgey
  # the array of piecewise

  for $j ("x","y","z") {
    push(@ret, "parray[$j,$target,$center] = {}");
  }

  # now, handle coefficients for each time period
  for $i (sort {$a <=> $b} keys %hash) {
    for $j ("x","y","z") {
      # arrays of Cheb coeffs
      my(@cheb,@cheb2);

      for $k (0..$hashref->{ncoeffs}-1) {
	# the current coefficient
	my($coeff) = ieee754todec(shift(@{$hash{$i}}), "mathematica=1");
	debug("COEFF: $coeff");
      # TODO: keep raw polys around too, not just converted ones
	push(@cheb2, "$coeff*ChebyshevT[$k, w]");
	push(@cheb, "$coeff*ChebyshevT[$k, conv[$int][$i][w]]");
      }

      my($cheb) = join("+\n", @cheb);
      my($cheb2) = join("+\n", @cheb2);

      push(@ret, "AppendTo[parray[$j,$target,$center], 
                  {$cheb, range[$int][$i][w]}]");

      # an array of polynomials

      push(@pw, "{Function[w,$cheb], range[$int][$i][t]}");

      push(@ret, "pos[$j,$target,$center,w] = Piecewise[{");
      push(@ret, join(",\n", @pw));
      push(@ret, "}];\n");
      @pw = ();
    }
  }

  for $j ("x","y","z") {
    push(@ret,"pos[$j,$target,$center][w_] = 
               Piecewise[parray[$j,$target,$center]]");
  }

  my($pw) = join(",\n", @pw);
  debug("<pw>$pw</pw>");
  return join("\n", @ret).";\n";
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
  # start_int = start of integration period <= first second
  # end_int = end of integration period >= last second
  my(@map) = ("header", "name", "start_int", "end_int", "target",
	      "center", "ref_frame", "eph_type");
  for $i (0..$#map) {$hash{$map[$i]} = ieee754todec(scalar(<$fh>));}

  # hack for names with spaces
  $hash{name}=~s/\s+$//;

  # toss "1024" line, read true start second
  <$fh>;
  $hash{start_sec} = ieee754todec(scalar(<$fh>));
  $hash{boundary} = scalar(<$fh>);

  # from formulas in spk.html, but we want #coeffs, not degree, so don't -1
  # eph_type determines if we have x y z or also vx vy vz
  if ($hash{eph_type} == 2) {
    $hash{ncoeffs} = ($hash{rsize}-2)/3;
  } elsif ($hash{eph_type} == 3) {
    $hash{ncoeffs} = ($hash{rsize}-2)/6;
  } else {
    # return nothing
    warn "Can only handle arrays of type 2 or 3 (for now), returning null";
    return;
  }

  # PEDANTIC: this is really a list, but ok if receiver treats it as hash
  return %hash;
}

sub write_coeffs {
  my($lref, $href) = @_;
  my(@arr) = @$lref;
  my(%hash) = %$href;

  debug("ARR",@arr,"HASH",%hash);
}
