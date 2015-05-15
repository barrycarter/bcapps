#!/bin/perl

# parsing fetlife user data into subroutine

require "/usr/local/lib/bclib.pl";

# fields from location sucking
# id,screenname,thumbnail,age,gender,role,loc1,loc2,page_number,scrape_time

my(@order)=split(/\,/,"id,screenname,age,gender,role,city,state,country,thumbnail,popnum,popnumtotal,source,mtime");

for $i (@ARGV) {
  my(%res) = fetlife_user_data($i);
  unless ($res{id}) {next;}

  # hack for sorting
  $res{id} = sprintf("%0.11d", $res{id});

  my(@l) = @order;
  map($_=$res{$_},@l);
  print join(",",@l),"\n";
}
