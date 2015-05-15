#!/bin/perl

# Parses a list of files, each containing a list of users (because
# filenames contain information per bc-dl-by-region.pl), parse data
# Sample file: https://fetlife.com/countries/233/kinksters?page=3

# giving up on merging this list w/ profile sucking list, so I can use
# more fields

require "/usr/local/lib/bclib.pl";

# order in which to print per-user fields (also used for header)
my(@fields) = ("id", "screenname", "age", "gender", "role", "city", "state",
	       "country", "thumbnail", "popnum", "popnumtotal", "source", "mtime");

print join(",",@fields),"\n";

for $i (@ARGV) {

  unless (-f $i) {
    warn("NO SUCH FILE: $i");
    next;
  }

  # using $_ is probably a bad idea, and my'ing it is maybe worse
  my($_);

  my($mtime) = (stat($i))[9];
  if ($i=~/\.bz2$/) {$_ = join("",`bzcat $i`);}else{$_ = read_file($i);}

  # find URL of this page (indirectly)
  s%<a href="([^>]*?)">return to [^<]*?</a>%%is||warn("NO UPPAGE: $i");
  my($source) = $1;
  # TODO: may not work on last page for given country
  # (actually, think that only applies if page is blank so ok?)
  # temporarily not caring about missing page number due to other error
  s%<em class="current">(\d+)</em>%%||debug("NO PAGE#: $i");
  # TODO: read https
#  $source = "https://fetlife.com$source/kinksters?page=$1";
  $source = "fetlife.com$source/kinksters?page=$1";

  unless (index($i,$source)) {debug("$i vs $source");}

  # how many of how many
  s/showing\s*([\d,]+)\s*\-\s*([\d,]+)\s*of\s*([\d\,]+)//is||warn("ERR: $i: NO PAGE INFO");
  my(@pagedata) = ($1,$2,$3);
  map(s/\,//g, @pagedata);

  # country (maybe) [this is fixed for a given page]
  s%<title>Kinksters in (.*?) \- FetLife</title>%%is||warn("ERR: $i: NO COUNTRY DATA");
  my($country) = $1;
  debug("COUNTRY: $country");

  # users
  while (s%<div class="clearfix user_in_list">(.*?)</div>\s*</div>%%is) {

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

    $user=~s%<span class="quiet">(.*?)</span>%%s||warn("ERR: $i: no age/gender/role");
    ($hash{age},$hash{gender},$hash{role}) = data2agr($1);

    $user=~s%<em class="small">(.*?)</em>%%s||warn("ERR: $i: no city/state");
    ($hash{city},$hash{state},$hash{country}) = loc2csc($1,$country);

    # and print
    my(@print) = @fields; 
    map($_=$hash{$_},@print);

    # hideous hack so that numerical and alphabetic sort are identical
    $print[0] = sprintf("%0.11d", $print[0]);

    # TODO: kill spurious commas, if any
    print join(",",@print),"\n";

#    debug("LEFTOVER: $user");

    next;
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
  $loc=~s/, (Republic of|Islamic Republic of|United Republic of|the Former Yugoslav Republic of|Federated States of|the Democratic Republic of the|Democratic People&\#x27\;s Republic of)$//;

  # TODO: review this; think its correct because $loc may have no commas
  my(@data)=(split(/\,\s*/, $loc));
  $data[2] = $country;

  # leftover commas must be removed
  for $i (@data) {$i=~s/,//g;}

  # if city/state and country are same, null them
  for $i (0,1) {if ($data[$i] eq $data[2]) {$data[$i]="";}}
  return @data;
}
