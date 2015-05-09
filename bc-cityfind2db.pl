#!/bin/perl

# Converts the output of bc-cityfind.pl into a CSV (trivial script I
# just happen to need)

require "/usr/local/lib/bclib.pl";

my(@order) = split(/\,/,"city,state,country,latitude,longitude");
my(%hash,@print);

my($data,$file) = cmdfile();

while ($data=~s%<response>(.*?)</response>%%s) {
  my($city) = $1;

  while ($city=~s%<(.*?)>(.*?)</\1>%%) {
    my($key,$val) = ($1,$2);
    # ugly hack because this is CSV
    $val=~s/\,//g;
    $hash{$key}=$val;
  }

  @print = @order;
  map($_=$hash{$_},@print);
  print join(",",@print),"\n";
}

=item db

To create a db from the output of this:

CREATE TABLE places (city TEXT, state TEXT, country TEXT, latitude
DOUBLE, longitude DOUBLE);

.separator ","
.import output-of-this places

=cut


