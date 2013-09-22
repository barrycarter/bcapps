#!/usr/bin/perl

require "/usr/local/lib/bclib.pl";

get_raws_obs();

=item get_raws_obs()

Obtain weather information from http://raws.wrh.noaa.gov/rawsobs.html

/var/tmp/raws must exist and be write-able

=cut

sub get_raws_obs {
  # chdir to correct directory
  dodie('chdir("/var/tmp/raws")');
  # index page almost never changes
  my($out,$err,$res) = cache_command2("curl http://raws.wrh.noaa.gov/rawsobs.html", "age=86400");
  # use parallel
  local(*A);
  open(A, "| parallel -j 10");

  # find hrefs and push to "well known" files
  while ($out=~s%"(http://raws.wrh.noaa.gov/.*?)"%%s) {
    my($url) = $1;
    unless ($url=~/stn\=(.*)/s) {next;}
    my($stn) = $1;
    # if we have a file less than an hour old, do nothing
    if (-f $stn && -M $stn < 1/24.) {next;}
    print A "curl -o $stn '$url'\n";
  }

  close(A);
}

