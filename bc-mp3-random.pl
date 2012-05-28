#!/bin/perl

# Another program really just for me: play MP3s in random order from
# the command line, but letting me skip and unskip songs; also, play
# songs at my preferred speed (= faster than normal)

# keypresses (NYI = not yet implemented):
#
# p - previous song
# n or <ENTER> - next song
# q - quit (NYI)
# r - restart program (not useful due to caching?; unless prog itself changes)
# number - play song #number (NYI)
# up/down - increase/reduce volume (using external amixer) (NYI)
# /phrase - search for and play song matching phrase + reset $pos (NYI)
# l - list all songs by number (piped to less?) [restrict by number/phrase?]
# o - do nothing <h>(everyone needs null ops!)</h>

# TODO: would be nice to get some overlap... know when a song's about to end
# TODO: would be nice to have mplayer controls too

require "/usr/local/lib/bclib.pl";
use Fcntl;

# STDIN needs to be interactive
fcntl(STDIN,F_SETFL,O_NONBLOCK);

# I keep these on a different machine using sshfs (list changes infrequently)
my($out, $err, $res) = cache_command("ls /mnt/sshfs/MP3/*.mp3 | sort -R", "age=86400");
@mp3s = split(/\n/, $out);
$pos = 0; # starting position in file

# loop forever
for (;;) {
  # if $pos goes beyond limits, fix
  if ($pos<0) {$pos=$#mp3s;}
  if ($pos>$#mp3s) {$pos=0;}

  # current song
  $song = $mp3s[$pos];
  # short form for festival (remove dir name and extension)
  $shortsong = $song;
  $shortsong=~s%^.*/%%isg;
  $shortsong=~s/\..*$//isg;
  $shortsong=~s/_/ /isg;
  # This changes TongueTied -> Tongue Tied (for example)
  $shortsong=~s/([a-z])([A-Z])/$1 $2/sg;

  debug("PLAYING: $mp3s[$pos] (song $pos+1)");
  # first killing all other mplayer procs == bad?
  # not sure about speaking name first (and, yes, it speaks over first
  # part of song)
  # sleep necessary for pgrep
  system("pkill mplayer; echo \"$shortsong\" | festival --tts& mplayer -really-quiet -af scaletempo,volnorm -speed 1.5 file \"$song\" < /dev/null >& /dev/null & sleep 1");

  # wait for song to end or keypress
  for (;;) {
    # if song end, abort inner loop
    $res = system("pgrep mplayer > /dev/null");
    if ($res) {$pos++; last;}

    # if not, listen for keybord input (nonblocking)
    $input = <>;

    # respond to input
    if ($input=~/^p/i) {
      $pos--;
    } elsif ($input) {
      # default case is to advance song if there is any other input
      $pos++;
    } else {
      # do nothing
    }

    # up arrow/ENTER: 27/91/65
    # down arrow/ENTER: 27/91/66

    # if there was any input, restart loop
    if ($input) {
      chomp($input);
      for $i (split(//,$input)) {
	debug("I: ". ord($i));
      }
      last;
    }

    # otherwise, sleep (to avoid CPU hang)
    sleep(1);
  }
}


