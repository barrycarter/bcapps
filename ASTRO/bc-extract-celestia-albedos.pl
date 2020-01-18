#!/bin/perl

# use Celestia ssc files to obtain albedo data and put it into an
# array (or two arrays if using bond and geometric albedo)

# TODO: Roman numeral library

require "/usr/local/lib/bclib.pl";

%short = ("MERCURY" => 1, "VENUS" => 2, "EARTH" => 3, "MARS" => 4, "JUPITER" => 5,
          "SATURN" => 6, "URANUS" => 7, "NEPTUNE" => 8, "PLUTO" => 9);

my($data, $fname) = cmdfile();

for $i (split(/\n+/, $data)) {

    my($name, $ext, $planetid);

    if ($i=~/^\"(.*?)\"/) {
	$name = $1;
	$name=~s/^[^:]*://;

	if ($name=~m%(\S+)\s+(.*)$%) {
	    $name = $1;
	    $ext = $2;
	}

	$planetid = $short{uc($name)};

	unless ($planetid) {die ("BAD PLANETID: $i, NAME: $name, EXT: $ext");}

	

	debug("LINE: $name/$ext/$planetid");
    }

    if ($i=~/albedo/i) {
	debug("LINE: $i");
    }
}

