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

sub find_disk {

  my($out, $err, $res) = cache_command2("find /mnt/cdrom/ -type f");

  # list of files without dirs
  my(@files) = split(/\n/, $out);
  map(s%^.*/%%, @files);

  # randomly select a file and see which DVD(s) it's on
  my($num) = floor(rand()*(scalar(@files)+1));
  debug("Chose $num of $#files+1");


  debug("FILES", @files);

#  debug("OUT: $out");

}


