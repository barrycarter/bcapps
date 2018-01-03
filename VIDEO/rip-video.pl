#!/bin/perl

# selectively rips a video (one frame per second) to display it faster

require "/usr/local/lib/bclib.pl";

# TODO: 1280x720 seems to be the best resolution for youtube (even
# though my own screen resolution is lower)

# 256x144 is 5x5 tiling which really seems nice

# TODO: create subdir to hold these and more subdir per film
# TODO: cleanup file names considerably
# TODO: use xargs for multiples

my($file) = @ARGV;

my($out, $err, $res);

# the output file base, cleanedup version of name

$filebase = $file;

# just the tail + strip extension + convert nonalpha to underscore

$filebase=~s%^.*/%%;
$filebase=~s/\.[^\.]*?$//;
$filebase=~s/[^\w]+/_/g;

# chdir to the appropriate subdirectory + create subsubdir

dodie('chdir("$bclib{home}/VIDEOFRAMES")');
# making the filebase also the dirname is weird but maybe ok
dodie('mkdir("$filebase")');



debug("FILEBASE: $filebase");


die "TESTING";



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


