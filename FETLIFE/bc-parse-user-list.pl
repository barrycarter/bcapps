#!/bin/perl

# Parses a list of files, each containing a list of users (note that
# the filenames themselves contain information)
# Sample file: https://fetlife.com/countries/233/kinksters?page=3

require "/usr/local/lib/bclib.pl";

# order in which to print per-user fields
my(@fields) = ("id", "screenname", "age", "gender", "role", "city", "state",
	       "country", "thumbnail", "popnum", "popnumtotal", "source",
	       "jloc", "mtime");
my($fields) = join(", ",@fields);

# using xargs, this means there will be "several" BEGIN/COMMIT blocks,
# but I'm OK with that

# NOTE: using BEGIN below WILL NOT WORK since MySQL autocommit is
# still on; must use "START TRANSACTION":
# https://dev.mysql.com/doc/refman/5.0/en/commit.html

for $i (@ARGV) {

  unless (-f $i) {warn("NO SUCH FILE: $i"); next;}

  # below is faster than cache_command2 (?) and doesn't clutter /var/tmp/
  my($all) = join("",`bzcat -f $i`);
  my($mtime) = (stat($i))[9];

  # find out how many of how many we are showing (do this first to avoid errs)
  $all=~s/showing\s*([\d,]+)\s*\-\s*([\d,]+)\s*of\s*([\d\,]+)//is||warn("ERR: $i: NO PAGE INFO");
  my(@pagedata) = ($1,$2,$3);
  map(s/\,//g, @pagedata);
  # if showing x to y of z and x>z, we are on empty page
  if ($pagedata[0]>$pagedata[2]) {debug("No data"); next;}
  # this is uglier than looking up page# but works for all pages(?)
  my($pagenum) = ceil($pagedata[0]/20);

  # find URL of this page (indirectly)
  $all=~s%<a href="([^>]*?)">return to [^<]*?</a>%%is||warn("NO UPPAGE: $i");
  my($source) = "fetlife.com$1/kinksters?page=$pagenum";
  # country name
  $all=~s%<title>Kinksters in (.*?) \- FetLife</title>%%is||warn("ERR: $i: NO COUNTRY DATA");
  my($country) = clean_country($1);

  # users
  while ($all=~s%<div class="clearfix user_in_list">(.*?)</div>\s*</div>%%is) {

    # parse user
    my($user) = $1;
    my(%hash);

    # last 3 are somewhat redundant
    $hash{popnum} = $pagedata[0]++;
    $hash{popnumtotal} = $pagedata[2];
    $hash{mtime} = $mtime;
    # TODO: source still not working for some pages
    $hash{source} = "https://$source";

    $user=~s%href=\"/users/(\d+)\".*alt=\"(.*?)\".*src=\"(.*?)\"%%||warn("ERR: $i: no id/screenname/thumbnail");
    ($hash{id},$hash{screenname},$hash{thumbnail}) = ($1,$2,$3);

    $user=~s%<span class="quiet">(.*?)</span>%%s||warn("ERR: $user: no age/gender/role");
    ($hash{age},$hash{gender},$hash{role}) = data2agr($1);

    $user=~s%<em class="small">(.*?)</em>%%s||warn("ERR: $i: no city/state");
    ($hash{city},$hash{state},$hash{country}) = loc2csc($1,$country);

    # string to join to locations db, once I create it
    # TODO: this is ugly!
    $hash{jloc} = lc(join(".", $hash{city},$hash{state},$hash{country}));
    $hash{jloc}=~s/[^a-z]/./ig;
    $hash{jloc}=~s/^\.+//;
    $hash{jloc}=~s/\.+$//;
    $hash{jloc}=~s/\.+/./g;

    my($vals) = join(",",map($hash{$_},@fields));
    print $vals,"\n";
  }

  # -1 to compensate for extra unused increment at last user
  unless ($pagedata[0]-1 == $pagedata[1]) {warn "$i: lost users";}
}

# parses data into age, gender, role

sub data2agr {
  if ($_[0]=~m%(\d+)([A-Za-z/]*)\s*(.*)$%) {return ($1,$2,$3);}
  warn ("BAD DATA: $_[0]");
}

sub loc2csc {
  my($loc,$country) = @_;

  # TODO: review special cases, some can be removed
  # special cases
  $loc=~s/NoMa, Washington, D\.C\., District of Columbia/NoMa Washington D.C., District of Columbia/;
  $loc=~s/, Arkansas, Arkansas/, Arkansas/;
  # intentionally no space between comma and Nebraska below
  $loc=~s/,Nebraska, Nebraska/, Nebraska/;
  $loc=~s/, Missouri\/Kickapoo, Missouri/, Missouri/;
  $loc=~s/, (city of|the|Republic of),/,/is;

  # TODO: review this; think its correct because $loc may have no commas
  my(@data)=(split(/\,\s*/, $loc));
  $data[2] = $country;

  # leftover commas must be removed
  for $i (@data) {$i=~s/,//g;}

  # if city/state and country are same, null them
  for $i (0,1) {if ($data[$i] eq $data[2]) {$data[$i]="";}}
  return @data;
}

sub clean_country {
  my($country) = @_;

  # hex badness
  $country=~s/\xc3\xb4/o/g;
  $country=~s/\xc3\xa9/e/g;

  # apostrophes (not allowed)
  $country=~s/\&\#x27\;//g;

  # unnecessarily long titles
  $country=~s/, (Republic of|Islamic Republic of|United Republic of|the Former Yugoslav Republic of|Federated States of|the Democratic Republic of the|Democratic Peoples Republic of)//;

  # parentheses
  $country=~s/\((.*?)\)//g;

  # one offs
  $country=~s/Brunei Darussalam/Brunei/;
  $country=~s/\s+Peoples Democratic Republic//;
  $country=~s/Libyan Arab Jamahiriya/Libya/;
  $country=~s/Palestinian Territory, Occupied/Palestine/;
  $country=~s/Virgin Islands, (.*?)$/$1 Virgin Islands/;

  # multispaces
  $country=~s/\s+/ /g;
  $country=~s/\s+$//g;

  return $country;
}
