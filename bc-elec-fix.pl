#!/bin/perl

# I use vlc's "snapshot" feature to take snapshots of my electric
# meter; however, VLC gives them stupid names like "elec45901.png"
# instead of naming them by timestamp (there is a setting on VLC to
# use timestamps, but it doesn't apply to this type of snapshot,
# sigh); this program fixes that oversight, using file mtime

require "/usr/local/lib/bclib.pl";
$maindir = "/mnt/sshfs/ELEC2013-VLC";

# if this directory doesn't exist, die
unless (-d $maindir) {die "$maindir DOES NOT EXIST";}

# start/shutdown VLC/elecstart based on time of day
my($out,$err,$res) = cache_command2("pgrep vlc");
if ($out) {$vlc=1;}
($out,$err,$res) = cache_command2("pgrep somagic-capture");
if ($out) {$som=1;}
my(%sm) = sunmooninfo(-106.651138463684,35.0844869067959);
debug(unfold(%sm));

debug("VLC: $vlc, SOM: $som, ALT: $sm{sun}{alt}");

# if sun is down, terminate vlc and somagic-capture if both running
# changed to civil twilight, in part to avoid the 5m delay
if ($sm{sun}{alt}<=-6 && $vlc && $som) {
  debug("Dark, killing VLC/SOMAGIC");
  # NOTE: this will kill any VLC I'm watching once, but I'm OK with that
  system("sudo pkill -9 vlc");
  system("sudo pkill -9 somagic-capture");
}

# if sun is up, start vlc/somagic-capture if needed
if ($sm{sun}{alt}>-6 && (!$vlc || !$som)) {
  debug("Not dark, starting VLC/SOMAGIC");
  # this is the elecstart alias
  system("sudo pkill -9 vlc; sudo pkill -9 somagic-capture; sudo /bin/nice -n 19 somagic-capture | /bin/nice -n 19 vlc --config /home/barrycarter/.config/vlc/vlcrc-elecstart --demux rawvideo --rawvid-fps 15 --rawvid-width 720 --rawvid-height 576 --rawvid-chroma=UYVY file:///dev/stdin &");
}

for $i (glob("$maindir/elec*.png")) {
  my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)=stat($i);
  # if size is 0, something is wrong (but keep processing other files)
  if ($size==0) {$erf=1; next;}
  my($dir) = strftime("$maindir/%Y%m%d",localtime($mtime));
  unless (-d $dir) {system("mkdir $dir");}
  my($file) = strftime("elec%Y%m%d.%H%M%S.png",localtime($mtime));
  system("mv $i $dir/$file");
}

# report error
if ($erf) {$str="0 byte file in $maindir";}
write_file_new($str, "/home/barrycarter/ERR/bcelecfix.err");
