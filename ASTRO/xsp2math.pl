#!/bin/perl

# converts XSP files for use with Mathematica, and tries to be a
# little clever about it

require "/usr/local/lib/bclib.pl";


# xsp2math("de431_part-2", 4, 0, 0);
# xsp2math("jup310", 4, 719812778, 1411072450);
# xsp2math("sat365", 6, 0, 3.14*10**7);
xsp2math("sat365", 6, 0, 86400*10);
# xsp2math("jup310", 1, 0, 86400*10);

=item xsp2math($kern, $idx, $stime, $etime)

Return Mathematica coefficients for array $idx in SPICE kernel $kern
(in xsp form) good from $stime to $etime, given in Unix
seconds. Result is normalized to Unix days (ie: Unix second/86400)

=cut

sub xsp2math {
  my($kern, $idx, $stime, $etime) = @_;
  my(@arr, %info);
  # TODO: handle this converstion at some point
  # convert stime/etime to NASA format (seconds since 2000-01-01 noon UTC)
#  $stime -= 946728000;
#  $etime -= 946728000;

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

#    debug("RVAL: $rval");
    return $rval-$stime;
  };

  # below automatically positions A correctly, so we ignore return value
  findroot($f, $info{begin_array}, $info{end_array}, $info{interval});
  read_coeffs(A, $stime, $etime, $info{boundary}, $info{objid});

  die "TESTING";

  my(@coeffs) = nasa_sec(A,$info{boundary},0,1);
  my($time) = shift(@coeffs);
  debug("LENGTH".scalar(@coeffs));

  # the x coeffs are the first 1/6th of the coeffs
  print "interval = $info{interval}\n";
  print "time = $time+946728000;\n";
  print "objid = $info{objid};\n";
  print "test[t_] = \n";
  for $i (0..scalar(@coeffs/6)-1) {
    print "$coeffs[$i]*ChebyshevT[$i,t]+\n";
  }
  print "0;\n";
}

# Given $fh, an open filehandle to an XSP file and a delimiter $delim, 
# return the next NASA second from the filehandle's current position.
# If $dir==-1, return the previous NASA second (should be 0 otherwise)
# If $info==1, return coefficients as well
# This subroutine is local and thus not perldoc'd

sub nasa_sec {
  my($fh, $delim, $dir, $info) = @_;
  my($temp, $i, @arr);

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
  debug("DIR: $dir");
  for $i (1..3+2*$dir) {
    $temp = current_line($fh, "\n", -1);
#    debug("REWIND: $temp");
  }

#  debug("TEMP: $temp, RETURNING:", ieee754todec($temp));

  # just requesting time? provide it
  unless ($info) {return ieee754todec($temp);}

  # ignore first line (it's just an ending apos), second line is time,
  # third line is delimiter, all lines to next delimiter are
  # coefficients (except last one is time)

  my($ignore) = scalar(<$fh>);
#  debug("IGNORE: $ignore");
  my($time) = ieee754todec(scalar(<$fh>));
  my($ignore) = scalar(<$fh>);
#  debug("IGNORE2: $ignore");

  while ($i=scalar(<$fh>)) {
#    debug("TIME: $time, pushing: $i");
    if ($i eq $delim) {last;}
    push(@arr, $i);
  }

  # convert to Mathematica format (all but last one) for now
  map($_=ieee754todec($_,"mathematica=1"),@arr);
  return ($time,@arr[0..$#arr-1]);
}


# Read Chebyshev coefficients for $objid from $fh, starting at $stime
# (or earlier) and ending at $etime (in NASA seconds) or later, in
# Mathematica usable format (the Mathematica forms are in Unix days,
# not NASA seconds). $delim is the delimiter (interval) between chunks

# TODO: this replaces the $info parameter to nasa_sec

sub read_coeffs {
  my($fh, $stime, $etime, $delim, $objid) = @_;

  # interval is the delimiter in decimal form
  my($int) = ieee754todec($delim);
  my($time, %hash);

  # read elements, do special things if we see $delim
  while ($i=scalar<$fh>) {

    debug("I: $i");

    # ignore things outside quotes
    unless ($i=~/^\'/) {next;}

    # push most elts to array of current time
    unless ($i eq $delim) {push(@{$hash{$time}},$i); next;}

    # if this elt is delim, last elt was time, so set new time
    # this allows removes the time (which isn't a coeff) from the prev array
    $time = ieee754todec(pop(@{$hash{$time}}));

    # if $time too early, true error (but do nothing about it)
    if ($time+$int < $stime) {warn "TOO EARLY"; next;}

    # if $time too late, we've reached end of coeffs (not an error)
    if ($time-$int > $etime) {
      debug("$time minus $int > $etime");
      last;
    }
  }

  # the null entry causes problems
  delete $hash{""};

  # now, handle coefficients for each time period
  for $i (sort {$a <=> $b} keys %hash) {
    debug("I: $i");

    # determine the UnCix days this formula is valid (a literal string)
    my($range) = "($i+946728000)/86400";
    # this is a literal string: Mathematica will do the math
    my($cond) = "/; (t >= $range-$int/86400 && t <= $range+$int/86400)";
    # and the conversion to get time to (-1,1) interval
    my($conv) = "86400*(t-$range)/$int";
    debug("CONV: $conv");


    # TODO: Most SPICE files give 6 parameters (X,Y,Z,VX,VY,VZ), the
    # last 3 of which are redundant; however, some (DE43*?) only give the 3
    # non-redundant ones. Tweak program to compensate
    # NOTE: The DE43* may also have different indexing for Cheb
    my($clen) = scalar(@{$hash{$i}})/6;
    debug("CLEN: $clen");

    for $j ("x","y","z") {
      # array of Cheb coeffs
      my(@cheb);

      for $k (0..$clen-1) {
	# the current coefficient
	my($coeff) = ieee754todec(shift(@{$hash{$i}}), "mathematica=1");
	debug("$i/$j/$k/$coeff");
	debug("CONV: $conv");
	push(@cheb, "$coeff*ChebyshevT[$k, $conv]");
      }

      # TODO: not crazy about using x/y/z as functions, prefer pos[x]... ?
      my($form) = "$j\[$objid,t_] := ".join("+\n", @cheb)."$cond;";
      debug("FORM: $form");
      # for testing
      print "$form\n";

    }
  }
}
