#!/bin/perl

# takes a snapshot of my electric meter every minute (via cron),
# storing results in sshfs mounted large drive (large drive is not
# local). Another "useful-only-to-me" script

require "/usr/local/lib/bclib.pl";

# TODO: should not have to hardcode this!
# TODO: convert to jpg, xwd takes up too much space!
$wid = "0x1e00002";

# lock
unless (mylock("bc-elec-snap.pl","lock")) {die("Locked");}

if (run_nagios_test("localhost","sshfs")) {die("sshfs not mounted");}

# file to write to
$file = `/bin/date +%Y%m%d.%H%M%S`;
chomp($file);

# capture 10 frames to /var/tmp/ELEC
system('sudo somagic-capture -f 10 | mplayer -really-quiet -vf screenshot -demuxer rawvideo -rawvideo "format=uyvy:h=576:w=720:fps=25" -ao none -vo "jpeg:outdir=/var/tmp/ELEC/" -');

# upgrading kernel broke xawtv with ov511 devices, so using xwd now
# my($out, $err, $res) = cache_command("xwd -id $wid > /var/tmp/$file.xwd");

# wait for file to exist (slight possibility it has 0 size, but ignoring that for now)

# for (;;) {
#  if (-f "/var/tmp/$file.xwd") {last;}
#  sleep(1);
#  # give up after 300s
#  if (++$n > 300) {die "/var/tmp/$file.xwd does not exist!";}
# }

# break into days, since this many files in a single dir is baddish
$date=$file;
$date=~s/\..*$//isg;
unless (-d "/mnt/sshfs/ELEC2013/$date") {system("mkdir /mnt/sshfs/ELEC2013/$date");}

# rename/move JPEGs
chdir("/var/tmp/ELEC");
for $i (glob "*.jpg") {
  my($cmd) = "mv $i /mnt/sshfs/ELEC2013/$date/$file-$i";
  system($cmd);
}

# system("cp /var/tmp/$file.xwd /mnt/sshfs/ELEC2013/$date/; sudo rm /var/tmp/$file.xwd");

mylock("bc-elec-snap.pl","unlock");
