use FileHandle;

# these are helper functions that the user cannot call directly

# Meta values for the data sets

our(%meta);

%{$meta{landuse}} = ("dataPointsPerDegree" => 360, "bytesPerDataPoint" => 1);

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

=item mapMeta(%hash)

Given a hash containing a filename, return a hash with metadata about
the data in the filename, including an opened filehandle to the
filename

=cut

sub mapMeta {

  my($hashref) = @_;

  debug("HASHREF: $hashref");

  # TODO: this doesn't check to see if an open filehandle exists, but
  # that may be ok; however, if I'm forking, it may not be

  $hashref->{filehandle} = FileHandle->new($hashref->{filename}, "r");

  my($hdr) = $hashref->{filename};
  $hdr=~s/\.bin/.hdr/;
  debug("HDR: $hdr");
  my($meta) = read_file($hdr);
  for $i (split(/\n/, $meta)) {
    $i=~m%^(.*?)\s+(.*)$%;
    $hashref->{$1} = $2;
  }

#  debug(var_dump("RETURNING", $hashref));

  return $hashref;

}

=item mapData(%hash)

Given the following information in a hash, return the corresponding data

map: the map from which data is requested

wlng, nlat, elng, slat: the bounding box for the requested data (degrees)

dlng, dlat: the requested delta of the longitude and latitude (degrees)

=cut

sub mapData {

  my($hashref) = @_;

  my($meta) = $mapmeta{$hashref->{map}};

  # TODO: return actual data coords not always same as requested

  # TODO: add checks here that data request does not exceed map extents

  # figure out which rows/columns desired and the resolution

  my($startRow) = ($meta->{ULYMAP} - $hashref->{nlat})/$meta->{YDIM};
  my($startCol) = ($hashref->{wlng} - $meta->{ULXMAP})/$meta->{XDIM};
  my($endRow) = ($meta->{ULYMAP} - $hashref->{slat})/$meta->{YDIM};
  my($endCol) = ($hashref->{elng} - $meta->{ULXMAP})/$meta->{XDIM};
  my($rowRes) = $hashref->{dlat}/$meta->{YDIM};
  my($colRes) = $hashref->{dlng}/$meta->{XDIM};

  debug("ROWS: $startRow - $endRow ($rowRes)");
  debug("COLS: $startCol - $endCol ($colRes)");

  # to hold byte data
  my($buf);

  # to hold return data
  my($str);

  # get data

  # TODO: this can probably be much more efficient, especially
  # grabbing multiple columns at a time and returning substr

  for ($i = $startRow; $i < $endRow; $i += $rowRes) {
    for ($j = $startCol; $j < $endCol; $j += $colRes) {

      # to actually get the data we do have to round
      my($seek) = $meta->{NCOLS}*(round($i)-1)*$meta->{NBITS}/8 + 
	round($j)*$meta->{NBITS}/8;

      sysseek($meta->{filehandle}, $seek, SEEK_SET);
      sysread($meta->{filehandle}, $buf, $meta->{NBITS}/8);

      $str .= $buf;
    }
  }

  $hashref->{data} = $str;

  return $hashref;
}

return 1;

