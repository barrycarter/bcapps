#!/bin/perl

# downloads all gocomics strips (each day) for a given strip

# <h>Pearls Before Swine = test strip, because of my everlasting hatred
# for Steven Pastis!</h>

# NOTE: this is VERY similar to bc-get-peanuts.pl

# one liner to obtain strips 2014-05-02+ (different format) after
# dl'ing page data (pipe to sh or parallel):
# grep src= page-2014-05-* | grep assets\.amuniversal | grep div | fgrep -v 'width=900' | perl -nle 's/^(.*?)://; $date=$1; /src="([^"]*?)" \/>/; $url = $1; print "curl -o $date.gif \47$url?width=1500\47"'

# tweaking the above can also update largeimagelinks.txt

require "/usr/local/lib/bclib.pl";

$strip = "pearlsbeforeswine";
$workdir = "/mnt/extdrive/GOCOMICS/$strip";
dodie("chdir('$workdir')");

for $i (2002..2014) {
  for $j (1..12) {
    # for which days this month are comics available?

    # already have it?
    if (-f "days-for-$i-$j.txt") {next;}

    # gocomics requires a user-agent
    push(@commands,"curl -A 'Arthur Fonzarelli' -o days-for-$i-$j.txt http://www.gocomics.com/calendar/$strip/$i/$j");
  }
}

# if there are any commands to run, do so in parallel

if (@commands) {
  write_file(join("\n",@commands), "runme1.sh");
  system("parallel -j 20 < runme1.sh");
}

# and now, see which days are available

for $i (glob "days-for-*") {
  $all = read_file($i);
  debug("$i: $all");
  # remove brackets and quotes, split into days
  $all=~s/[\[\]\"]//isg;
  push(@days,split(/\,/,$all));
}

# download the days we don't already have
for $i (@days) {
  # the output filename can't include /s so..
  $outfile = "page-$i";
  $outfile=~s%/%-%isg;

  # if outfile exists, skip it
  if (-f $outfile) {next;}

  # if not, we will be downloading it
  push(@commands2, "curl -L -A 'Richie Cunningham' -o $outfile http://www.gocomics.com/$strip/$i")
}

# if any for first batch, run commands to get
if (@commands2) {
  write_file(join("\n",@commands2), "runme2.sh");
  system("parallel -j 20 < runme2.sh");
}

# now, look inside files for image

for $i (glob "page-2[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]") {
  debug("I: $i");

  # if I already have the GIF, ignore
  if (-f "$i.gif") {next;}

  debug("NOGIF: $i");
  $all = read_file($i);

  # look for the image
  while ($all=~s/(<img[^>]*?>)//is) {
    $img = $1;
#    debug("FOUND: $img");

    # look at alt and src
    unless ($img=~/alt="(.*?)"/) {$alt=""; next;}
    $alt = $1;
    unless ($img=~/src="(.*?)"/) {next;}
    $src = $1;

    # unless they match (up to case), continue
    unless (lc($src) eq lc("http://assets.amuniversal.com/$alt")) {next;}

#    debug("ALT: $alt, SRC: $src");

    # slightly different assets server for pearlsbeforeswine
#    unless ($src=~/cdn\.svcs\.c2\.uclick\.com/) {next;}
#    unless ($src=~/^http:..assets\.amuniversal\.com/) {next;}

#    debug("SRC: $src");

    # just to update largeimagelinks.txt
    print "$i $src?width=1500\n";

    # I think all pearlsbeforeswine have a width version (not necessarily 900)
    # the nonwidth version does not zoom properly
#    unless ($src=~s/\?width\=.*$//) {next;}

    # create hash to avoid dupes (yes, the whole command)
    $images{"curl -o $i.gif -A 'gocomics\@barrycarter.info' '$src?width=1500'"} = 1;

  }
}


if (%images) {
  write_file(join("\n",sort keys %images), "runme3.sh");
  # /var/tmp/gocomics is sshfs-mounted, so don't want to run parallel here
  die "TESTING";
  system("parallel -j 20 < runme3.sh");
}










