#!/bin/perl

# This script converts the geonames files at:
# http://download.geonames.org/export/dump/
# into an SQLite3 db (result: http://geonames.db.94y.info)

# --nodep: don't check for file dependencies (useful when testing)

# Improvements 28 Sep 2013:
# latitude/longitude no longer mangled
# add ids to altnames table

# TODO: this entire code seems really ugly
# TODO: all geonames are also altnames!

use utf8;
use Text::Unidecode;
use Math::Round;
require "/usr/local/lib/bclib.pl";

unless (-f "canon.txt") {admpcl();}

# load the canon.txt hash
for $i (split("\n",read_file("canon.txt"))) {
#  debug("I: $i");
  unless ($i=~m%^(\d)\s+(\d+)\s+(.*?)$%) {die "BAD LINE: $i";}
  $canon{$1}{$3} = $2;
}

# sort -R version of allCountries.txt, useful for testing
open(A,"allCountries.txt");
open(C,">geonames.tsv");

while (<A>) {
  chomp($_);
  s/\"//isg;

  $lines++;
#  if ($lines >= 100000) {warn "TESTING"; last;}

  @admin = ();
  ($geonameid, $name, $asciiname, $alternatenames, $latitude, $longitude,
   $featureclass, $featurecode, $admin[0], $cc2, $admin[1],
   $admin[2], $admin[3], $admin[4], $population, $elevation,
   $gtopo30, $timezone, $modificationdate) = split("\t",$_);

  # convert admin codes to geonameid where possible
  # everything has a country code (hopefully)
  $admintest = $admin[0];
  $admin[0] = $canon{0}{$admin[0]};
  for $j (1..4) {
    # if ADM$j is empty, ignore rest (but if it's 0 do not ignore)
    unless (length($admin[$j])>=1) {last;}
    # does this admin level match a know canonical ADM?
    $admintest = "$admintest.$admin[$j]";
    if ($canon{$j}{$admintest}) {$admin[$j] = $canon{$j}{$admintest};}
  }

  # whatever $admintest ends up as will be the adminstring

  print C join("\t", $geonameid, $asciiname, $latitude, $longitude,
  $featurecode, $admin[0], $admin[4], $admin[3], $admin[2],
  $admin[1], $admintest, $population, $timezone, $elevation)."\n";
}

close(A);
close(C);

die "TESTING";

# this program takes time to run, so warn about missing files ASAP
for $i ("admin1CodesASCII.txt", "countryInfo.txt", "allCountries.txt",
	"alternateNames.txt", "featureCodes_en.txt") {
  if ($globopts{nodep}) {next;}
  unless (-f $i) {die "$i must exist in current directory (you may need to unzip)";}
}

# using GOTO is getting addictive
if (-f "/var/tmp/altnames1.out") {
  warn("Using existing version of /var/tmp/altnames1.out");
  goto ALLCOUNTRIES;
}

# create altnames table first, since I'm testing it
open(A,"alternateNames.txt");
open(B,">/var/tmp/altnames1.out");

while (<A>) {
  chomp($_);

  if ($lines++ % 100000==0) {debug("$lines LINES");}

  my($alternateNameId, $geonameid, $isolanguage, $alternatename,
     $isPreferredName, $isShortName, $isColloquial, $isHistoric) =
       split("\t", $_);

  # ignore links (TODO: I feel bad about this)
  if ($isolanguage eq "link") {next;}

  # clean alternate name
  $alternatename = cleanup($alternatename);

  # and print
  print B join("\t", ($alternateNameId, $geonameid, $isolanguage, 
		       $alternatename, $isPreferredName, $isShortName,
		       $isColloquial, $isHistoric)),"\n";
}

close(B);

ALLCOUNTRIES:

# create cheat table for parents
unless (-f "/var/tmp/admpcl.txt") {
  debug("Creating /var/tmp/admpcl.txt");
  # there really is no ADM0, I'm being snarky
  system("egrep 'PCLI|ADM[0-4]' allCountries.txt 1> /var/tmp/admpcl.txt");
}

# the idea here is to map all ADM0-4 codes (ADM0=PCL) to
# geonameids. However, the ADM3 code "123" can mean different things
# depending on the values of ADM0-2; the code below attempts to do
# this

open(A,"/var/tmp/admpcl.txt");
debug("Parsing /var/tmp/admpcl.txt");

while (<A>) {
  chomp($_);

  # easier to think of country code as ADM0
  @admin = ();
  ($geonameid, $name, $asciiname, $alternatenames, $latitude, $longitude,
   $featureclass, $featurecode, $admin[0], $cc2, $admin[1],
   $admin[2], $admin[3], $admin[4], $population, $elevation,
   $gtopo30, $timezone, $modificationdate) = split("\t",$_);

  # the grep collects some things we don't want...
  if ($featurecode eq "RDGE") {next;}

  # ignore historicals
  if ($featurecode=~/^ADM\dH$/ || $featurecode eq "PCLH") {next;}

  # what level admin code is this?
  # TODO: not sure the check for countries is correct; do all have
  # their own country code? (may not matter if they don't)
  if ($featurecode=~/^PCL[FIDS]?X?$/) {
    $level=0
  } elsif ($featurecode=~/^ADM(\d)$/) {
    $level = $1
  } else {
    warn("BAD LINE: $_");
  }

  debug("FC: $level, ADMIN:",@admin);
}

die "TESTING";

# feature codes we can safely ignore (not usable admin districts)
# TODO: ADMD bad to ignore?
# NOTE: WADM shows up because of grep above (TODO: improve grep?)
%ignorefc = list2hash("ADMD", "ADM1H", "ADM2H", "ADM3H", "ADM4H", "WADM",
		     "ADMF");

while (<A>) {
  chomp($_);

  ($geonameid, $name, $asciiname, $alternatenames, $latitude, $longitude,
   $featureclass, $featurecode, $countrycode, $cc2, $admin1code,
   $admin2code, $admin3code, $admin4code, $population, $elevation,
   $gtopo30, $timezone, $modificationdate) = split("\t",$_);

  if ($ignorefc{$featurecode}) {next;}

  # TODO: are there any ADM3/4 which aren't geonameids?

  # for ADM1-4 and PCL, record full path
  if ($featurecode eq "ADM4" && $admin4code ne $geonameid && $admin4code ne "") {
    $ADM4{$countrycode}{$admin1code}{$admin2code}{$admin3code}{$admin4code} = $geonameid;
    debug("ADM4: $countrycode/$admin1code/$admin2code/$admin3code/$admin4code: $geonameid");
  } elsif ($featurecode eq "ADM3" && $admin3code ne $geonameid && $admin3code ne "") {
    $ADM3{$countrycode}{$admin1code}{$admin2code}{$admin3code} = $geonameid;
    debug("ADM3: $countrycode/$admin1code/$admin2code/$admin3code: $geonameid");
  } elsif ($featurecode eq "ADM2" && $admin2code ne $geonameid && $admin2code ne "") {
    $ADM2{$countrycode}{$admin1code}{$admin2code} = $geonameid;
#    debug("$countrycode/$admin1code/$admin2code: $geonameid");
  } elsif ($featurecode eq "ADM1" && $admin1code ne $geonameid && $admin1code ne "") {
    $ADM1{$countrycode}{$admin1code} = $geonameid;
    debug("$countrycode/$admin1code: $geonameid");
  } elsif ($featurecode=~/^PCL/ && $countrycode ne $geonameid && $countrycode ne "") {
    $ADM0{$countrycode} = $geonameid;
    debug("$countrycode: $geonameid");
  } elsif ($admin2code == $geonameid) {
    # this just catches non-errors
    # TODO: of course, this could happen with ADM1, ADM3/4 too
#    debug("ADM2 code is already geonameid");
  } else {
    debug("COULD NOT HANDLE: $_, FC: $featurecode, CODE: $admin3code");
  }
}

close(A);

# these files are pretty important so using /var/tmp not /tmp
open(B,">/var/tmp/altnames.out");
open(C,">/var/tmp/geonames.out");
open(D,">/var/tmp/tzones.out");
# TODO: I never create a table from the file below, but should
open(E,">/var/tmp/featurecodes.out");

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

die "TESTING";

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

  # this is really ugly + might break stuff
  $name=~s/[^a-z]//isg;

  # if it still has bad chars, report and return empty
  if ($name=~/[^a-z]/) {
    warn "Ignoring: $name";
    return "";
  }

  return $name;
}

# memorize the geonameids of ADM0-4 (ADM0 = PCL) so we can store
# geonameids of these values, not the values themselves

sub admpcl {
  # create from allcountries (irks me that I have to go through
  # allCountries.txt, but this appears to be unavoidable)
  unless (-f "/var/tmp/admpcl.txt") {
    system("egrep 'PCL|ADM[1-4]' allCountries.txt 1> /var/tmp/admpcl.txt");
  }

  local(*A);
  local(*C);
  open(A,"/var/tmp/admpcl.txt");
  open(C,">canon.txt");
  while (<A>) {
    my($level);
    # TODO: use my() here correctly with $admin
    ($geonameid, $name, $asciiname, $alternatenames, $latitude, $longitude,
       $featureclass, $featurecode, $admin[0], $cc2, $admin[1],
       $admin[2], $admin[3], $admin[4], $population, $elevation,
       $gtopo30, $timezone, $modificationdate) = split("\t",$_);
    # is this an ADM or PCL (if not, ignore)
    if ($featurecode=~/^ADM([1-4])$/) {
      $level = $1;
    } elsif ($featurecode=~/^PCL[FIDS]?X?$/) {
      $level = 0;
    } else {
      next;
    }

    # if I'm an ADMx but my ADMx value is empty, ignore
    if (length($admin[$level]) == 0) {next;}
    # if it's already my geonameid, also ignore
    if ($admin[$level] == $geonameid) {next;}

    # all other cases print my "full" ADMx value
    my($full) = join(".",@admin[0..$level]);
    print C "$level $geonameid $full\n";
  }
}

