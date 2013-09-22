#!/usr/bin/perl

require "/usr/local/lib/bclib.pl";

get_raws_obs();

=item get_raws_obs()

Obtain weather information from http://raws.wrh.noaa.gov/rawsobs.html

=cut

sub get_raws_obs {
  # index page almost never changes
  my($out,$err,$res) = cache_command2("curl http://raws.wrh.noaa.gov/rawsobs.html", "age=86400");
  # find hrefs
  while ($out=~s%"(http://raws.wrh.noaa.gov/.*?)"%%s) {
    my($url) = $1;
    unless ($url=~/stn=/) {next;}
    # updated hourly
    my($out,$err,$res) = cache_command2("curl '$url'", "age=3600");
    debug("$url: $out");
  }
}

