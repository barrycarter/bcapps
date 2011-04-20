#!/bin/perl

# visit URLs for NOAA cycle files and download new ones

push(@INC,"/usr/local/lib");
require "bclib.pl";

# I tend to use up CPU, so renice myself
system("renice 19 -p $$");

defaults("mode=devel&root=/usr/local/etc/cycle");

# different options depending on mode
# THOUGHT: should this be in bclib?
if ($globopts{mode} eq "prod") {
  # never cache or debug in production
  $globopts{nocache}=1;
  $globopts{debug}=0;
} elsif ($globopts{mode} eq "devel") {
  # debug in devel
  $globopts{debug}=1;
} else {
  die "MODE required";
}

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
  dodie(qq%chdir("$globopts{root}/$type/")%);

  # download directory of files (cache if in development)
  cache_command("curl -R -m 300 -s -o files.txt $i","age=300");

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
    push(@commands, "curl -R -m 300 -s -o $globopts{root}/$type/$file $i/$file");
  }
}

# run commands using gnu parallel

$commands = join("\n",@commands);
write_file($commands, "commands");
# ARGH: new version of parallel defaults to "-j 1"
($out, $err, $stat) = cache_command("parallel -j 20 < commands");

# TODO: run repeatedly (vs cron)
