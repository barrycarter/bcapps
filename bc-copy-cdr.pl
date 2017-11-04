#!/bin/perl

# starts off as copy of bc-copy-dvd.pl

# attempts to canonically copy back CDR(W)s to which I offloaded data
# many years ago (since I now have more space on my main drives)

# --repeat: ok if directory already exists, rsync anyway

require "/usr/local/lib/bclib.pl";

# always spit out an xmessage when done
defaults("xmessage=1");

# root only
if ($>) {die("Must be root");}

my($out, $err, $res);

# if it returns non-0, badness has happened
unless (mount_drive("/dev/cdrom", "/mnt/cdrom")) {die "Mount failure";}

# it's not actually to mount the CDR(W) for this to work, but if I
# can't mount it, there's no point in reading this info

# the bytes 32960 - 32960+8192 contain identifying information-- in
# this case, the burn date of the CDR(W) which I have indexed

# <h>The first part of the read returns "MKISOFS ISO 9660/HFS
# FILESYSTEM BUILDER & CDRECORD CD-R/DVD CREATOR (C) 1993 E.YOUNGDALE
# (C) 1997 J.PEARSON/J.SCHILLING", which is fairly useless</h>

# code below copy/pasted from much older program, may look strange

my($val);
my($device) = "/dev/cdrom";

open(A,$device)||die("Can't open device $device, $!");
seek(A,32960,0);
$ret=read(A,$val,8192);
close(A)||die("Can't close device $device, $!");
unless ($ret == 8192) {die("Didn't read 8192 bytes, dying");}

debug("MOUNT SUCCESSFUL, data is: $val");

# read the value - at least 5 numbers
$val=~/(\d{5,})/;
$date=$1;

# read the metadata in the file corresponding to burn date
my($etcdir) = "/usr/local/etc/CDRinfo/";
$all=suck("$etcdir/$date.dat")||die("Couldn't find $etcdir/$date.dat");

debug("ALL: $all");

# all we need here is the cd number, though more info is stored
unless ($all=~s%<cdrmnt>(\d+)</cdrmnt>%%) {die "Can't find CD#";}
my($num) = $1;

# if dir is empty, delete it
# TODO: better check for non-empty directory?
($out, $err, $res) = cache_command2("rmdir /CDR/$num");

# if directory exists (and wasn't deleted by above), abort
if (-d "/CDR/$num" && !$globopts{repeat}) {
  die "Non-empty directory /CDR/$num already exists";
}

# now all good, create directory, rsync, eject

($out, $err, $res) = cache_command2("mkdir /CDR/$num");
debug("ABOUT TO START RSYNC at". `date`);

# time out after 10m
alarm(600);

$SIG{ALRM} = sub {die "Taking too long, 10m"};

# expect $out and $err to be empty, since I am redirecting
($out, $err, $res) = cache_command2("rsync -Pavz /mnt/cdrom/ /CDR/$num/ 1> /CDR/$num.out 2> /CDR/$num.err");

if ($res) {die "RSYNC failed: $err";}

# NOTE: don't really need to use cache_command2 for most of these
# all good, eject
($out, $err, $res) = cache_command2("eject");

# TODO: consider making this a general function

# mount_drive($dev, $pt): attempt to mount $dev on $pt with some extra checks
# 1 for success, 0 for fail

sub mount_drive {
  my($dev, $pt) = @_;
  my($out, $err, $res);

  # if already mounted, we are good
  # TODO: in theory, could be mounted, but wrong device
  ($out, $err, $res) = cache_command2("mountpoint $pt");
  debug("OUT: $out, ERR: $err, RES: $res");
  if ($res == 0) {return 1;}

  # attempt to mount 10 times
  # NOTE: using cache_command, not cache_command2, to get 'retry' option
  ($out, $err, $res) = cache_command("mount $dev $pt", "retry=10&sleep=1&nocache=1");

  # is NOW a mountpoint?
  ($out, $err, $res) = cache_command2("mountpoint $pt");

  if ($res == 0) {return 1;}

  return 0;
}
