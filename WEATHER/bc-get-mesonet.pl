#!/bin/perl

# attempts to get data from all active mesonet stations (which
# includes APRSWXNET and RAWS)

require "/usr/local/lib/bclib.pl";

my($url) = "http://mesowest.utah.edu/data/mesowest.out.gz";
my($out,$err,$res) = cache_command2("curl $url | gunzip", "age=150");

# store unzipped results
write_file($out, "/var/tmp/mesowest.out");

# get rid of header lines
$out=~s/^.*?\n(\s*STN)/$1/s;
$out=~s/^\s*/ /sg;
map(push(@res, [split(/\s+/,$_)]), split(/\n/,$out));
debug(var_dump("res0",$res[0]));
debug(var_dump("res1",$res[1]));
($hlref) = arraywheaders2hashlist(\@res);
debug(var_dump("hlref",$hlref));




die "TESTING";

# routine below is too invasive + got me temp blocked
dodie('chdir("/var/tmp/meso")');

# there are about 200 of these, so we parallelize
open(A,"|parallel -j 10");
for $i (1..200) {
  if (-f "mnet-$i.html" && -M "mnet-$i.html" < 1/24.) {next;}
  print A "curl -o mnet-$i.html 'http://mesowest.utah.edu/cgi-bin/droman/station_status_monitor.cgi?order=id&mnet=$i'\n";
}
close(A);

@good = `fgrep -h 'stn=' mnet*.html | fgrep '#33FF66' | sort | uniq`;
# about 20K stations, so get in parallel
open(A,"|parallel -j 10");

for $i (@good) {
  $i=~/stn=(.*?)\"/;
  my($stn) = $1;
  if (-f $stn && -M $stn < 1/24.) {next;}
  print A "curl -o $stn 'http://mesowest.utah.edu/cgi-bin/droman/meso_table_mesowest.cgi?stn=$stn&time=GMT'\n";
}

close(A);

# "fgrep -h 'stn=' mnet*.html | sort | uniq | wc" shows about 40438
# stations, not all active

# "fgrep -h 'stn=' mnet*.html | fgrep -v '#FF' | sort | uniq | wc" shows about 27226 active

# colors:
# #33FF66 [green]
# #FF6666 [red]
# #FFFF66 [yellow]


# http://mesowest.utah.edu/cgi-bin/droman/meso_base.cgi?stn=DPG14&time=GMT
# (Sample url)

# compare to http://raws.wrh.noaa.gov/cgi-bin/roman/raws_flat.cgi?stn=CRVC1 for NOAA




