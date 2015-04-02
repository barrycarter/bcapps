#!/bin/perl

# parses data obtained from tcpflow'ing bc-bernco-prop-dl.pl

require "/usr/local/lib/bclib.pl";

my($all) = read_file("packets.txt");

# string that separates records
$str = "address are updated weekly through September 2014";

# remove garbage above first record
$all=~s/^.*?$str//s;

# grab data chunks

my(%data);

while ($all=~s/(.*?)$str//s) {
  $count++;
  my($data) = $1;

  # th/td style data
  while ($data=~s%<th>(.*?)</th>.*?<td>(.*?)</td>%%s) {
    my($key,$val) = ($1,$2);
    # key: no spaces, all lc
    $key=~s/\s//g;
    $key=~s/://g;
    $key = lc($key);
    # cleanup val
    $val = trim($val);
    $val=~s/\s+/ /g;
    $data{$count}{$key} = $val;
  }

  $data{$count}{mailingaddress}=~s%\s*<br/>\s*%, %g;

  $data=~s%<div class="caption">\s*Location Address\s*</div>\s*<table class="form">\s*<tr>\s*<td>\s*(.*?)\s*</td>%%;
  my($addr) = $1;
  $addr=~s/\s+/ /g;
  $data{$count}{addr}=trim($addr);

  # this is just for testing purposes (seeing what other data is really there)
#  $data=~s%<script.*?>.*?</script>%%;
#  $data=~s/<.*?>//sg;
#  $data=~s/ +/ /sg;
#  $data=~s/\r/\n/sg;
#  $data=~s/\s*\n+\s*/\n/sg;

#  debug("LEFTOVER: $data");

#  die "TESTING";

}

for $i (sort {$data{$a}{addr} cmp $data{$b}{addr}} keys %data) {
  # only need first 4 chars of addr for my purposes
  my($addr) = substr($data{$i}{addr},0,4);

  print "$addr\t$data{$i}{owner1}\t\t$data{$i}{mailingaddress}\n";
}

