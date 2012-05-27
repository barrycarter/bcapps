#!/bin/perl

# Another program really just for me: play MP3s in random order from
# the command line, but letting me skip and unskip songs; also, play
# songs at my preferred speed (= faster than normal)

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

  debug("PLAYING: $mp3s[$pos] (song $pos+1)");
  # first killing all other mplayer procs == bad?
  # not sure about speaking name first (and, yes, it speaks over first part of song)
  system("pkill mplayer; echo \"$shortsong\" | festival --tts& mplayer -really-quiet -af scaletempo,volnorm -speed 1.5 file \"$song\" < /dev/null &");

  # wait for song to end or keypress
  # pgrep below is ok, because 
  while (system("pgrep mplayer > /dev/null")==0) {
    $input = <>;

    debug("POS BEFORE: $pos");

    # respond to input (and end loop)
    if ($input=~/^p/i) {
      $pos--;
    } elsif ($input) {
      # default case is to advance song if there is any other input
      $pos++;
    } else {
      # do nothing
    }

    debug("POS NOW: $pos");

    # if there was any input, go back to main loop
    if ($input) {last;}

    # otherwise
    sleep(1);
  }
  # if song ends, go to next one
  $pos++;
}

