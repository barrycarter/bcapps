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
