#!/bin/perl

# Another program really just for me: play MP3s in random order from
# the command line, but letting me skip and unskip songs; also, play
# songs at my preferred speed (= faster than normal)

require "/usr/local/lib/bclib.pl";
use Fcntl;

# this is probably bad, but useful to catch garbage from other
# invokations this program
system("pkill mplayer");

# STDIN needs to be interactive
fcntl(STDIN,F_SETFL,O_NONBLOCK);

# I keep these on a different machine using sshfs (list changes infrequently)
my($out, $err, $res) = cache_command("ls /mnt/sshfs/MP3/*.mp3 | sort -R", "age=86400");
@mp3s = split(/\n/, $out);
$pos = 0; # starting position in file

# loop forever
for (;;) {
  # play current song
  debug("PLAYING: $mp3s[$pos]");
  system("mplayer -really-quiet -af scaletempo,volnorm -speed 1.5 file \"$mp3s[$pos]\" < /dev/null &");
  # give pgrep enough time to see this proc (w/o it, 2 songs play at once sometimes)
  sleep(1);

  # wait for song to end
  # TODO: this is ugly and catches other mplayer processes
  while (system("pgrep mplayer > /dev/null")==0) {
    $input = <>;
    if ($input) {debug("INPUT: $input");}
    sleep(1);
  }

  $pos++;
#  debug("RES: $res");
#  die "TESTING";
#  debug("WAITING...");
#  sleep(1);
}

# debug(@mp3s);

# NOTES: mplayer -af scaletempo -speed 1.5 file
# mplayer -really-quiet -af scaletempo -speed 1.5 file /mnt/sshfs/MP3/file.mp3 < /dev/null &

