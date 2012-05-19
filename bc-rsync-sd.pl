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

# is device mounted? (this is a very kludgey way to check, but 'mount'
# sometimes gives me bad answers, not sure why
($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$sizefile, $atime,$mtime,$ctime,$blksize,$blocks) = stat("/");
$rootdev = $dev;
($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$sizefile, $atime,$mtime,$ctime,$blksize,$blocks) = stat($dir);
$dirdev = $dev;

debug("$dirdev vs $rootdev");

die "TESTING";



# start out by unmounting
$res = system("sudo umount $dev")>>8;
debug("RES: $res");
die "TESTING";
$res = system("sudo mount $dev $dir")>>8;
die "TESTING";

# what would <h>jesus^H^H^H^H^H</h> rsync do?
# remote systems rounds times, thus --modify-window=1
# ignore directories via egrep
($out,$err,$res) = cache_command("rsync --modify-window=1 -Prtn $source $target | egrep -v '/$'");

debug("OUT: $out");

=item mount($dev, $dir, $umount)

Mount $dev on $dir (or unmount if $umount set), using stat to confirm
the device number matches/doesn't match the root device. Not perfect,
but safer than straight mount/umount

=cut

sub mount {
  my($dev, $dir, $umount) = @_;
}


