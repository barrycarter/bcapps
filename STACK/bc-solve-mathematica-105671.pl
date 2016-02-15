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
  my($temp, @arrays, %rethash);

  # NOTE: assuming these files never change
  # TODO: in theory could check file time vs cache time but sheesh!
  my($out,$err,$res) = cache_command2("fgrep -b BEGIN_ARRAY $fname", "age=9999999");

  local(*A);
   open(A,$fname);

  for $i (split(/\n/, $out)) {
    $i=~m/^(\d+):BEGIN_ARRAY (\d+) (\d+)$/||die("BAD LINE: $i");
    my(%hash);
    $hash{fname} = $fname;
    ($hash{byte}, $hash{num}, $hash{size}) = ($1, $2, $3);

    # seek to the start of array and store stuff in hash
    seek(A, $hash{byte}, SEEK_SET);

    # read data from file
    for $j ("", "name", "jdstart", "jdend", "objid", "center", "ref_frame", 
	    "eph_type", "startsec", "secs") {
      $temp = <A>;
      # avoid 1024
      if ($temp=~/^1024$/) {$temp=<A>;}
      chomp($temp);
      $hash{$j} = ieee754todec($temp);
    }



    # setup the hash we'll be returning
    for $j (keys %hash) {$rethash{$hash{objid}}{$j} = $hash{$j};}
  }

  debug(unfold("y",\%hash));

  close(A);
  return \%rethash;
}



debug(var_dump("x",xsp_arrays("/home/barrycarter/SPICE/KERNELS/jup310.xsp")));

