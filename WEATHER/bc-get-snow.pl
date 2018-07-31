#!/bin/perl

# Copy of bc-get-hilo.pl to get snowfall values

# https://earthscience.stackexchange.com/questions/14710/what-is-the-northernmost-southernmost-city-that-receives-no-snow

# NOTE: could use ghncd-inventory to restrict, but don't really care
# to run: fgrep -h SNOW *.dly | bc-get-snow.pl --debug

require "/usr/local/lib/bclib.pl";

my(%hash, %vals, %dates);

while (<>) {

  my($orig) = $_;

  my($stat) = get_chars($_,1,11);

  my($date) = get_chars($_,12,17);

  my($key) = get_chars($_,18,21);

  # just as a doublecheck
  unless ($key eq "SNOW") {next;}

  debug("LOOKING AT: $stat/$date");

  # the 31 element values (per README file)
  for ($i=22; $i<=262; $i+=8) {
    my($val) = get_chars($_, $i, $i+4);
    my($qflag) = get_chars($_, $i+6, $i+6);

    # quality problem with data
    unless ($qflag eq " ") {next;}

    # missing data (also compensates for non-31-day months)
    if ($val == -9999) {next;}

    # total snow for station and days for which we have data
    $hash{$stat}{snow} += $val;
    $hash{$stat}{days}++;
  }
}

for $i (keys %hash) {
  my($perdiem) = $hash{$i}{snow}/$hash{$i}{days};
  print "$i $hash{$i}{snow} $hash{$i}{days} $perdiem\n";
}

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

=item answer

TODO: ANSWER HERE!!!

I decided to use ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/ (I have a slightly outdated version, but that shouldn't be an issue) to find a canonical answer. Notes:

  - GHCN has data for a total of 100,749 weather stations

  - Of these, 59,097 have some snowfall data.

TODO: more here, use abs lat to sort after join

why imperfect, so check against alt sources (TODO: actually do that)

snowfall is in mm

calc 10mm/365.2425 = .0273790700

14225 = no snow, ends at WQW00041606

USC00415113 152 5553 0.0273725913920403 = line 15909
USC00020671 8 292 0.0273972602739726 = line 15910

CIW00054701 -41.4667  -72.8167   11.3    PUERTO MONTT B = southernmost

CA002403833  81.1667  -91.8167   72.0 NU SVARTEVAEG                             71872

https://en.wikipedia.org/wiki/Puerto_Montt

SVARTEVAEG uninhabited

MEIGHEN ISLAND uninhabited

yellowknife: 

CA1NT000002  62.4612 -114.3513  158.2 NT YELLOWKNIFE 1.2 NE - GNWT                   
chevak, alaska ftw? nope!

perl -anle 'if ($F[3] <= .0273790700 && $F[2] >= 366 ) {print $_}' snowfalls.txt.srt | less

perl -anle 'if ($F[3] <= .0273790700 && $F[2] >= 366 ) {print $F[0]}' snowfalls.txt.srt | sort | tee smallsnow.txt

fgrep -f smallsnow.txt ghcnd-stations.txt | sort -k2n > smallsnow.txt.srt





=cut
