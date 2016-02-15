#!/bin/perl

=item text

****** SUMMARY INCL DONT DO THIS + USE ELLIPSES IF MATH MUST

This is serious overkill, but if you want uber-accurate planetary moon
positions in Mathematica, start by visiting:

http://naif.jpl.nasa.gov/pub/naif/generic_kernels/spk/satellites/

and look over the ".cmt" files to find which ".bsp" files you need to
download.

Note that the ".bsp" files are very large, and you'll only want to
download the ones you need.

In this answer, I will use Callisto as an example.

Looking over the ".cmt" files, I note that "jup310.cmt" reads in part:

<pre><code>
Bodies on the File:

   Name       Number            GM             NDIV   NDEG   Model
   Io           501    5.959924010272514E+03     24     11   SATORBINT
   Europa       502    3.202739815114734E+03     18     15   SATORBINT
   Ganymede     503    9.887819980080976E+03     12     15   SATORBINT
   Callisto     504    7.179304867611079E+03     12     10   SATORBINT
   Amalthea     505    1.487604677404272E-01     72     11   SATORBINT
   Thebe        514    0.000000000000000E+00     72     11   SATORBINT
   Adrastea     515    0.000000000000000E+00     72     13   SATORBINT
   Metis        516    0.000000000000000E+00     72     13   SATORBINT
   Jupiter      599    1.266865341960128E+08     18     10   SATORBINT
</code></pre>

so "jup310.bsp" is the file I need, so I download it (it's almost 1G in size).

Some programs (like CSPICE and PyEphem) can use the ".bsp" files
directly, but the scripts I created require one extra step. Visit:

http://naif.jpl.nasa.gov/pub/naif/utilities/

click on your platform, and then download "toxfr".

You can also download its user guide "toxfr.ug". Since these utilities
are fairly small, I recommending downloading all of them, but you
won't need the others for what we're doing.

Run "toxfr" on "jup310.bsp" to get "jup310.xsp".

Note that .xsp files are even larger than .bsp files. "jup310.xsp",
for example, is ~2201MB, compared to "jup310.bsp"s size of ~977MB.

***** WHAT THE XSP FILES ACTUALLY ARE

*****DISPOSE OF OR COMPRESS, ACTUAL NAVIGTEA SPACESHIS, I USED TO MAINTAIN BUT MX NOT GOOD BUT IF YOU NEED TELL ME

******LESS ACCURATE: ellipse

TODO: add some of these subroutines into bclib.pl

=cut


=item xsp_arrays($fname)

Given an .xsp file, return information about the arrays in it,
including the starting character position, indexed by the NAIF id of
the body in the array

=cut

require "/usr/local/lib/bclib.pl";

sub xsp_arrays {
  my($fname) = @_;
  my($bs, $be, @ret);

  # NOTE: assuming these files never change
  # TODO: in theory could check file time vs cache time but sheesh!
  my($out,$err,$res) = cache_command2("egrep -b 'BEGIN_ARRAY|END_ARRAY' $fname", "age=9999999");

  local(*A);
  open(A,$fname);

  for $i (split(/\n/, $out)) {

    # if start of array record it
    if ($i=~m/^(\d+):BEGIN_ARRAY (\d+) (\d+)$/) {$bs = $1; next;}

    # if not end of array, move on
    unless ($i=~m/^(\d+):END_ARRAY (\d+) (\d+)$/) {next;}

    # end of array: record arraynum + ending byte and send to other subr
    my($be, $num) = ($1, $2);

    debug("ALPHA");

    my(%hash) = spk_array_info(A, $bs, $be);
    
    $ret[$num] = \%hash;
  }

  debug(unfold("arr",@ret));

}

# below copied directly from bc-xsp2math-pw.pl, see details there

sub spk_array_info {
  my($fh, $bs, $be) = @_;
  my(%hash);

  debug("CALLED");

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



debug(var_dump("x",xsp_arrays("/home/barrycarter/SPICE/KERNELS/jup310.xsp")));

