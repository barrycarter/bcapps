#!/bin/perl

# test geolocation

push(@INC, "/usr/local/lib");
require "bclib.pl";

# load regexps
for $i (split("\n", read_file("/home/barrycarter/BCGIT/GEOLOCATION/regexps.txt"))) {
  # ignore blanks and comments
  if ($i=~/^\s*$/ || $i=~/\#/) {next;}
  chomp($i);

  # if beginning of <bad> regexps, note so
  if ($i=~/^<bad>$/) {$bad=1; next;}
  if ($i=~/^<\/bad>$/) {$bad=0; next;}

  # below is bad because it disallows post-/ options
  $i=~s/\///isg;

  push(@regexp, $i);
  if ($bad) {
    $bad{$i}=1;
    unless (substr($i,0,1) eq "^") {
      warn "BAD CODE $i does not start with ^";
    }

    unless (substr($i,-1,1) eq "\$") {
      warn "BAD CODE $i does not end with \$";
    }
  }

}

open(A,"/home/barrycarter/BCGIT/GEOLOCATION/sortedhosts.txt");

# write results
open(B,">/home/barrycarter/BCGIT/GEOLOCATION/resolvedhosts.txt");
open(C,">/home/barrycarter/BCGIT/GEOLOCATION/unresolvedhosts.txt");

while (<A>) {
  chomp;

  if (++$count%10000==0) {debug("$count done");}

  # check vs regexps (but start w/ blank code)
  $code = "";
  for $i (@regexp) {
    if (@parts=($_=~m/$i/)) {
      # if this is a bad regexp, just note so
#      debug("MATCH: $i to $_");
      if ($bad{$i}) {
#	debug("BAD CODE: $i");
	$code="NULL";
	last;
      }
      # join all matched expressions with "."
      # TODO: is above wise?
      $code = join(".",@parts);
      $match = $i;
      $iscode{$code} = 1;
      last;
    }
  }

  if ($code) {
#    debug("HOST/CODE: $_ $code");
    print B "$_ $code\n";
  } else {
    print C "$_\n";
  }
}

close(A);
close(B);
close(C);

# print all found codes to "codelist.txt"
# TODO: don't limit to specific hostnames
write_file(join("\n",sort keys %iscode), "/home/barrycarter/BCGIT/GEOLOCATION/codelist.txt");



