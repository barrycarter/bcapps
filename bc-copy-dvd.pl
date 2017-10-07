#!/bin/perl

# attempts to canonically copy a 'backup DVD' (a DVD where I offloaded
# files when space was tight) back to hard drive now that I have
# plenty of space

require "/usr/local/lib/bclib.pl";

# always spit out an xmessage when done
defaults("xmessage=1");

# root only
if ($>) {die("Must be root");}

my($out, $err, $res);

# if it returns non-0, badness has happened
unless (mount_drive("/dev/cdrom", "/mnt/cdrom")) {die "Mount failure";}

# which disk is it?
my($disk) = find_disk();

# if dir is empty, delete it
# TODO: better check for non-empty directory?
($out, $err, $res) = cache_command2("rmdir /DVD/$disk");

# if directory exists (and wasn't deleted by above), abort
if (-d "/DVD/$disk") {die "Non-empty directory already exists";}

# now all good, create directory, rsync, eject

($out, $err, $res) = cache_command2("mkdir /DVD/$disk");
($out, $err, $res) = cache_command2("rsync -Pavz /mnt/cdrom/ /DVD/$disk/");

if ($res) {die "RSYNC failed: $err";}

# NOTE: don't really need to use cache_command2 for most of these
# all good, eject
($out, $err, $res) = cache_command2("eject");

# program specific subroutine, not general

# return the name of the file in /usr/local/etc/DVDmnt/info/*/* that
# matches this DVD

# TODO: improve code, though this can't possibly benefit anyone else ever

sub find_disk {

  my($out, $err, $res) = cache_command2("find /mnt/cdrom/ -type f");

  # list of files without dirs
  my(@files) = split(/\n/, $out);
  map(s%^.*/%%, @files);

  # randomly select a file and see which DVD(s) it's on
  my($num) = floor(rand()*(scalar(@files)+1));
  my($fname) = $files[$num];

  ($out, $err, $res) = cache_command2(qq%fgrep -l "$fname" /usr/local/etc/DVDmnt/info/*/*%);

  # if there are 0 matches or more than 2, die
  # TODO: if more than 2 matches, could keep grepping until found 1 w all
  my(@res) = split(/\n/, $out);

  unless (scalar(@res) == 1) {die "Number of matches is not exactly 1";}

  $res[0]=~s%^.*/%%;

  return $res[0];
}

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
