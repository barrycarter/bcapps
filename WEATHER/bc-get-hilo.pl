#!/bin/perl

# Given the untar of the file ghcnd_all.tar.gz in
# ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/ (size ~2.9 GB), and the
# subsequent bzip2 compression of the dly files, this program computes
# the frequency of each temperature and stores it compactly; because
# there are many stations, time is of the esscence in the program

require "/usr/local/lib/bclib.pl";

# TODO: early versions might be not efficient (even more so than above)
my($file) = @ARGV;

my(%hash, %vals);

open(A,"bzegrep 'TMAX|TMIN' $file|");

while (<A>) {

  my($orig) = $_;

  my($key) = get_chars($_,18,21);

  # the 31 element values (per README file)
  for ($i=22; $i<=262; $i+=8) {
    my($val) = get_chars($_, $i, $i+4);
    my($qflag) = get_chars($_, $i+6, $i+6);

    # quality problem with data
    unless ($qflag eq " ") {next;}

    # missing data
    if ($val == -9999) {next;}

    # all good, push
    push(@{$hash{$key}}, $val);
    # count how many of each
    $vals{$key}++;
  }

}

my($stat) = $file;
$stat=~s/\.dly\.bz2$//;
my(@lows) = percentile($hash{TMIN}, [0,.01,.02,.05]);
my(@highs) = percentile($hash{TMAX}, [.95,.98,.99,1]);
print join(",",($stat,@lows,@highs,$vals{TMIN},$vals{TMAX})),"\n";

=item percentile(\@list, \@percentiles)

Calculate the given percentiles of a given a list.

TODO: maybe put this in bclib.pl

=cut

sub percentile {
  my($lref, $pref) = @_;
  my(@l) = sort {$a <=> $b} (@$lref);
  my(@p) = @$pref;
  my(@ret);

  for $i (@p) {
    my($elt) = $#l*$i;
    my($int) = floor($elt);
    my($frac) = $elt-floor($elt);
    push(@ret, $l[$int]*(1-$frac) + $frac*$l[$int+1]);
  }
  return @ret;
}

# TODO: this needs to go into bclib.pl

sub get_chars {
  my($str,$x,$y) = @_;
  return substr($str,$x-1,$y-$x+1);
}
