#!/bin/perl

# Given the untar of the file ghcnd_all.tar.gz in
# ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/ (size ~2.9 GB), and the
# subsequent bzip2 compression of the dly files, this program computes
# the frequency of each temperature and stores it compactly; because
# there are many stations, time is of the esscence in the program

require "/usr/local/lib/bclib.pl";

# TODO: early versions might be not efficient (even more so than above)
my($file) = @ARGV;

my(%hash, %vals, %dates);

open(A,"bzegrep 'TMAX|TMIN' $file|");

while (<A>) {

  my($orig) = $_;

  my($date) = get_chars($_,12,17);

  my($key) = get_chars($_,18,21);

  # the 31 element values (per README file)
  for ($i=22; $i<=262; $i+=8) {
    my($val) = get_chars($_, $i, $i+4);
    my($qflag) = get_chars($_, $i+6, $i+6);

    # quality problem with data
    unless ($qflag eq " ") {next;}

    # missing data
    if ($val == -9999) {next;}

    # all good, push data
    push(@{$hash{$key}}, $val);
    # count how many of each
    $vals{$key}++;

    # and push dates to find min and max
    # NOTE: this is highly redundant and occurs for every valid hi/lo entry
    $dates{$date} = 1;
  }
}

my(@dates) = sort {$a <=> $b} keys %dates;

my($stat) = $file;
$stat=~s/\.dly\.bz2$//;
my(@lows) = percentile($hash{TMIN}, [0,.01,.02,.05]);
my(@highs) = percentile($hash{TMAX}, [.95,.98,.99,1]);

# ultimately decided NOT to print first/last dates in this way, though
# I still compute them above

# print join(",",($stat,@lows,@highs,$vals{TMIN},$vals{TMAX},$dates[0], $dates[-1])),"\n";

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

  debug("L",@l);

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

=item comment

Format of *.dly.bz2 files (per README):

ID            1-11   Character
YEAR         12-15   Integer
MONTH        16-17   Integer
ELEMENT      18-21   Character
VALUE1       22-26   Integer
MFLAG1       27-27   Character
QFLAG1       28-28   Character
SFLAG1       29-29   Character
VALUE2       30-34   Integer
MFLAG2       35-35   Character
QFLAG2       36-36   Character
SFLAG2       37-37   Character
  .           .          .
  .           .          .
  .           .          .
VALUE31    262-266   Integer
MFLAG31    267-267   Character
QFLAG31    268-268   Character
SFLAG31    269-269   Character

=cut
