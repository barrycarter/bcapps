#!/bin/perl

# 23 Sep 2011: daemonizing
# visit URLs for NOAA cycle files and download new ones

push(@INC,"/usr/local/lib");
require "bclib.pl";
require "bc-weather-lib.pl";

# fields that weather.db has (could also use sqlitecols, hmmm)
# timestamp intentionally not included since it's auto-filled
@fields = ("type", "id", "latitude", "longitude", "cloudcover", "temperature",
"dewpoint", "pressure", "time", "winddir", "windspeed", "gust", "observation",
"comment");

$root = "/usr/local/etc/cycle";


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

    # TODO: maybe compare $sizefile and $size just in case we get
    # bogus file from NOAA

    # cycle files are created no less than 1m apart, so 2h is very
    # safe here
    if (abs($loctime-$remtime) <= 2*3600) {next;}

    # The cycle file I have is stale, so get fresh copy
    push(@commands, "curl -R -m 300 -s -o $root/$type/$file $i/$file");
    # keep track of the file I'm downloading; I'll need it for parse-metar
    push(@files, "$root/$type/$file");
  }
}

# run commands using gnu parallel
$commands = join("\n",@commands);
write_file($commands, "commands");
($out, $err, $stat) = cache_command("parallel -j 20 < commands");

warn "TESTING";
# @files = ("/usr/local/etc/cycle/SYNOP/sn.0029.txt",
#	  "/usr/local/etc/cycle/DBUOY/sn.0198.txt",
#	  "/usr/local/etc/cycle/SHIPS/sn.0081.txt",
#	  "/usr/local/etc/cycle/METAR/sn.0199.txt"
#	  );

@files = ("/usr/local/etc/cycle/DBUOY/sn.0197.txt");

# go through files

for $i (@files) {
  debug("I: $i");

  # what type (not sure why I get the double slash sometimes)
  $i=~/\/([^\/]*?)\/sn\.\d+\.txt$/;
  my($type) =  lc($1);
  debug("TYPE: $type");

  # handle
  if ($type eq "metar") {
    handle_metar($i);
  } elsif ($type eq "ships") {
    handle_ship($i);
  } elsif ($type eq "dbuoy") {
    handle_buoy($i);
  } elsif ($type eq "synop") {
    debug("Not currently handling SYNOP");
  } else {
    warnlocal("Can't handle: $type");
  }
}

# rsync (uses private key)
system("rsync ../weather.db root\@barrycarter.info:/sites/DB/weather.db.new");
system("ssh root\@barrycarter.info 'cd /sites/DB; mv weather.db weather.db.old; mv weather.db.new weather.db'");

warn "TESTING";
print "HIT RETURN WHEN READY\n";
<STDIN>;

# TODO: use entire command line, not just $0
sleep(10);
exec("$0 --debug");

# note: all routines below hardcode, which is ok, since they're not
# intended to be general

# thin wrapper around parse_metar
sub handle_metar {
  my($file) = @_;
  debug("HANDLE_METAR($file)");
  my($data) = read_file($file);

  for $i (split(/\n/, $data)) {
    # ignore empty, comments, NIL=
    if ($i=~/\#|^\s*$|^\s*NIL\=$/) {next;}
    $i=~s/^(METAR|SPECI)\s*//isg;
    push(@queries, hash2query(parse_metar($i)));
  }

  transact(@queries);
}

# trivial wrapper around parse_ship
sub handle_ship {
  my($file) = @_;
  debug("HANDLE_SHIP($file)");
  my($data) = read_file($file);
  my(@queries);
  while ($data=~s/BBXX\s*(.*?)\s*\=//s) {
    $i = $1;
    $i=~s/\s+/ /isg;
    push(@queries, hash2query(parse_ship($i)));
  }

  transact(@queries);
}

sub handle_buoy {
  my($file) = @_;
  debug("HANDLE_BUOY($file)");
  my($data) = read_file($file);
  my(@queries);
  while ($data=~s/ZZYY\s*(.*?)\s*\=//s) {
    $i = $1;
    $i=~s/\s+/ /isg;
    push(@queries, hash2query(parse_buoy($i)));
  }

  transact(@queries);
}

# below not yet used
sub handle_synop {}

# convert hash to query (trivial)
sub hash2query {
  my(%hash) = @_;
  my(@vals);
 
  for $i (@fields) {push(@vals, "'$hash{$i}'");}

  my($keys) = join(", ", @fields);
  my($vals) = join(", ", @vals);

  return "REPLACE INTO weather ($keys) VALUES ($vals)",
    "REPLACE INTO nowweather ($keys) VALUES ($vals)";
}

# send bunch of queries to weather.db in transaction
sub transact {
  my(@queries) = @_;
  unshift(@queries, "BEGIN");
  push(@queries, "COMMIT");
  my($now) = stardate(time()).$$;
  write_file(join(";\n",@queries).";\n", "../commands.$now");
  system("sqlite3 ../weather.db < ../commands.$now 1> ../$now.out 2> ../$now.err");
}
