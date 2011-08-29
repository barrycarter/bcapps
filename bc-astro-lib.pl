# Finally breaking up my libraries slightly

=item radec2azel($ra, $dec, $lat, $lon, $time)

Given the azimuth and elevation of an object with right ascension $ra
and declination $dec, at latitude $lat and longitude $lon at Unix time
$time

=cut

sub radec2azel {
  my($ra, $dec, $lat, $lon, $time) = @_;
  unless ($time) {$time=time();}

  # convert ra/dec, lat to radians (not lon)
  $ra *= $PI/12;
  $dec *= $PI/180;
  $lat *= $PI/180;

  # determine local siderial time (in hours)
  my($lst) = gmst($time) + $lon/15;
  debug("LST: $lst");
  debug("RA: $ra, OTHER",$lst*$PI/12);
  # determine 'hour angle' (time since last culmination?) in radians
  my($ha) = $lst*$PI/12-$ra;
  debug("HA: $ha");
  debug("DEC: $dec", "LAT: $lat");
  # and now azimuth and elevation
  my($az)=atan2(-sin($ha)*cos($dec),cos($lat)*sin($dec)-sin($lat)*cos($dec)*cos($ha));
  my($el)=asin(sin($lat)*sin($dec)+cos($lat)*cos($dec)*cos($ha));

  # convert back to degrees
  return ($az*180/$PI,$el*180/$PI);
}

1;
