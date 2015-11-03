#!/bin/perl

# This maps timezones in CLDR's common/supplemental/metaZones.xml file
# to metazones; combined with common/main/en.xml, this provides long
# zone name(s) for each timezone

# CLDR: http://cldr.unicode.org/

require "/usr/local/lib/bclib.pl";

# where I'm keeping CLDR for now
my($cldr) = "/home/barrycarter/20151102";

my(%tz2z, %tz2name);

my($all) = read_file("$cldr/common/supplemental/metaZones.xml");

# TODO: not crazy about assuming header tag format here
while ($all=~s%<timezone type="(.*?)">(.*?)</timezone>%%s) {
  my($name,$data) = ($1,$2);

  # if multiple metazones, use the 'from' one which is most recent
  if ($data=~s%<usesMetazone from=".*?" mzone="(.*?)"/>%%) {
    $tz2z{$name} = $1;
    next;
  }

  # in some cases, order of tags is reversed (which is why I really
  # should be parsing these, not regexing
  if ($data=~s%<usesMetazone mzone="(.*?)" from=".*?"/>%%) {
    $tz2z{$name} = $1;
    next;
  }
    
  # single metazone?
  if ($data=~s%<usesMetazone mzone="(.*?)"/>%%) {
    $tz2z{$name} = $1;
    next;
  }

  # there appear to be three "leftover" zones not currently used
}

# for $i (sort keys %tz2z) {print "$i $tz2z{$i}\n";}

$all = read_file("$cldr/common/main/en.xml");

while ($all=~s%<metazone type="(.*?)">(.*?)</metazone>%%s) {

  my($name,$data) = ($1,$2);

  # more than one of these conditions can be true
  while ($data=~s%<(standard|generic|daylight)>(.*?)</\1>%%s) {
    $tz2name{$name}{$1} = $2;
  }
}

for $i (keys %tz2z) {

  # output format: filename_of_tz standard_name daylight_name generic_name
  # any/all of these might be blank when unknown

  print qq%$i "$tz2name{$tz2z{$i}}{standard}" "$tz2name{$tz2z{$i}}{daylight}" "$tz2name{$tz2z{$i}}{generic}"\n%;
}

# Asia/Urumqi "" "" ""




