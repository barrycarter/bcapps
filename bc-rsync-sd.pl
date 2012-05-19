#!/bin/perl

# One off script that probably helps no one but me: I'm rsyncing to an
# SD card, but write-caching means that "umounting" the card takes
# forever; this program rsyncs a few files at a time so that I can
# take the card and go without losing too much data

# The mount option "-o sync" DOES work, but is painfully even slower

require "/usr/local/lib/bclib.pl";

# rsync source and target from command-line
my($source, $target) = @ARGV;

# device and mount point
my($dev, $dir) = ("/dev/sdb1", "/mnt/usbext/");

# mount device
mount($dev,$dir);

# what would <h>jesus^H^H^H^H^H</h> rsync do?
# remote systems rounds times, thus --modify-window=1
# ignore directories via egrep
($out,$err,$res) = cache_command("rsync --modify-window=1 -Prtn $source $target | egrep -v '/\$'");

debug("OUT: $out");

=item mount($dev, $dir, $umount)

Mount $dev on $dir (or unmount if $umount set), using stat to confirm
the device number matches/doesnt match the root device. Not perfect,
but safer than straight mount/umount

=cut

sub mount {
  my($dev, $dir, $umount) = @_;
  my($res);

  # current state
  my($rootdev) = stat("/");
  my($dirdev) = stat($dir);

  # if requesting mount and devs differ, already ok
  if ($rootdev != $dirdev && !$umount) {return;}

  # if requesting umount and devs same, already ok
  if ($rootdev == $dirdev && $umount) {return;}

  # mount or umount as requested
  if ($umount) {
    $res = system("umount $dir");
  } else {
    $res = system("mount $dev $dir");
  }

  # since we checked whether already mounted, command above should not fail
  if ($res) {die "COMMAND RETURNED: $res";}

  # to be even safer, we call this subroutine again, expecting it to
  # return instantly
  mount($dev,$dir,$umount);
}


