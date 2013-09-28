#!/bin/perl

# This script converts the geonames files at:
# http://download.geonames.org/export/dump/
# into an SQLite3 db (result: http://geonames2.db.94y.info)

# Improvements 28 Sep 2013:
# latitude/longitude no longer mangled
# new 'parent' field
# add ids to altnames table

use utf8;
use Text::Unidecode;
use Math::Round;
require "/usr/local/lib/bclib.pl";

# this program takes time to run, so warn about missing files ASAP
for $i ("admin1CodesASCII.txt", "countryInfo.txt", "allCountries.txt", "alternateNames.txt") {
  unless (-f $i) {die "$i must exist in current directory (you may need to unzip alternateNames.zip";}
}

# create altnames table first, since I'm testing it
open(A,"/var/tmp/alternateNames.txt");
open(B,">/var/tmp/altnames.out");

while (<A>) {
  chomp($_);
  $lines++;

  # shortcut?
  $_ = cleanup($_);
  debug("THUNK: $_");

  my($alternateNameId, $geonameid, $isolanguage, $alternatename,
     $isPreferredName, $isShortName, $isColloquial, $isHistoric) =
       split("\t", $_);
  # clean alternate name
  $alternatename = cleanup($alternatename);
#  print B 
}

close(B);

die "TESTING";

# these files are pretty important so using /var/tmp not /tmp
open(B,">/var/tmp/altnames.out");
open(C,">/var/tmp/geonames.out");
open(D,">/var/tmp/tzones.out");
# TODO: I never create a table from the file below, but should
open(E,">/var/tmp/featurecodes.out");

# create cheat table for parents
unless (-f "/var/tmp/admpcl.txt") {
  system("grep -e 'ADM|PCL' allCountries.txt 1> /var/tmp/admpcl.txt");
}

open(A,"/var/tmp/admpcl.txt");

while (<A>) {
  chomp($_);

  ($geonameid, $name, $asciiname, $alternatenames, $latitude, $longitude,
   $featureclass, $featurecode, $countrycode, $cc2, $admin1code,
   $admin2code, $admin3code, $admin4code, $population, $elevation,
   $gtopo30, $timezone, $modificationdate) = split("\t",$_);

  # ignore admin1code of 00 meaning unknown (unless this is a PCL)
  if ($admin1code eq "00" && $featurecode=~/^ADM/) {
    debug("IGNORING: $_");
    next;
  }

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
open(A,"allCountries.txt");

while (<A>) {
  chomp($_);

  $lines++;
#  if ($lines >= 100000) {die "TESTING";}

  ($geonameid, $name, $asciiname, $alternatenames, $latitude, $longitude,
   $featureclass, $featurecode, $countrycode, $cc2, $admin1code,
   $admin2code, $admin3code, $admin4code, $population, $elevation,
   $gtopo30, $timezone, $modificationdate) = split("\t",$_);

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

  debug("ADMINS: $admin4new $admin3new $admin2new $admin1new $admin0new");

  # record "parent" only; much more efficient
  # TODO: better ways to do this... Perl coalesce?
  if ($admin4new) {$parent = $admin4new;} elsif
    ($admin3new) {$parent = $admin3new;} elsif
      ($admin2new) {$parent = $admin2new;} elsif
	($admin1new) {$parent = $admin1new;} elsif
	  ($admin0new) {$parent = $admin0new;} else {
	    $parent = 0;
	  }

  debug("PARENT: $parent");

  # TODO: parent = 0 is probably an error

  # the geonames table must come first, because writing to
  # alternate_names mangles stuff

  print C join("\t", $geonameid, $asciiname, $latitude, $longitude,
  $featurecode, $parent, $admin0new, $admin4new, $admin3new, $admin2new,
  $admin1new, $population, $tz, $elevation)."\n";

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
