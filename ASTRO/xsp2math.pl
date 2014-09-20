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

xsp2math("jup310", 13, 0, 86400*365);


=item xsp2math($kern, $idx, $stime, $etime)

Return Mathematica coefficients for array $idx in SPICE kernel $kern
(in xsp form) good from $stime to $etime, given in Unix
seconds. Result is normalized to Unix days (ie: Unix second/86400)

=cut

sub xsp2math {
  my($kern, $idx, $stime, $etime) = @_;
  my(@arr, %info);
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
  seek(A, $info{begin_array}, SEEK_SET);

  # "" = values that aren't IEEE754 and/or we don't care about
  my(@map) = ("", "", "int_start", "int_end", "target_id", "source_id",
	      "", "coeff_flag", "", "mid_first");

  # first 11 lines of the array are special (11th line is super special)
  for $i (0..$#map) {$info{$map[$i]} = ieee754todec(scalar(<A>));}

  # 11th line, need both hex and decimal forms of interval (hex = boundary)
  $info{boundary} = scalar(<A>);
  $info{interval} = ieee754todec($info{boundary});

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
  read_coeffs(A, $stime, $etime, {%info});
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

  # interval is the delimiter in decimal form
  my($int) = ieee754todec($hashref->{boundary});
  my($time, %hash);

  # read elements, do special things if we see $delim
  while ($i=scalar<$fh>) {

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

  # now, handle coefficients for each time period
  for $i (sort {$a <=> $b} keys %hash) {

    # determine the UnCix days this formula is valid (a literal string)
    my($range) = "($i+946728000)/86400";
    # this is a literal string: Mathematica will do the math
    my($cond) = "/; (t >= $range-$int/86400 && t <= $range+$int/86400)";
    # and the conversion to get time to (-1,1) interval
    my($conv) = "86400*(t-$range)/$int";

    # TODO: Most SPICE files give 6 parameters (X,Y,Z,VX,VY,VZ), the
    # last 3 of which are redundant; however, some (DE43*?) only give the 3
    # non-redundant ones. Tweak program to compensate
    # NOTE: The DE43* may also have different indexing for Cheb
    # coeff_flag might give this info?

    my($clen) = scalar(@{$hash{$i}})/(3+3*($hashref->{coeff_flag}-2));

    for $j ("x","y","z") {
      # array of Cheb coeffs
      my(@cheb);

      for $k (0..$clen-1) {
	# the current coefficient
	my($coeff) = ieee754todec(shift(@{$hash{$i}}), "mathematica=1");
	push(@cheb, "$coeff*ChebyshevT[$k, $conv]");
      }

      # TODO: keep raw polynomials around so that poly[t] = actual
      # polynomial unevaluated


      # TODO: not crazy about using x/y/z as functions, prefer pos[x]... ?
      my($form)="$j\[$hashref->{target_id}, $hashref->{source_id},t_] := ".join("+\n", @cheb)."$cond;";
      # for testing
      print "$form\n";
    }
  }
}
