# these are helper functions that the user cannot call directly

# Meta values for the data sets

# Given a hash where the key cmd represents the command, call the
# relevant use command in bc-mapserver-commands.pl

# NOTE: the hash sent can come from GET or JSON

sub process_command {

  my($hashref) = @_;

  # run command
  my($res) = eval("command_$hashref->{cmd}(\$hashref)");

  # TODO: can there be other errors? if so, catch them

  if ($@) {
    return str2hashref("type=error&value=The command **$hashref->{cmd}** does not exist");
  }

  return $res;

}

=item latlon2pixel($hashref)

Given lat, lon, ppd (pixels per degree), and dpd (data per degree)
value in hash, return x and y position of latitude/longitude, byte
where data would be found, and adjusted lat and lon (for rounding)

=cut

sub lonlat2pixel {

  my($hashref) = @_;

  debug(var_dump("lonlat2pixel", $hashref));

  # setting the input hash is a bit weird, but it should work

  $hashref->{x} = round(($hashref->{lon}+180)*$hashref->{ppd});
  $hashref->{y} = round(($hashref->{lat}+90)*$hashref->{ppd});
  $hashref->{byte} = $hashref->{y}*360*$hashref->{ppd}*$hashref->{dpd} + 
    $hashref->{x}*$hashref->{dpd};

  $hashref->{adjlon} = $hashref->{x}/$hashref->{ppd}-180;
  $hashref->{adjlat} = $hashref->{y}/$hashref->{ppd}-90;

  return $hashref;

}


# return landuse for a specific lat and lon

sub landuse {

  my($hashref) = @_;
  my($data);

  # TODO: be careful here with file handles
  unless (-r LANDUSE) {
    # TODO: this path will change
    open(LANDUSE, "/mnt/villa/user/NOBACKUP/EARTHDATA/LANDUSE/landuse.dat");
  }

  # add some specifications for landuse
  $hashref->{ppd} = 360;
  $hashref->{dpd} = 1;

  my($ret) = lonlat2pixel($hashref);

  seek(LANDUSE, $ret->{byte}, SEEK_SET);
  sysread(LANDUSE, $data, 1);
  return str2hashref("cmd=landuse&lon=$hashref->{lon}&lat=$hashref->{lat}&adjlat=$hashref->{adjlat}&adjlon=$hashref->{adjlon}&value=".ord($data));
}

return 1;

