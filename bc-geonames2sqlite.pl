#!/bin/perl

# NOTE: if you just want the resulting database:
# http://geonames.db.94y.info

# This script converts the geonames files at:
# http://download.geonames.org/export/dump/
# into an SQLite3 db

# allCountries comes in a .zip file, but I unzipped it and then bzip2'd it
# <h>I'm not sure why. I suspect rabies</h>

# NOTE: this program does NOT include allCountries.txt.bz2 (it'd be
# out of date anyway); please obtain it yourself

# These files are assumed to be in the current directory:
# allCountries.txt.bz2
# admin1CodesASCII.txt
# countryInfo.txt

use utf8;
use Text::Unidecode;
use Math::Round;
push(@INC,"/usr/local/lib");
require "bclib.pl";
# these files are pretty important so using /var/tmp not /tmp
open(B,">/var/tmp/altnames.out");
open(C,">/var/tmp/geonames.out");
open(D,">/var/tmp/tzones.out");
# TODO: I never create a table from the file below, but should
open(E,">/var/tmp/featurecodes.out");

# things that are listed as ADM/PCL, but aren't really
# probably bad to hardcode ids here: one of them doesn't even exist anymore!
# if you're REALLY curious what these are:
# http://ws.geonames.org/get?geonameId=2634343 (for example)
@fakeadm = (2411430,3370684,6940286,921810,6693220,2634343);
%fakeadm = list2hash(@fakeadm);

# create cheat table for parents
unless (-f "/var/tmp/admpcl.txt") {
  system("bzgrep -e 'ADM|PCL' allCountries.txt.bz2 1> /var/tmp/admpcl.txt");
}

open(A,"/var/tmp/admpcl.txt");

while (<A>) {
  chomp($_);

  ($geonameid, $name, $asciiname, $alternatenames, $latitude, $longitude,
   $featureclass, $featurecode, $countrycode, $cc2, $admin1code,
   $admin2code, $admin3code, $admin4code, $population, $elevation,
   $gtopo30, $timezone, $modificationdate) = split("\t",$_);

  # ignore fake ADM/PCL
  if ($fakeadm{$geonameid}) {next;}

  # ignore admin1code of 00 meaning unknown (unless this is a PCL)
  if ($admin1code eq "00" && $featurecode=~/^ADM/) {next;}

  # for ADM1-4 and PCL, record full path
  if ($featurecode eq "ADM4" && $admin4code ne $geonameid && $admin4code ne "") {
    $ADM4{$countrycode}{$admin1code}{$admin2code}{$admin3code}{$admin4code} = $geonameid;
#    debug("$countrycode/$admin1code/$admin2code/$admin3code/$admin4code: $geonameid");
  } elsif ($featurecode eq "ADM3" && $admin3code ne $geonameid && $admin3code ne "") {
#    $ADM3{$countrycode}{$admin1code}{$admin2code}{$admin3code} = $geonameid;
    debug("$countrycode/$admin1code/$admin2code/$admin3code: $geonameid");
  } elsif ($featurecode eq "ADM2" && $admin2code ne $geonameid && $admin2code ne "") {
    $ADM2{$countrycode}{$admin1code}{$admin2code} = $geonameid;
    debug("$countrycode/$admin1code/$admin2code: $geonameid");
  } elsif ($featurecode eq "ADM1" && $admin1code ne $geonameid && $admin1code ne "") {
    $ADM1{$countrycode}{$admin1code} = $geonameid;
    debug("$countrycode/$admin1code: $geonameid");
  } elsif ($featurecode=~/^PCL/ && $countrycode ne $geonameid && $countrycode ne "") {
    $ADM0{$countrycode} = $geonameid;
    debug("$countrycode: $geonameid");
  } else {
    # do nothing
  }
}

close(A);

# handle admin1codes
open(A,"admin1CodesASCII.txt");

while (<A>) {
  chomp($_);

  ($code,$short,$long,$id) = split("\t",$_);
  ($cc,$ad) = split(/\./, $code);

  for $i ($ad,$short,$long) {
    $i = cleanup($i);
    print B "$id\t$i\n";
  }
}

close(A);

# and country codes
open(A,"countryInfo.txt");

while (<A>) {
  if (/^\#/ || /^iso/) {next;}

  ($ISO, $ISO3, $ISONumeric, $fips, $Country, $Capital, $Area, $Population,
   $Continent, $tld, $CurrencyCode, $CurrencyName, $Phone,
   $PostalCodeFormat, $PostalCodeRegex, $Languages, $geonameid, $neighbours,
   $EquivalentFipsCode) = split("\t",$_);

  for $i ($ISO,$ISO3,$fips,$Country) {
    $i = cleanup($i);
    print B "$geonameid\t$i\n";
  }
}

close(A);

# TODO: remove any blank names that might've snuck in

# and now the main file...
open(A,"bzcat allCountries.txt.bz2|");

while (<A>) {
  chomp($_);

  $lines++;
#  if ($lines >= 100000) {die "TESTING";}

  ($geonameid, $name, $asciiname, $alternatenames, $latitude, $longitude,
   $featureclass, $featurecode, $countrycode, $cc2, $admin1code,
   $admin2code, $admin3code, $admin4code, $population, $elevation,
   $gtopo30, $timezone, $modificationdate) = split("\t",$_);

  # NOTE: considered limiting to places w/ population of featurecode AP
  # meaning "populated place", but decided to just convert everything
  #  unless ($population || $featureclass=~/^[ap]$/i ) {next;}

  # index featurecode
  unless ($FEATURECODE{$featurecode}) {
    $FEATURECODE{$featurecode} = ++$featurecodecount;
    print E "$featurecodecount\t$featurecode\n";
  }

  $featurecode = $FEATURECODE{$featurecode};

  if ($featurecode =~/^pcl/i) {
    $adm = 0;
  } elsif ($featurecode =~/^adm(\d)$/i) {
    $adm = $1;
  } else {
    $adm = -1;
  }

  # In theory, the below lets me store both latitude/longitude in a
  # 63-bit (or even 48-bit) integer; this may be useful one day if I
  # use sqlite3's implicit oid column; for now, it just confuses things

  # convert lat/lon to 3-byte int
  $latitude = round($latitude*8388607/90);
  $longitude = round($longitude*8388607/180);

  # index timezone
  unless ($TZ{$timezone}) {
    $TZ{$timezone} = ++$count;
    print D "$count\t$timezone\n";
  }

  $tz = $TZ{$timezone};

  # set admincodes to geonameids (OK if blank)
  $admin4new = $ADM4{$countrycode}{$admin1code}{$admin2code}{$admin3code}{$admin4code};
  $admin3new = $ADM3{$countrycode}{$admin1code}{$admin2code}{$admin3code};
  $admin2new = $ADM2{$countrycode}{$admin1code}{$admin2code};
  $admin1new = $ADM1{$countrycode}{$admin1code};
  $admin0new = $ADM0{$countrycode};

  # record "parent" only; much more efficient
  # TODO: better ways to do this... Perl coalesce?
  if ($admin4new) {$parent = $admin4new;} elsif
    ($admin3new) {$parent = $admin3new;} elsif
      ($admin2new) {$parent = $admin2new;} elsif
	($admin1new) {$parent = $admin1new;} elsif
	  ($admin0new) {$parent = $admin0new;} else {
	    $parent = 0;
	  }

  # TODO: parent = 0 is probably an error

  # the geonames table must come first, because writing to
  # alternate_names mangles stuff

  print C join("\t", $geonameid, $asciiname, $latitude, $longitude,
  $featurecode, $parent, $population, $tz)."\n";

  # $name and $asciiname and $alternatenames are alt names
  for $i ($name,$asciiname,split(",",$alternatenames)) {
    $i = cleanup($i);
    print B "$geonameid\t$i\n";
  }
}

close(A);
close(B);
close(C);
close(D);
close(E);

system("sort -n /var/tmp/altnames.out | uniq > /var/tmp/altnames2.out");

# unidecode the way I want it
sub cleanup {
  my($name) = @_;

  # unidecode the whole thing first, lower case, despace
  $name = lc(unidecode($name));

  # remove spaces
  $name=~s/\s//isg;

  # remove the word "(general)" and "[provisional]"
  $name=~s/\(general\)//isg;
  $name=~s/\[provisional\]//isg;

  # for other (x), change to x (later decided against this)
#  $name=~s/\((.*?)\)/$1/isg;

  # this is really ugly + might break stuff
  $name=~s/[^a-z]//isg;

  # if it still has bad chars, report and return empty
  if ($name=~/[^a-z]/) {
    warn "Ignoring: $name";
    return "";
  }

  return $name;
}

=item sql

To actually create the sqlite3 db, run these commands

CREATE TABLE geonames (
 geonameid INTEGER PRIMARY KEY,
 asciiname TEXT,
 latitude INT,
 longitude INT,
 feature_code INT,
 parent INT,
 population INT,
 timezone INT
);

CREATE INDEX i_feature_code ON geonames(feature_code);
CREATE INDEX i_parent ON geonames(parent);
.separator "\t"
.import /var/tmp/geonames.out geonames

CREATE TABLE altnames (
 geonameid INT,
 name TEXT
);

CREATE INDEX i_name ON altnames(name);
.import /var/tmp/altnames2.out altnames
DELETE FROM altnames WHERE name = '';
INSERT INTO altnames VALUES (0,'');
INSERT INTO geonames (geonameid) VALUES (0);
VACUUM;

CREATE TABLE tzones (
 timezoneid INTEGER PRIMARY KEY,
 name TEXT
);
.separator "\t"
.import /var/tmp/tzones.out tzones

=cut

