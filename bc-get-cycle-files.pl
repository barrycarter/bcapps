#!/bin/perl

# 23 Sep 2011: daemonizing
# visit URLs for NOAA cycle files and download new ones

push(@INC,"/usr/local/lib");
require "bclib.pl";
require "bc-weather-lib.pl";
use XML::Simple;

# load METAR/SYNOP location data (only once per run)
@res = sqlite3hashlist("SELECT * FROM stations","db/stations.db");

for $i (@res) {
  %hash = %{$i};
  # set lat/lon for METAR name
  $lat{$hash{metar}} = $hash{latitude};
  $lon{$hash{metar}} = $hash{longitude};
  # and synop station
  $lat{$hash{wmob}*1000+$hash{wmos}} = $hash{latitude};
  $lon{$hash{wmob}*1000+$hash{wmos}} = $hash{longitude};
}

# fields that weather.db has (could also use sqlitecols, hmmm)
# timestamp intentionally not included since it's auto-filled
@fields = ("type", "id", "latitude", "longitude", "cloudcover", "temperature",
"dewpoint", "pressure", "time", "winddir", "windspeed", "gust", "observation",
"comment");

$root = "/usr/local/etc/cycle";

$now = time();

# the URLs and what programs to run after downloading new files
# (currently, just downloads and does nothing)
%urls = (
"http://weather.noaa.gov/pub/SL.us008001/DF.an/DC.sflnd/DS.synop/" => "",
"http://weather.noaa.gov/pub/SL.us008001/DF.an/DC.sflnd/DS.metar/" => "",
"http://weather.noaa.gov/pub/SL.us008001/DF.an/DC.sfmar/DS.dbuoy/" => "",
"http://weather.noaa.gov/pub/SL.us008001/DF.an/DC.sfmar/DS.ships/" => ""
);

# download the directories for all urls
for $i (sort keys %urls) {

  # what type of data are we getting (look at URL to figure out)
  $i=~m%\.([a-z]{5})/?$%||die("URL: bad format");
  $type=uc($1);

  # these directories must already exist
  dodie(qq%chdir("$root/$type/")%);

  # download directory of files
  cache_command("curl -R -m 300 -s -o files.txt $i");

  # look at files.txt to see which cycle files we need
  $list = read_file("files.txt");
  @cycles = ($list=~m%>(sn\.\d+\.txt.*$)%mg);

  # clean it up a bit
  map {s/<[^>]*?>//; s/\s+/ /g;} @cycles;

  for $j (@cycles) {
    ($file, $date, $time, $size) = split(/\s+/,$j);

    # check local date/time
    ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$sizefile,
     $atime,$mtime,$ctime,$blksize,$blocks) = stat($file);
    $loctime = $mtime;

    # and remote time
    $remtime = str2time("$date $time UTC");

    # if I already have a newer copy, ignore
    if ($loctime >= $remtime) {next;}

    # if server copy is too old, ignore it (this program runs as a
    # daemon and shouldn't load old data on startup)
    if ($remtime <= $now-3600) {next;}

    # TODO: maybe compare $sizefile and $size just in case we get
    # bogus file from NOAA

    # The cycle file I have is stale, so get fresh copy
    push(@commands, "curl -R -m 300 -s -o $root/$type/$file $i/$file");
    # keep track of the file I'm downloading; I'll need it for parse-metar
    push(@files, "$root/$type/$file");
  }
}

# chdir back to root
chdir($root);

# run commands using gnu parallel
$commands = join("\n",@commands);
write_file($commands, "commands");
($out, $err, $stat) = cache_command("parallel -j 20 < commands");

# go through files
for $i (@files) {
  debug("I: $i");

  # what type (not sure why I get the double slash sometimes)
  $i=~/\/([^\/]*?)\/sn\.\d+\.txt$/;
  my($type) =  lc($1);
  debug("TYPE: $type");

  # handle
  if ($type eq "metar") {
    system("metafsrc2raw.pl -Fmetaf_nws $i|metaf2xml.pl -x output.xml");
  } elsif ($type eq "ships") {
    system("metafsrc2raw.pl -Fsynop_nws $i|metaf2xml.pl -TSYNOP -x output.xml");
  } elsif ($type eq "dbuoy") {
    system("metafsrc2raw.pl -Fbuoy_nws $i|metaf2xml.pl -TBUOY -x output.xml");

  } elsif ($type eq "synop") {
    system("metafsrc2raw.pl -Fsynop_nws $i|metaf2xml.pl -TSYNOP -x output.xml");
  } else {
    warnlocal("Can't handle: $type");
  }

  # data is now in output.xml regardless of original type
  # convert to hash
  $xml = new XML::Simple;
  $data = $xml->XMLin("output.xml");
  %data = %{$data};

  # HACK: this is cheating: I already know the type, but it's easier
  # to do it this way
  for $i ("metar", "synop", "buoy") {
    @reports = @{$data{reports}{$i}};
    if ($#reports>-1) {last;}
  }

  # create hash for each report
  @hashes = ();
  for $i (@reports) {
    # TODO: is the below just weather_hash($i)?
    %hash = %{$i};
    %ret = weather_hash(\%hash);
    push(@hashes, {%ret});
  }

  # add to db (as transaction)
  @queries = hashlist2sqlite(\@hashes, "weather");
  unshift(@queries, "BEGIN");
  push(@queries, "COMMIT");
  write_file(join(";\n",@queries).";\n", "queries.txt");
  system("sqlite3 weather.db < queries.txt");
}

die "TESTING";

# rsync (uses private key)
system("rsync ../weather.db root\@barrycarter.info:/sites/DB/weather.db.new");
system("ssh root\@barrycarter.info 'cd /sites/DB; mv weather.db weather.db.old; mv weather.db.new weather.db'");

warn "TESTING";
print "HIT RETURN WHEN READY\n";
<STDIN>;

# TODO: use entire command line, not just $0
sleep(10);
exec("$0 --debug");
