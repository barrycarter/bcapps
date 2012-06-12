#!/bin/perl

# takes a snapshot of my electric meter every minute (via cron),
# storing results in sshfs mounted large drive (large drive is not
# local). Another "useful-only-to-me" script

require "/usr/local/lib/bclib.pl";

# check that /mnt/sshfs exists and is a mount point
my($out, $err, $res) = cache_command("stat / | grep -i device:");
$out=~m%device: (.*?)\s+%i||die("BAD STAT /");
$devroot = $1;
my($out, $err, $res) = cache_command("stat /mnt/sshfs | grep -i device:");
$out=~m%device: (.*?)\s+%i||die("BAD STAT");
$sshroot = $1;

# same device? the not mounted!
# TODO: this should be a separate nagios test too
if ($devroot eq $sshroot) {die "ssfs not mounted";}

# file to write to
$file = `/bin/date +%Y%m%d.%H%M%S`;
chomp($file);

# and snapshot (I am running xawtv-remote as root but have sshfs
# mounted as myself, requiring the odd cp-rm hack below)
my($out, $err, $res) = cache_command("xawtv-remote snap jpeg win /var/tmp/$file.jpg");

# wait for file to exist (slight possibility it has 0 size, but ignoring that for now)

for (;;) {
  if (-f "/var/tmp/$file.jpg") {last;}
  sleep(1);
  # TODO: maybe give up after n seconds
}

system("cp /var/tmp/$file.jpg /mnt/sshfs/ELEC2012/; sudo rm /var/tmp/$file.jpg");
