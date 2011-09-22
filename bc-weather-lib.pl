# Am I creating too many libs?

=item parse_ship($report)

Parses a SHIP report from
http://weather.noaa.gov/pub/SL.us008001/DF.an/DC.sfmar/DS.ships/,
based on www.nws.noaa.gov/om/marine/handbk1.pdf, returning a hash of data.

Note: SHIP reports may have multiple lines, but $report should be a
single line

=cut

sub parse_ship {
  my($report) = @_;
  my(%rethash) = ();

  # we ignore section 2 entirely
  $report=~s/\s+222\d\d.*$//isg;

  # TODO: it's probably ok to change / to 0
  $report=~s%/%0%isg;

  # split report into chunks
  my(@chunks) = split(/\s+/, $report);

  # the first few elements are fixed
  my($id, $datetime, $lat, $lon, $useless, $wind) = @chunks;

  # $datetime is in DDHHx format, where x indicates wind speed measure type
  # TODO: convert date/hour to Unix time or at least find month/year
  unless ($datetime=~/^(\d{2})(\d{2})([0134])$/) {return "BADTIME: $datetime";}
  ($rethash{date}, $rethash{hour}) = ($1, $2);
  my($wsm) = $3;

  # $lat is 99xxx where xxx = lat/10
  unless ($lat=~/^99(\d{3})$/) {return "BADLAT: $lat";}
  $lat = $1/10;

  # first digit/char in $longitude indicates quadrant, rest is lon/10
  unless ($lon=~/^(1|3|5|7)(\d{4})$/) {return "BADLON: $lon"}
  $lon = $2/10;
  my($quad) = $1;

  # wind is Nddff where N=cloud cover/8, dd=direction, ff=speed
  unless ($wind=~/^(\d)(\d{2})(\d{2})$/) {return "BADWIND: $wind";}
  ($rethash{cloudcover}, $rethash{winddir}, $rethash{windspeed}) = ($1,$2,$3);
  # if wind speed was given in m/s, convert to knots
  if ($wsm==0 || $wsm==1) {$rethash{windspeed} *= 1.9438445;}

  # correct latitude/longitude for quadrant
  if ($quadrant==5 || $quadrant==7) {$lon*=-1;}
  if ($quadrant==3 || $quadrant==5) {$lat*=-1;}

  # and put into results
  $rethash{id} = $id;
  $rethash{latitude} = $lat;
  $rethash{longitude} = $lon;

  # rest of report is optional
  for $i (@chunks) {
    # only care about temperature/pressure
    unless ($i=~/^[124]\d{4}$/) {next;}

    # temperature (1xttt, x=sign, ttt=temperature*10 Celsius)
    if ($i=~/^1(0|1)(\d{3})/) {
      $rethash{temperature} = $3/10*(0.5<=>$2);
      next;
    }

    # dewpoint (2xttt, same convention as temperature)
    if ($i=~/^2(0|1)(\d{3})/) {
      $rethash{dewpoint} = $3/10*(0.5<=>$2);
      next;
    }

    # pressure (4xxxx) where xxxx is hectopascals*10 last four digits
    if ($i=~/4(\d{4})$/) {
      $rethash{pressure} = ($1+($1<5000?10000:0))/10;
      next;
    }

  }
  return %rethash;

}

true;
