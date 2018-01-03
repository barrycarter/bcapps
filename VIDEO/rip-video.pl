#!/bin/perl

# selectively rips a video (one frame per second) to display it faster

require "/usr/local/lib/bclib.pl";

# TODO: 854x480 will be final resolution for youtube (1280 too wide
# for my screen)

# TODO: create subdir to hold these and more subdir per film
# TODO: cleanup file names considerably
# TODO: use xargs for multiples

my($file) = @ARGV;

my($out, $err, $res);

# because I do a chdir, I need to get the whole path to the file

unless ($file=~m%^/%) {$file = "$ENV{PWD}/$file";}

debug("FILE: $file");

# snip 1 frame to get "natural" size

# TODO: is first frame the best one to snip?

my($tmpdir) = tmpdir();
chdir($tmpdir);

debug("TEMPDIR: $tmpdir, NOT DELETING DURING TESTING");

$globopts{keeptemp} = 1;

($out, $err, $res) = cache_command2("ffmpeg -i '$file' -vframes 1 output.jpg");

($out, $err, $res) = cache_command2("identify output.jpg");

debug("OUT: $out, ERR: $err, RES: $res");


