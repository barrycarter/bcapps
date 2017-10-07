#!/bin/perl

# attempts to canonically copy a 'backup DVD' (a DVD where I offloaded
# files when space was tight) back to hard drive now that I have
# plenty of space

require "/usr/local/lib/bclib.pl";

# always spit out an xmessage when done
defaults("xmessage=1");

# root only
if ($>) {die("Must be root");}

find_disk();

die "TESTING";

# in theory, this should keep trying to mount until success or mass fail
# <h>these are actually DVDs, but I live in the 80s</h>
# NOTE: using cache_command, not cache_command2, to get 'retry' option
my($out, $err, $res) = cache_command("mount /dev/cdrom /mnt/cdrom", "retry=10&sleep=1&nocache=1");

# if mount fails, complain (auto  xmessage by above)
if ($res) {die "Unable to mount: $err";}

debug("MOUNT SUCCESSFUL, continuing");

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



