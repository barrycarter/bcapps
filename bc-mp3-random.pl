#!/bin/perl

# Another program really just for me: play MP3s in random order from
# the command line, but letting me skip and unskip songs; also, play
# songs at my preferred speed (= faster than normal)

require "/usr/local/lib/bclib.pl";

# I keep these on a different machine using sshfs (list changes infrequently)
my($out, $err, $res) = cache_command("ls /mnt/sshfs/MP3/*.mp3 | sort -R", "age=86400");
@mp3s = split(/\n/, $out);

debug(@mp3s);

# NOTES: mplayer -af scaletempo -speed 1.5 file
# mplayer -really-quiet -af scaletempo -speed 1.5 file /mnt/sshfs/MP3/file.mp3

