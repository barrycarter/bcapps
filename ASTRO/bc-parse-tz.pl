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
  debug("NAME: $name");
}
