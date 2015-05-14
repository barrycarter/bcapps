#!/bin/perl

# This script converts the geonames files at:
# http://download.geonames.org/export/dump/
# into an SQLite3 db (result: http://geonames.db.94y.info)

# --nodep: don't check for file dependencies (useful when testing)

# Improvements 28 Sep 2013:
# latitude/longitude no longer mangled
# add ids to altnames table

# TODO: this entire code seems really ugly

use utf8;
use Text::Unidecode;
use Math::Round;
require "/usr/local/lib/bclib.pl";

# check that all needed files are present
for $i ("allCountries.txt", "alternateNames.txt") {
  if ($globopts{nodep}) {next;}
  unless (-f $i) {die "$i not here (unzip?)";}
}

open(A,"alternateNames.txt");
open(B,">altnames1.tsv");

while (<A>) {
  chomp($_);
  s/\"//isg;

  if ($lines++%100000==0) {debug("$lines LINES");}

  my(@fields) = split("\t", $_);

  # ignore links (get mangled too badly by "cleanup" and not useful)
  if ($fields[2] eq "link") {next;}

  # sqlite requires EXACTLY 8 fields per line
  for $j (0..7) {unless ($fields[$j]) {$fields[$j]="";}}

  # $fields[3] is the alternatename, and the only one we must cleanup
  $fields[3] = cleanup($fields[3]);

  print B join("\t",@fields)."\n";
}

close(A);
close(B);

# create canon.txt
unless (-f "canon.txt") {admpcl();}

# load the canon.txt hash
for $i (split("\n",read_file("canon.txt"))) {
#  debug("I: $i");
  unless ($i=~m%^(\d)\s+(\d+)\s+(.*?)$%) {die "BAD LINE: $i";}
  $canon{$1}{$3} = $2;
}

open(A,"allCountries.txt");
open(C,">geonames.tsv");
open(B,">altnames0.tsv");

while (<A>) {
  chomp($_);
  s/\"//isg;

  if ($lines++%100000==0) {debug("$lines LINES");}
#  if ($lines >= 100000) {warn "TESTING"; last;}

  @admin = ();
  ($geonameid, $name, $asciiname, $alternatenames, $latitude, $longitude,
   $featureclass, $featurecode, $admin[0], $cc2, $admin[1],
   $admin[2], $admin[3], $admin[4], $population, $elevation,
   $gtopo30, $timezone, $modificationdate) = split("\t",$_);

  # ASCII name written ONLY to altnames, geonames will no longer have ANY names
  # the artificial altnameid is -1*geonameid
  print B join("\t",(-1*$geonameid,$geonameid,"orig",$asciiname,0,0,0,0))."\n";

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

  print C join("\t", $geonameid, $latitude, $longitude,
  $featurecode, $admin[0], $admin[4], $admin[3], $admin[2],
  $admin[1], $admintest, $population, $timezone, $elevation)."\n";
}

close(A);
close(B);
close(C);

# unidecode the way I want it
sub cleanup {
  my($name) = @_;

  debug("GOT: $name");

  # unidecode the whole thing first, lower case, despace
  $name = lc(unidecode($name));
  debug("BETA: $name");

  # "county" is a designation, not a name
  $name=~s/\s+county$//isg;
  debug("GAMMA: $name");

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
