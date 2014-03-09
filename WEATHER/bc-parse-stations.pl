#!/bin/perl

# Parses the latest version of
# http://weather.noaa.gov/data/nsd_cccc.txt and 
# http://www.rap.ucar.edu/weather/surface/stations.txt
# but only after parsing MLI list which trumps these lists

# all subroutines must: check/set seen hash and close(A)

# -noprint: don't print anything (useful for debugging)

require "/usr/local/lib/bclib.pl";

# mli contains weird entries, so must go first
mli();
# because we get most of our data from mesonet, it comes next
meso();
nsd();
ucar();

# fake subroutine so I can control order in which files are read
sub meso {
  local(*A);

  # use csv file, it's more accurate than meso_station.cgi.html
  open(A, "zcat /home/barrycarter/BCGIT/WEATHER/mesowest_link_csv.tbl.gz|");

  # skip header line (this is cheating in some sense)
  <A>;

  while (<A>) {
    # convert quotation marks
    s/\"/&quot;/isg;
    my(@data) = csv($_);
    # get rid of backticks
    map($_=trim($_), @data);

    # global seen hash
    if ($seen{$data[0]}) {next;}
    $seen{$data[0]} = 1;
    print join("\t", $data[0], "NULL", $data[2], $data[3], $data[4], $data[5],
	       $data[6], $data[7],
	       "http://mesowest.utah.edu/cgi-bin/droman/meso_station.cgi"),
		 "\n";
  }

  close(A);
}

# fake subroutine
sub nsd {
  local(*A);
  open(A,"/home/barrycarter/BCGIT/WEATHER/nsd_cccc_annotated.txt");

  while (<A>) {
  # x1, x2 = useless to me
    my($indi,$wmob,$wmos,$place,$state,$country,$wmoregion,$lat,$lon,$x1,$x2,$elev) = split(/\;/, $_);

    # seen by anyone else?
    if ($seen{$indi}) {
      debug("NSD SEEN: $indi");
      next;
    }

    debug("NSD NEW: $indi");
    $seen{$indi}=1;

    # convert lat to decimal (probably much better ways to do this!)
    if ($lat=~/^(\d{2})\-(\d{2})(N|S)/) {
      ($lad,$lam,$las,$lax)=($1,$2,0,$3);
    } elsif ($lat=~/^(\d{2})\-(\d{2})\-(\d{2})(N|S)/) {
      ($lad,$lam,$las,$lax)=($1,$2,$3,$4);
    } else {
      warn("BAD LAT: $lat");
    }
    
    $flat=$lad+$lam/60+$las/3600;
    if ($lax eq "S") {$flat=-$flat;}
    
    if ($lon=~/^(\d{2,3})\-(\d{2})(E|W)/) {
      ($lod,$lom,$los,$lox)=($1,$2,0,$3);
    } elsif ($lon=~/^(\d{2,3})\-(\d{2})\-(\d{2})(E|W)/) {
      ($lod,$lom,$los,$lox)=($1,$2,$3,$4);
    } else {
      warn("BAD LON: $lon");
    }

    $flon=$lod+$lom/60+$los/3600;
    if ($lox eq "W") {$flon=-$flon;}

    # correct elevation, combo field for WMO
    $elev = round2(convert($elev,"m","ft"));
    $wmobs = $wmob*1000+$wmos;

    debug("NSD ABOUT TO PRINT");
    # print in importable format (for sqlite3)
    print join("\t", ($indi, $wmobs, $place, $state, $country, $flat, $flon, $elev, "http://weather.noaa.gov/data/nsd_cccc.txt")),"\n";
  }
  close(A);
}

sub ucar {
  # columns where data starts (not actually all data, just start/end cols I need)
  @cols = (0, 3, 20, 26, 32, 39, 47, 55, 61, 80, 99);
  local(*A);
  open(A,"/home/barrycarter/BCGIT/WEATHER/stations.txt");

  while (<A>) {
    # ignore comments (start with "!") and blank lines
    if (/^\!/ || /^\s*$/) {next;}

    # if third column is non-blank, this is a header line, not a data line
    unless (substr($_,2,1)=~/\s/) {next;}

    # get data from columns
    @data=();
    for $j (0..$#cols) {
      $item = substr($_, $cols[$j], $cols[$j+1]-$cols[$j]);
      $item=trim($item);
      push(@data,$item);
    }

    # assign data to vars
    ($state, $name, $code, $iata, $synop, $lat, $lon, $elev, $junk, $country) = @data;

    # ignore blank codes and seen codes and header "ICAO" code
    if ($code=~/^\s*$/ || $seen{$code} || $code=~/^ICAO$/) {next;}

    # third col test above insufficient; if $code starts with number, ignore
    if ($code=~/^\d/) {next;}

    # have we seen this code?
    if ($seen{$code}) {next;}
    $seen{$code} = 1;

    # icky code copying from above, except "-" becomes " "
    # convert lat to decimal (probably much better ways to do this!)
    if ($lat=~/^(\d{2})\s(\d{2})(N|S)/) {
      ($lad,$lam,$las,$lax)=($1,$2,0,$3);
    } elsif ($lat=~/^(\d{2})\s(\d{2})\s(\d{2})(N|S)/) {
      ($lad,$lam,$las,$lax)=($1,$2,$3,$4);
    } else {
      warn("BAD LAT: $lat");
    }

    $flat=$lad+$lam/60+$las/3600;
    if ($lax eq "S") {$flat=-$flat;}

    if ($lon=~/^(\d{2,3})\s(\d{2})(E|W)/) {
      ($lod,$lom,$los,$lox)=($1,$2,0,$3);
    } elsif ($lon=~/^(\d{2,3})\s(\d{2})\s(\d{2})(E|W)/) {
      ($lod,$lom,$los,$lox)=($1,$2,$3,$4);
    } else {
      warn("BAD LON: $lon");
    }

    $flon=$lod+$lom/60+$los/3600;
    if ($lox eq "W") {$flon=-$flon;}

    # correct elevation
    $elev = round2(convert($elev,"m","ft"));

    # print in importable format (for sqlite3)
    print join("\t", ($code, $wmobs, $name, $state, $country, $flat, $flon, $elev, "http://www.rap.ucar.edu/weather/surface/stations.txt")),"\n";
  }
  close(A);
}

sub mli {

  @ls=split(/\n/,read_file("/home/barrycarter/BCGIT/WEATHER/master-location-identifier-database-20130801.csv"));
  # get rid of useless lines
  for (1..4) {shift(@ls);}
  # array-ify
  map(push(@res, [csv($_)]), @ls);
  ($hlref) = arraywheaders2hashlist(\@res);

  for $i (@{$hlref}) {

  # if ICAO blank, try to find it elsewhere
    unless ($i->{icao}=~/\S/) {
      if ($i->{icao_xref}=~/\S/) {
	debug("CASE XREF");
	$i->{icao} = $i->{icao_xref};
      } elsif ($i->{stn_key}=~s/^USaa//) {
	debug("CASE STNKEY");
	$i->{icao} = $i->{stn_key};
      } else {
	debug("LINE HAS NO ICAO");
	next;
    }
  }


    # TODO: should I really ignore non-metar?

    # ignore things without lat/lon too
    $err = 0;
    for $j ("icao", "lat_prp", "lon_prp") {
      # just spaces and apostrophes
      if ($i->{$j}=~m/^[\'\s]*$/) {$err=1;}
    }

    # impossible lat/lon
    if (abs($i->{lat_prp})>90 || abs($i->{lon_prp})>180) {$err=1;}
    
    if ($err) {
      debug("SKIPPING: ($i->{icao}) ($i->{lat_prp}) ($i->{lon_prp})");
      next;
    }

    # no duplicates
    if ($seen{$i->{icao}}) {next;}
    $seen{$i->{icao}} = 1;

    # cheat to make city look nicer
    $i->{city}=~s/\|(.*)$/ ($1)/;

    # most fields can be used as is (region -> state)
    @l = ();
    for $j ("icao", "wmo", "city", "region", "country", "lat_prp", "lon_prp") {
      # if it has nothing but dashes/spaces, it's null
      if ($i->{$j}=~/^[\s\-]*$/) {$i->{$j} = "NULL";}
      push(@l, $i->{$j});
    }

    # fix elevation
    push(@l, round2(convert($i->{elev_baro},"m","ft")));
    # and source
    push(@l, "http://www.weathergraphics.com/identifiers/master-location-identifier-database-20130801.csv");
    print join("\t",@l),"\n";
  }
}


=item schema

CREATE TABLE stations ( 
 metar TEXT,
 wmobs INT, 
 city TEXT, 
 state TEXT, 
 country TEXT, 
 latitude DOUBLE, 
 longitude DOUBLE, 
 elevation DOUBLE,
 source TEXT 
);

CREATE INDEX i_metar ON stations(metar);

.separator "\t"
.import /path/to/output/of/this/program stations

=cut

