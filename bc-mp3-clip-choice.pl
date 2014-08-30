#!/bin/perl

# Plays 15s clips in /home/barrycarter/MP3/GAME/ and lets me annotate
# them (literally put the filename and tag into a file) with any text,
# but the following strings have special meanings:

# y - the clip is good for a guessing game, does not contain song title
# cs - the clip contains the song title at the start, clipping may help
# ce - the clip contains the song title at the end, clipping may help
# n - the clip is unacceptable for a guessing game

require "/usr/local/lib/bclib.pl";
use Fcntl;
chdir("/home/barrycarter/MP3/GAME");

# STDIN needs to be interactive
fcntl(STDIN,F_SETFL,O_NONBLOCK);

# in random order
@mp3s = randomize([glob("*.mp3")]);

# the annotations file
open(A,">>/home/barrycarter/20140828/annos.txt");

for $i (@mp3s) {
  system("pkill mplayer; mplayer -really-quiet -af scaletempo,volnorm -speed 1.5 file \"$i\" < /dev/null >& /dev/null & sleep 1");

  # wait for keypress (nonblocking)
  do {$input = <STDIN>;} until $input;
  chomp($input);

  print A "$input $i\n";
}
