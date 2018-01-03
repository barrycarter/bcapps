#!/bin/perl

# selectively rips a video (one frame per second) to display it faster

require "/usr/local/lib/bclib.pl";

# TODO: create subdir to hold these and more subdir per film
# TODO: cleanup file names considerably
# TODO: use xargs for multiples

my($file) = @ARGV;

# because I do a chdir, I need to get the whole path to the file

unless ($file=~m%^/%) {$file = "$ENV{cwd}/$file";}

debug("FILE: $file");

# snip 1 frame to get "natural" size

# TODO: is first frame the best one to snip?

my($tmpdir) = tmpdir();
chdir($tmpdir);

debug("TEMPDIR: $tmpdir, NOT DELETING DURING TESTING");

$globopts{keeptemp} = 1;

my($out, $err, $res) = cache_command2("ffmpeg -i '$file' -vframes 1 output.jpg");

debug("OUT: $out, ERR: $err, RES: $res");


